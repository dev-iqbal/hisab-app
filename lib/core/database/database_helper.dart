import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hisab_nikesh.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ১. ইউজার প্রোফাইল টেবিল
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_path TEXT,
        is_bangla_digits INTEGER NOT NULL DEFAULT 1,
        is_dark_mode INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ২. ক্যাটাগরি টেবিল (normalized_name ইউনিক রাখা হয়েছে ডুপ্লিকেট রোধে)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        normalized_name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ৩. লেনদেন টেবিল
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // ডিফল্ট ক্যাটাগরিগুলো যুক্ত করা
    await _seedDefaultCategories(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final defaultCategories = [
      // আয় ক্যাটাগরি
      CategoryModel(name: 'বেতন', type: 'income', iconCode: 0xe040, colorValue: 0xFF10B981, isDefault: true),
      CategoryModel(name: 'ব্যবসা', type: 'income', iconCode: 0xe11e, colorValue: 0xFF059669, isDefault: true),
      CategoryModel(name: 'ফ্রিল্যান্সিং', type: 'income', iconCode: 0xe3ac, colorValue: 0xFF0EA5E9, isDefault: true),
      CategoryModel(name: 'অন্যান্য আয়', type: 'income', iconCode: 0xe047, colorValue: 0xFF8B5CF6, isDefault: true),

      // ব্যয় ক্যাটাগরি
      CategoryModel(name: 'মাসিক বাজার', type: 'expense', iconCode: 0xe59c, colorValue: 0xFFEF4444, isDefault: true),
      CategoryModel(name: 'বাসা ভাড়া', type: 'expense', iconCode: 0xe318, colorValue: 0xFFF97316, isDefault: true),
      CategoryModel(name: 'যাতায়াত / গাড়ি ভাড়া', type: 'expense', iconCode: 0xe1d5, colorValue: 0xFFF59E0B, isDefault: true),
      CategoryModel(name: 'বিদ্যুৎ ও অন্যান্য বিল', type: 'expense', iconCode: 0xe3e8, colorValue: 0xFFEAB308, isDefault: true),
      CategoryModel(name: 'চিকিৎসা ও ওষুধ', type: 'expense', iconCode: 0xe3bb, colorValue: 0xFFEC4899, isDefault: true),
      CategoryModel(name: 'খাওয়া-দাওয়া / রেস্তোরাঁ', type: 'expense', iconCode: 0xe532, colorValue: 0xFFD946EF, isDefault: true),
      CategoryModel(name: 'শিক্ষা ও বইপত্র', type: 'expense', iconCode: 0xe54d, colorValue: 0xFF6366F1, isDefault: true),
      CategoryModel(name: 'অন্যান্য খরচ', type: 'expense', iconCode: 0xe400, colorValue: 0xFF64748B, isDefault: true),
    ];

    for (var cat in defaultCategories) {
      await db.insert(
        'categories',
        cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // ==================== ক্যাটাগরি মেথডসমূহ ====================

  /// ক্যাটাগরি ইতিমধ্যে বিদ্যমান কি না যাচাই
  Future<bool> isCategoryExists(String name, {int? excludeId}) async {
    final db = await database;
    final normalized = CategoryModel.normalize(name);
    
    String whereClause = 'normalized_name = ?';
    List<dynamic> whereArgs = [normalized];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final res = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return res.isNotEmpty;
  }

  /// নতুন ক্যাটাগরি সংরক্ষণ
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    final exists = await isCategoryExists(category.name);
    if (exists) {
      throw Exception('এই ক্যাটাগরি আগে থেকেই তৈরি করা আছে!');
    }
    return await db.insert('categories', category.toMap());
  }

  /// ক্যাটাগরি আপডেট
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    final exists = await isCategoryExists(category.name, excludeId: category.id);
    if (exists) {
      throw Exception('এই নামের ক্যাটাগরি আগে থেকেই আছে!');
    }
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// ক্যাটাগরি ডিলিট (লেনদেন থাকলে অনুমতি দেবে না)
  Future<int> deleteCategory(int id) async {
    final db = await database;
    // ক্যাটাগরিতে কোনো লেনদেন আছে কি না যাচাই
    final transactions = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [id],
    );

    if (transactions.isNotEmpty) {
      throw Exception('এই ক্যাটাগরিতে পূর্বের লেনদেন যুক্ত রয়েছে। ডিলিট করা সম্ভব নয়।');
    }

    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// সব ক্যাটাগরি নিয়ে আসা
  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    String? where = type != null ? 'type = ?' : null;
    List<dynamic>? whereArgs = type != null ? [type] : null;

    final maps = await db.query(
      'categories',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'is_default DESC, name ASC',
    );

    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  // ==================== লেনদেন মেথডসমূহ ====================

  /// নতুন লেনদেন যোগ
  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  /// লেনদেন আপডেট
  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  /// লেনদেন ডিলিট
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ফিল্টার অনুযায়ী লেনদেন নিয়ে আসা (Category সহ Join করা)
  Future<List<TransactionModel>> getFilteredTransactions({
    String? type, // 'income', 'expense' অথবা null (সব)
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    String? searchQuery,
  }) async {
    final db = await database;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (type != null && type.isNotEmpty && type != 'all') {
      whereConditions.add('t.type = ?');
      whereArgs.add(type);
    }

    if (startDate != null) {
      whereConditions.add('t.date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('t.date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      final placeholders = List.filled(categoryIds.length, '?').join(',');
      whereConditions.add('t.category_id IN ($placeholders)');
      whereArgs.addAll(categoryIds);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereConditions.add('(t.title LIKE ? OR t.note LIKE ?)');
      whereArgs.add('%${searchQuery.trim()}%');
      whereArgs.add('%${searchQuery.trim()}%');
    }

    String whereClause = whereConditions.isNotEmpty
        ? 'WHERE ' + whereConditions.join(' AND ')
        : '';

    final query = '''
      SELECT 
        t.*,
        c.name AS category_name,
        c.icon_code,
        c.color_value
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      $whereClause
      ORDER BY t.date DESC, t.id DESC
    ''';

    final result = await db.rawQuery(query, whereArgs);
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // ==================== ইউজার প্রোফাইল মেথডসমূহ ====================

  Future<UserModel?> getUserProfile() async {
    final db = await database;
    final res = await db.query('user_profile', where: 'id = 1');
    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  Future<void> saveUserProfile(UserModel user) async {
    final db = await database;
    await db.insert(
      'user_profile',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ডেটাবেস বন্ধ করা
  Future close() async {
    final db = await database;
    db.close();
  }
}
