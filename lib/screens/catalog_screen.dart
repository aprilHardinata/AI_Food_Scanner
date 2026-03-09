import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart'; // Sesuaikan path jika berbeda
import '../models/food_item.dart';
import '../providers/cart_provider.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // Menyimpan Future di variabel agar tidak fetch ulang setiap kali UI re-build
  late Future<List<FoodItem>> _foodListFuture;

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi dari DBHelper yang sudah kamu buat sebelumnya
    _foodListFuture = DBHelper().getFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog Makanan'),
        actions: [
          // Indikator jumlah barang di keranjang pojok kanan atas
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '🛒 ${cart.cartItems.length}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodListFuture,
        builder: (context, snapshot) {
          // 1. State Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // 2. State Error
          else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          // 3. State Kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Katalog makanan kosong.'));
          }

          // 4. State Sukses (Data berhasil ditarik)
          final foods = snapshot.data!;
          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(food.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${food.calories} kcal | P: ${food.protein}g | K: ${food.carbs}g | L: ${food.fat}g\nKat: ${food.category}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                    onPressed: () {
                      // Action: Kirim data makanan ini ke CartProvider
                      Provider.of<CartProvider>(context, listen: false).addItem(food);

                      // Feedback visual berupa SnackBar di bawah layar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.name} ditambahkan!'),
                          duration: Duration(seconds: 1),
                        ),
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