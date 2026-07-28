import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nutrisi'),
        backgroundColor: Colors.green,
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