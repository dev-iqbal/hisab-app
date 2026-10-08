import 'package:flutter/material.dart';

class AppColors {
  // প্রাথমিক ব্র্যান্ড কালার ও গ্রেডিয়েন্ট
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF8B5CF6); // Purple Accent

  // আয় ও ব্যয় নির্দেশক কালার
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFEF4444); // Red Coral
  static const Color expenseLight = Color(0xFFFEE2E2);

  // লাইট থিম কালার
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ডার্ক থিম কালার
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // গ্রেডিয়েন্টস
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
