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
              // Tambahan opsional: helperText agar user tahu format yang benar
              TextField(controller: _calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kalori', helperText: 'Isi angka saja, misal: 95')),
              TextField(controller: _proCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein', helperText: 'Isi angka saja, misal: 0.5')),
              TextField(controller: _carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Karbohidrat', helperText: 'Isi angka saja, misal: 25')),
              TextField(controller: _fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lemak', helperText: 'Isi angka saja, misal: 0.3')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // Ambil semua teks dan bersihkan spasi berlebih
              String name = _nameCtrl.text.trim();
              String calText = _calCtrl.text.trim();
              String proText = _proCtrl.text.trim();
              String carbText = _carbCtrl.text.trim();
              String fatText = _fatCtrl.text.trim();

              // --- 1. VALIDASI KOSONG ---
              if (name.isEmpty || calText.isEmpty || proText.isEmpty || carbText.isEmpty || fatText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal: Semua kolom wajib diisi!'), backgroundColor: Colors.red),
                );
                return; // Hentikan proses
              }

              // --- 2. VALIDASI ANGKA (PENCEGAH ERROR SATUAN) ---
              // Coba konversi teks menjadi angka desimal (double)
              double? cal = double.tryParse(calText);
              double? pro = double.tryParse(proText);
              double? carb = double.tryParse(carbText);
              double? fat = double.tryParse(fatText);

              // Jika salah satu gagal dikonversi (karena ada huruf/simbol), nilainya akan null
              if (cal == null || pro == null || carb == null || fat == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal: Nilai gizi wajib berupa angka murni (jangan ketik "gram" atau "kcal")!'), 
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return; // Hentikan proses, biarkan form tetap terbuka agar user bisa memperbaiki
              }

              // --- 3. VALIDASI DUPLIKAT ---
              bool isExists = await DBHelper().checkFoodExists(name);
              if (isExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: "$name" sudah ada di katalog!'), backgroundColor: Colors.red),
                );
                return; // Hentikan proses
              }

              // --- 4. JIKA SEMUA VALIDASI LOLOS, SIMPAN KE DATABASE ---
              FoodItem newItem = FoodItem(
                name: name,
                calories: cal,
                protein: pro,
                carbs: carb,
                fat: fat,
                category: 'Kustom', 
              );

              await DBHelper().insertFoodItem(newItem);

              // Tutup Pop-up & Refresh Layar
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
                  isThreeLine: true,

                  onLongPress: () {
                    showDialog(
                      context: context, 
                      builder: (ctx) => AlertDialog(
                        content: Text('Apakah anda yakin ingin mengahapus "${food.name}" dari katalog'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), 
                          child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              // 1. Eksekusi hapus data dari SQLite berdasarkan ID
                              if (food.id != null) {
                                await DBHelper().deleteFoodItem(food.id!);
                              }
                              
                              // 2. Tutup pop-up
                              Navigator.pop(ctx);
                              
                              // 3. Refresh ulang UI Katalog agar itemnya hilang dari layar
                              _refreshKatalog();
                              
                              // 4. Tampilkan pesan sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${food.name} berhasil dihapus!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            },
                            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ));
                  },
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