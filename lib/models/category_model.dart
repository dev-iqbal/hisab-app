class CategoryModel {
  final int? id;
  final String name;
  final String normalizedName;
  final String type; // 'income' অথবা 'expense'
  final int iconCode;
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    this.id,
    required this.name,
    String? normalizedName,
    required this.type,
    this.iconCode = 0xe3ae, // Icons.category_rounded codepoint default
    this.colorValue = 0xFF6366F1,
    this.isDefault = false,
  }) : normalizedName = normalizedName ?? normalize(name);

  /// ক্যাটাগরির নাম নরমালাইজ করার ফাংশন (বড়-ছোট হাতের অক্ষর ও একাধিক স্পেস দূর করে)
  static String normalize(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.trim(),
      'normalized_name': normalize(name),
      'type': type,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      normalizedName: map['normalized_name'] as String,
      type: map['type'] as String,
      iconCode: map['icon_code'] as int? ?? 0xe3ae,
      colorValue: map['color_value'] as int? ?? 0xFF6366F1,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    int? iconCode,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
