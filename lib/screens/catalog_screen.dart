import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<FoodItem>> _foodListFuture;

  @override
  void initState() {
    super.initState();
    _refreshKatalog(); // Panggil fungsi refresh saat pertama kali buka
  }

  // Fungsi untuk memuat ulang data dari SQLite
  void _refreshKatalog() {
    setState(() {
      _foodListFuture = DBHelper().getFoodItems();
    });
  }

  // --- FUNGSI MUNCULKAN FORM TAMBAH MAKANAN ---
  void _showAddFoodDialog() {
    final _nameCtrl = TextEditingController();
    final _calCtrl = TextEditingController();
    final _proCtrl = TextEditingController();
    final _carbCtrl = TextEditingController();
    final _fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Makanan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Makanan (Cth: Apel)')),
              TextField(controller: _calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kalori (kcal)')),
              TextField(controller: _proCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)')),
              TextField(controller: _carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Karbohidrat (g)')),
              TextField(controller: _fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lemak (g)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              String name = _nameCtrl.text.trim();
              if (name.isEmpty) return; // Cegah simpan jika nama kosong

              // 1. CEK DUPLIKAT DI DATABASE
              bool isExists = await DBHelper().checkFoodExists(name);
              if (isExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: "$name" sudah ada di katalog!'), backgroundColor: Colors.red),
                );
                return; // Hentikan proses simpan
              }

              // 2. JIKA BELUM ADA, SIMPAN KE DATABASE
              FoodItem newItem = FoodItem(
                name: name,
                calories: double.tryParse(_calCtrl.text) ?? 0,
                protein: double.tryParse(_proCtrl.text) ?? 0,
                carbs: double.tryParse(_carbCtrl.text) ?? 0,
                fat: double.tryParse(_fatCtrl.text) ?? 0,
                category: 'Kustom', // Kategori default untuk buatan user
              );

              await DBHelper().insertFoodItem(newItem);

              // 3. TUTUP POP-UP & REFRESH LAYAR
              Navigator.pop(ctx);
              _refreshKatalog();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Berhasil menambahkan $name!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Makanan'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text('🛒 ${cart.cartItems.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          )
        ],
      ),
      // TOMBOL PLUS DI POJOK KANAN BAWAH
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Makanan Baru',
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Katalog kosong. Tekan tombol + untuk menambahkan makanan.'
                , textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ));
          }

          final foods = snapshot.data!;
          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${food.calories} kcal | P: ${food.protein}g | K: ${food.carbs}g | L: ${food.fat}g'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(food);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${food.name} masuk keranjang!'), duration: const Duration(milliseconds: 800)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}