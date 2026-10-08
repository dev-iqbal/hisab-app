import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/user_model.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isBanglaDigits = true;

  bool get isDarkMode => _isDarkMode;
  bool get isBanglaDigits => _isBanglaDigits;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void initFromUser(UserModel user) {
    _isDarkMode = user.isDarkMode;
    _isBanglaDigits = user.isBanglaDigits;
    notifyListeners();
  }

  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    _persistSettings();
  }

  void toggleBanglaDigits(bool value) async {
    _isBanglaDigits = value;
    notifyListeners();
    _persistSettings();
  }

  void _persistSettings() async {
    final user = await DatabaseHelper.instance.getUserProfile();
    if (user != null) {
      final updated = user.copyWith(
        isDarkMode: _isDarkMode,
        isBanglaDigits: _isBanglaDigits,
      );
      await DatabaseHelper.instance.saveUserProfile(updated);
    }
  }
}
