import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/bangla_number.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/export_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  final List<Color> _chartColors = [
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF0EA5E9),
    const Color(0xFF14B8A6),
  ];

  void _exportData() async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    try {
      await ExportService.exportToCsv(txProvider.transactions);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV ফাইল তৈরি ও শেয়ারের জন্য প্রস্তুত!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = themeProvider.isBanglaDigits;

    final categoryExpenses = txProvider.getCategoryExpenses();
    final totalExpense = txProvider.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navAnalytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _exportData,
            tooltip: 'CSV এক্সপোর্ট ও শেয়ার করুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ওভারভিউ বার
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('মোট আয়', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.currencySymbol} ${BanglaNumber.format(txProvider.totalIncome, isBanglaDigits: isBangla)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(height: 36, width: 1, color: Colors.white.withOpacity(0.3)),
                  Column(
                    children: [
                      Text('মোট ব্যয়', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.currencySymbol} ${BanglaNumber.format(txProvider.totalExpense, isBanglaDigits: isBangla)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ডোনাট চার্ট হেডার
            const Text(
              'ক্যাটাগরি অনুযায়ী ব্যয়ের বিশ্লেষণ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            if (categoryExpenses.isEmpty || totalExpense <= 0)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Text(
                    'চার্ট দেখানোর মতো কোনো ব্যয়ের তথ্য নেই',
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 46,
                          sections: _generateChartSections(categoryExpenses, totalExpense),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ক্যাটাগরি তালিকা ও শতাংশ
                    ...categoryExpenses.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final catName = entry.value.key;
                      final amount = entry.value.value;
                      final percent = (amount / totalExpense) * 100;
                      final color = _chartColors[index % _chartColors.length];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                catName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            Text(
                              '${BanglaNumber.format(percent, isBanglaDigits: isBangla, decimalDigits: 1)}%',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${AppStrings.currencySymbol} ${BanglaNumber.format(amount, isBanglaDigits: isBangla)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // CSV এক্সপোর্ট বাটন
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _exportData,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                label: const Text(
                  'CSV ফরম্যাটে সম্পূর্ণ রিপোর্ট ডাউনলোড ও শেয়ার করুন',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections(Map<String, double> data, double total) {
    int i = 0;
    return data.entries.map((entry) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 62.0 : 52.0;
      final color = _chartColors[i % _chartColors.length];
      final percent = (entry.value / total) * 100;
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
