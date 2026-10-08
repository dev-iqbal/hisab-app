class BanglaNumber {
  static const Map<String, String> _enToBn = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
    '.': '.',
    ',': ',',
    '-': '-',
    '+': '+',
  };

  /// সংখ্যাকে বাংলা বা ইংরেজি সংখ্যায় রূপান্তর করে
  static String format(num number, {bool isBanglaDigits = true, int decimalDigits = 2}) {
    // দশমিক শূন্য হলে পূর্ণসংখ্যায় দেখানো
    String formatted;
    if (number % 1 == 0) {
      formatted = number.toInt().toString();
    } else {
      formatted = number.toStringAsFixed(decimalDigits);
    }

    if (!isBanglaDigits) {
      return formatted;
    }

    return formatted.split('').map((char) => _enToBn[char] ?? char).join();
  }

  /// টেক্সটের ভিতরের যে কোনো ইংরেজি সংখ্যাকে বাংলায় পরিবর্তন
  static String convertString(String input, {bool isBanglaDigits = true}) {
    if (!isBanglaDigits) return input;
    return input.split('').map((char) => _enToBn[char] ?? char).join();
  }
}
