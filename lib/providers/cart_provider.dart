import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../database/db_helper.dart';  

class CartProvider with ChangeNotifier {
  // State utama: Daftar makanan yang dimasukkan ke keranjang hari ini
  final List<FoodItem> _cartItems = [];

  // Getter untuk mengambil data keranjang
  List<FoodItem> get cartItems => _cartItems;

  // --------------------------------------------------------
  // Aksesor (Computed Properties) untuk menghitung total nutrisi
  // --------------------------------------------------------
  
  double get totalCalories {
    // Fold adalah cara elegan di Dart untuk menjumlahkan isi list
    return _cartItems.fold(0.0, (sum, item) => sum + item.calories);
  }

  double get totalProtein {
    return _cartItems.fold(0.0, (sum, item) => sum + item.protein);
  }

  double get totalCarbs {
    return _cartItems.fold(0.0, (sum, item) => sum + item.carbs);
  }

  double get totalFat {
    return _cartItems.fold(0.0, (sum, item) => sum + item.fat);
  }

  // --------------------------------------------------------
  // Fungsi (Actions) untuk memanipulasi keranjang
  // --------------------------------------------------------

  void addItem(FoodItem item) {
    _cartItems.add(item);
    notifyListeners(); // Wajib dipanggil agar UI yang memakai data ini otomatis ter-update
  }

  void removeItem(FoodItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // --- TARGET HARIAN (Bisa diubah jadi dinamis nanti) ---
  final double targetCalories = 2000.0;
  final double targetProtein = 120.0;

  // --- STATE UNTUK HASIL ANALISIS ---
  String _aiMessage = "";
  String get aiMessage => _aiMessage;

  // --- LOGIKA CERDAS (RULE-BASED AI) ---
  Future<void> analyzeNutritionAndRecommend() async {
    double missingCalories = targetCalories - totalCalories;
    double missingProtein = targetProtein - totalProtein;

    // Skenario 1: Kalori sudah pas/berlebih
    if (missingCalories <= 0) {
      _aiMessage = "🌟 Target kalori harianmu sudah terpenuhi! Jangan makan berat lagi ya.";
      notifyListeners();
      return;
    }

    // Ambil semua data makanan dari SQLite untuk dianalisis
    // Import DBHelper di bagian atas file jika belum: import '../database/db_helper.dart';
    final allFoods = await DBHelper().getFoodItems();

    // Skenario 2: Kekurangan Protein sangat tinggi (> 20 gram)
    if (missingProtein > 20) {
      // AI mencari makanan yang tinggi protein tapi kalorinya pas dengan sisa kalori
      var recommendedFoods = allFoods.where((f) => f.protein >= 10 && f.calories <= missingCalories).toList();
      
      if (recommendedFoods.isNotEmpty) {
        recommendedFoods.shuffle(); // Acak agar rekomendasinya tidak itu-itu saja
        final suggestion = recommendedFoods.first;
        _aiMessage = "🔍 Analisis: Kamu masih butuh banyak protein.\n💡 Rekomendasi: Tambahkan '${suggestion.name}' (+${suggestion.protein}g Protein) untuk memenuhi target tanpa *over-calorie*.";
      } else {
        _aiMessage = "🔍 Analisis: Proteinmu kurang, tapi sisa kalorimu terlalu sedikit untuk makan besar. Coba cari cemilan tinggi protein.";
      }
    } 
    // Skenario 3: Kurang Kalori secara umum
    else {
      var snacks = allFoods.where((f) => f.calories <= missingCalories && f.category == 'Buah').toList();
      if (snacks.isNotEmpty) {
        snacks.shuffle();
        final suggestion = snacks.first;
        _aiMessage = "🔍 Analisis: Makronutrisi cukup aman, tapi kalori harianmu masih kurang.\n💡 Rekomendasi: Makan '${suggestion.name}' sebagai cemilan sehat penutup hari.";
      } else {
        _aiMessage = "🔥 Sedikit lagi target terpenuhi, pertahankan dietmu!";
      }
    }

    notifyListeners();
  }

}
