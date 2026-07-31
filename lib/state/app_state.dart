import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  List<String> appliances = [];
  List<String> pantryIngredients = [];

  void logIn() {
    isLoggedIn = true;
    notifyListeners();
  }

  void skipLogin() {
    isLoggedIn = false;
    notifyListeners();
  }

  void setAppliances(List<String> selected) {
    appliances = selected;
    notifyListeners();
  }
}