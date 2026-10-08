import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../core/utils/date_helper.dart';

class ExportService {
  /// লেনদেনগুলোকে CSV ফাইলে রূপান্তর করে শেয়ার করা
  static Future<void> exportToCsv(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) {
      throw Exception('এক্সপোর্ট করার মতো কোনো লেনদেন পাওয়া যায়নি!');
    }

    List<List<dynamic>> rows = [];

    // হেডার সারি
    rows.add([
      'আইডি',
      'তারিখ',
      'ধরন',
      'শিরোনাম',
      'ক্যাটাগরি',
      'পরিমাণ (টাকা)',
      'নোট'
    ]);

    for (var tx in transactions) {
      rows.add([
        tx.id ?? '',
        DateHelper.formatFull(tx.date, isBangla: false),
        tx.isIncome ? 'আয়' : 'ব্যয়',
        tx.title,
        tx.categoryName ?? '',
        tx.amount,
        tx.note ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/hisab_report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'আমার আয়-ব্যয়ের হিসাব রিপোর্ট',
      subject: 'আয়-ব্যয় হিসাব CSV রিপোর্ট',
    );
  }
}
