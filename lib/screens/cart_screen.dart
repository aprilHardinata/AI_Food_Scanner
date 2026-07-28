import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'catalog_screen.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Nutrisi Harian'),
        backgroundColor: Colors.green,
        actions: [
          // Tombol untuk mengosongkan semua daftar
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
            tooltip: 'Kosongkan Jurnal',
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Jika keranjang kosong
          if (cart.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada makanan hari ini.\nYuk tambah dari katalog!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Tambah Makanan', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen()));
                    },
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // --- 1. KOTAK RINGKASAN NUTRISI ---
              Card(
                margin: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Kalori: ${cart.totalCalories.toStringAsFixed(1)} kcal',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutrientStat('Protein', cart.totalProtein, Colors.red),
                          _buildNutrientStat('Karbo', cart.totalCarbs, Colors.blue),
                          _buildNutrientStat('Lemak', cart.totalFat, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. DAFTAR MAKANAN (Bisa di-swipe untuk hapus) ---
              Expanded(
                child: ListView.builder(
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return Dismissible(
                      key: ValueKey('${item.id}_$index'), // Key unik
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) {
                        cart.removeItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} dihapus'), duration: const Duration(seconds: 1)),
                        );
                      },
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.calories} kcal'),
                        trailing: Text('P:${item.protein}g | K:${item.carbs}g | L:${item.fat}g'),
                      ),
                    );
                  },
                ),
              ),

              // --- 3. TOMBOL ANALISIS AI (Untuk fitur selanjutnya) ---
              // --- 3. KOTAK PESAN AI & TOMBOL ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Kotak yang muncul jika AI sudah menganalisis
                    if (cart.aiMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          cart.aiMessage,
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 14, height: 1.4),
                        ),
                      ),
                      
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Tambah Makanan', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen()));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Analisis Nutrisi dengan AI', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          // Panggil fungsi otak AI yang ada di provider
                          Provider.of<CartProvider>(context, listen: false).analyzeNutritionAndRecommend();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // Widget bantuan (Helper) agar kode UI di atas tidak terlalu berantakan
  Widget _buildNutrientStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('${value.toStringAsFixed(1)}g', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}