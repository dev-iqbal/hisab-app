import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;

  // ফিল্টার স্টেট
  String _selectedType = 'all'; // 'all', 'income', 'expense'
  TimePeriod _selectedPeriod = TimePeriod.monthly;
  DateTime _currentDate = DateTime.now();
  List<int> _selectedCategoryIds = [];
  String _searchQuery = '';

  // গেটার্স
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;
  TimePeriod get selectedPeriod => _selectedPeriod;
  DateTime get currentDate => _currentDate;
  List<int> get selectedCategoryIds => _selectedCategoryIds;
  String get searchQuery => _searchQuery;

  // মোট আয়, ব্যয় ও ব্যালেন্স
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  // সামগ্রিক মোট আয় ও ব্যয় (ড্যাশবোর্ডের ওভারভিউ কার্ডের জন্য)
  double _allTimeIncome = 0.0;
  double _allTimeExpense = 0.0;
  double get allTimeIncome => _allTimeIncome;
  double get allTimeExpense => _allTimeExpense;
  double get allTimeBalance => _allTimeIncome - _allTimeExpense;

  /// লেনদেন ও ড্যাশবোর্ড ডেটা লোড
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dateRange = _getDateRange();
      _transactions = await DatabaseHelper.instance.getFilteredTransactions(
        type: _selectedType == 'all' ? null : _selectedType,
        startDate: dateRange['start'],
        endDate: dateRange['end'],
        categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
        searchQuery: _searchQuery,
      );

      // ড্যাশবোর্ডের জন্য সাম্প্রতিক ৫টি লেনদেন
      _recentTransactions = await DatabaseHelper.instance.getFilteredTransactions();
      if (_recentTransactions.length > 5) {
        _recentTransactions = _recentTransactions.sublist(0, 5);
      }

      // সামগ্রিক হিসাব
      final allList = await DatabaseHelper.instance.getFilteredTransactions();
      _allTimeIncome = allList.where((t) => t.isIncome).fold(0.0, (sum, i) => sum + i.amount);
      _allTimeExpense = allList.where((t) => t.isExpense).fold(0.0, (sum, i) => sum + i.amount);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ফিল্টার সেটার মেথডস
  void setType(String type) {
    _selectedType = type;
    fetchTransactions();
  }

  void setPeriod(TimePeriod period) {
    _selectedPeriod = period;
    fetchTransactions();
  }

  void setDate(DateTime date) {
    _currentDate = date;
    fetchTransactions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchTransactions();
  }

  void toggleCategoryFilter(int categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    fetchTransactions();
  }

  void clearCategoryFilter() {
    _selectedCategoryIds.clear();
    fetchTransactions();
  }

  /// পূর্ববর্তী সময়ে যাওয়া (আগের দিন/সপ্তাহ/মাস/বছর)
  void previousPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        _currentDate = _currentDate.subtract(const Duration(days: 1));
        break;
      case TimePeriod.weekly:
        _currentDate = _currentDate.subtract(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
        break;
      case TimePeriod.yearly:
        _currentDate = DateTime(_currentDate.year - 1, 1, 1);
        break;
    }
    fetchTransactions();
  }

  /// পরবর্তী সময়ে যাওয়া (পরের দিন/সপ্তাহ/মাস/বছর)
  void nextPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        _currentDate = _currentDate.add(const Duration(days: 1));
        break;
      case TimePeriod.weekly:
        _currentDate = _currentDate.add(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
        break;
      case TimePeriod.yearly:
        _currentDate = DateTime(_currentDate.year + 1, 1, 1);
        break;
    }
    fetchTransactions();
  }

  /// সময় সীমার শুরু ও শেষ নির্ধারণ
  Map<String, DateTime> _getDateRange() {
    DateTime start;
    DateTime end;

    switch (_selectedPeriod) {
      case TimePeriod.daily:
        start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, 0, 0, 0);
        end = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, 23, 59, 59);
        break;
      case TimePeriod.weekly:
        // সপ্তাহের শুরু (সোমবার)
        final weekday = _currentDate.weekday;
        start = _currentDate.subtract(Duration(days: weekday - 1));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case TimePeriod.monthly:
        start = DateTime(_currentDate.year, _currentDate.month, 1, 0, 0, 0);
        final nextMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);
        end = nextMonth.subtract(const Duration(seconds: 1));
        break;
      case TimePeriod.yearly:
        start = DateTime(_currentDate.year, 1, 1, 0, 0, 0);
        end = DateTime(_currentDate.year, 12, 31, 23, 59, 59);
        break;
    }

    return {'start': start, 'end': end};
  }

  /// নতুন লেনদেন যোগ
  Future<void> addTransaction(TransactionModel tx) async {
    await DatabaseHelper.instance.insertTransaction(tx);
    await fetchTransactions();
  }

  /// লেনদেন আপডেট
  Future<void> updateTransaction(TransactionModel tx) async {
    await DatabaseHelper.instance.updateTransaction(tx);
    await fetchTransactions();
  }

  /// লেনদেন ডিলিট
  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await fetchTransactions();
  }

  /// ক্যাটাগরিভিত্তিক ব্যয়ের হিসাব (পাই চার্টের জন্য)
  Map<String, double> getCategoryExpenses() {
    final Map<String, double> map = {};
    for (var tx in _transactions.where((t) => t.isExpense)) {
      final name = tx.categoryName ?? 'অন্যান্য';
      map[name] = (map[name] ?? 0.0) + tx.amount;
    }
    return map;
  }
}
