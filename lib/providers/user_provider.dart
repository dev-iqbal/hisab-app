import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasUser => _user != null && _user!.name.trim().isNotEmpty;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await DatabaseHelper.instance.getUserProfile();
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUser({required String name, String? avatarPath}) async {
    final newUser = UserModel(
      id: 1,
      name: name.trim(),
      avatarPath: avatarPath ?? _user?.avatarPath,
      isBanglaDigits: _user?.isBanglaDigits ?? true,
      isDarkMode: _user?.isDarkMode ?? false,
    );

    await DatabaseHelper.instance.saveUserProfile(newUser);
    _user = newUser;
    notifyListeners();
  }
}
