import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import '../widgets/chat_ai_sidebar.dart'; 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nutrisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
          )
        ],
      ),
      
      // 2. Daftarkan UI Chat sebagai End Drawer (muncul dari kanan)
      endDrawer: const AiChatSidebar(), 
      
      // 3. Tambahkan Floating Action Button (FAB)
      // Kita bungkus dengan Builder agar tombol ini tahu posisi Scaffold untuk membuka laci/drawer-nya
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              // Perintah untuk menggeser sidebar keluar
              Scaffold.of(context).openEndDrawer(); 
            },
          );
        }
      ),

      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Menghitung persentase bar (maksimal 1.0 atau 100%)
          double calPercent = (cart.totalCalories / cart.targetCalories).clamp(0.0, 1.0);
          double proPercent = (cart.totalProtein / cart.targetProtein).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progres Hari Ini', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // --- KARTU KALORI ---
                _buildProgressBar(
                  title: 'Kalori',
                  current: cart.totalCalories,
                  target: cart.targetCalories,
                  percent: calPercent,
                  color: Colors.green,
                  unit: 'kcal',
                ),
                const SizedBox(height: 16),

                // --- KARTU PROTEIN ---
                _buildProgressBar(
                  title: 'Protein',
                  current: cart.totalProtein,
                  target: cart.targetProtein,
                  percent: proPercent,
                  color: Colors.redAccent,
                  unit: 'g',
                ),
                
                const Spacer(), // Mendorong tombol ke paling bawah

                // --- TOMBOL KE KATALOG ---
                Padding(
                  padding: const EdgeInsets.only(right: 80.0), // Sisakan ruang di kanan untuk FAB
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Tambah Makanan', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen()));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 23), 
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget helper untuk menggambar Progress Bar yang rapi
  Widget _buildProgressBar({required String title, required double current, required double target, required double percent, required Color color, required String unit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          minHeight: 12,
          backgroundColor: Colors.grey.shade300,
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}