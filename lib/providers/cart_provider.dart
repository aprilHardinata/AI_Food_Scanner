import 'package:flutter/material.dart';
import '../models/food_item.dart';

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
}