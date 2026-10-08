import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories => _categories.where((c) => c.type == 'income').toList();
  List<CategoryModel> get expenseCategories => _categories.where((c) => c.type == 'expense').toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await DatabaseHelper.instance.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// নতুন ক্যাটাগরি তৈরি (ডুপ্লিকেট চেকসহ)
  Future<CategoryModel> addCategory({
    required String name,
    required String type,
    int? iconCode,
    int? colorValue,
  }) async {
    final normalized = CategoryModel.normalize(name);
    if (normalized.isEmpty) {
      throw Exception('ক্যাটাগরির নাম খালি রাখা যাবে না!');
    }

    // চেক করা ডুপ্লিকেট আছে কি না
    final exists = _categories.any((c) => c.normalizedName == normalized && c.type == type);
    if (exists) {
      throw Exception('এই ক্যাটাগরি আগে থেকেই তৈরি করা আছে!');
    }

    final newCat = CategoryModel(
      name: name.trim(),
      type: type,
      iconCode: iconCode ?? (type == 'income' ? 0xe040 : 0xe59c),
      colorValue: colorValue ?? (type == 'income' ? 0xFF10B981 : 0xFFEF4444),
      isDefault: false,
    );

    final id = await DatabaseHelper.instance.insertCategory(newCat);
    final created = newCat.copyWith(id: id);
    _categories.add(created);
    notifyListeners();
    return created;
  }

  /// ক্যাটাগরি আপডেট
  Future<void> updateCategory(CategoryModel category) async {
    final normalized = CategoryModel.normalize(category.name);
    final exists = _categories.any((c) => c.normalizedName == normalized && c.id != category.id && c.type == category.type);
    if (exists) {
      throw Exception('এই নামের ক্যাটাগরি আগে থেকেই আছে!');
    }

    await DatabaseHelper.instance.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  /// ক্যাটাগরি মুছে ফেলা
  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
