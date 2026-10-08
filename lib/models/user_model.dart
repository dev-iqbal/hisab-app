class UserModel {
  final int id;
  final String name;
  final String? avatarPath;
  final bool isBanglaDigits;
  final bool isDarkMode;

  UserModel({
    this.id = 1,
    required this.name,
    this.avatarPath,
    this.isBanglaDigits = true,
    this.isDarkMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.trim(),
      'avatar_path': avatarPath,
      'is_bangla_digits': isBanglaDigits ? 1 : 0,
      'is_dark_mode': isDarkMode ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int? ?? 1,
      name: map['name'] as String? ?? 'ব্যবহারকারী',
      avatarPath: map['avatar_path'] as String?,
      isBanglaDigits: (map['is_bangla_digits'] as int? ?? 1) == 1,
      isDarkMode: (map['is_dark_mode'] as int? ?? 0) == 1,
    );
  }

  UserModel copyWith({
    String? name,
    String? avatarPath,
    bool? isBanglaDigits,
    bool? isDarkMode,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      isBanglaDigits: isBanglaDigits ?? this.isBanglaDigits,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
