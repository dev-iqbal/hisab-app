class TransactionModel {
  final int? id;
  final int categoryId;
  final String title;
  final double amount;
  final String type; // 'income' অথবা 'expense'
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  // ক্যাটাগরির অতিরিক্ত তথ্য (UI তে দেখানোর সুবিধার জন্য জয়েন ডেটা)
  final String? categoryName;
  final int? categoryIcon;
  final int? categoryColor;

  TransactionModel({
    this.id,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    DateTime? createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title.trim(),
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note?.trim(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
      categoryName: map['category_name'] as String?,
      categoryIcon: map['icon_code'] as int?,
      categoryColor: map['color_value'] as int?,
    );
  }

  TransactionModel copyWith({
    int? id,
    int? categoryId,
    String? title,
    double? amount,
    String? type,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    String? categoryName,
    int? categoryIcon,
    int? categoryColor,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}
