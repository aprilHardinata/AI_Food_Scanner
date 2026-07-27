import 'package:flutter/material.dart';
import 'package:healthy_ai_scanner/screens/main_screen.dart';
import 'package:provider/provider.dart';

// Import Provider dan Screen yang sudah kita buat
import 'providers/cart_provider.dart';

void main() {
  // Pastikan binding Flutter sudah siap sebelum menjalankan aplikasi
  // Ini best practice jika kamu pakai database lokal seperti sqflite
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const NutritionTrackerApp());
}

class NutritionTrackerApp extends StatelessWidget {
  const NutritionTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Mendaftarkan semua Provider di akar aplikasi
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Nutrition Tracker',
        debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG"
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        // Menjadikan CatalogScreen sebagai halaman pertama yang muncul
        home: const MainScreen(), 
      ),
    );
  }
}