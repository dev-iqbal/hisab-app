import 'package:intl/intl.dart';
import 'bangla_number.dart';

class DateHelper {
  static const List<String> _bnMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  static const List<String> _bnDays = [
    'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'
  ];

  /// তারিখকে "১২ অক্টোবর, ২০২৪" ফরম্যাটে দেখায়
  static String formatFull(DateTime date, {bool isBangla = true}) {
    final dayStr = BanglaNumber.format(date.day, isBanglaDigits: isBangla, decimalDigits: 0);
    final monthStr = _bnMonths[date.month - 1];
    final yearStr = BanglaNumber.format(date.year, isBanglaDigits: isBangla, decimalDigits: 0);
    return '$dayStr $monthStr, $yearStr';
  }

  /// ছোট ফরম্যাট: "১২ অক্টো"
  static String formatShort(DateTime date, {bool isBangla = true}) {
    final dayStr = BanglaNumber.format(date.day, isBanglaDigits: isBangla, decimalDigits: 0);
    final monthStr = _bnMonths[date.month - 1].substring(0, 3);
    return '$dayStr $monthStr';
  }

  /// মাসের নাম ও সাল: "অক্টোবর ২০২৪"
  static String formatMonthYear(DateTime date, {bool isBangla = true}) {
    final monthStr = _bnMonths[date.month - 1];
    final yearStr = BanglaNumber.format(date.year, isBanglaDigits: isBangla, decimalDigits: 0);
    return '$monthStr $yearStr';
  }

  /// বার নাম: "শুক্রবার"
  static String getWeekday(DateTime date) {
    return _bnDays[date.weekday - 1];
  }

  /// ISO স্ট্রিং তৈরি
  static String toIso(DateTime date) {
    return date.toIso8601String();
  }

  /// ISO স্ট্রিং থেকে DateTime
  static DateTime fromIso(String isoString) {
    return DateTime.tryParse(isoString) ?? DateTime.now();
  }
}
