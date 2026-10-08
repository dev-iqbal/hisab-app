import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/bangla_number.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/theme_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/animated_number.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_transaction_screen.dart';
import 'widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final txProvider = Provider.of<TransactionProvider>(context, listen: false);
        switch (_tabController.index) {
          case 0:
            txProvider.setType('all');
            break;
          case 1:
            txProvider.setType('income');
            break;
          case 2:
            txProvider.setType('expense');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getPeriodLabel(TimePeriod period, DateTime date, bool isBangla) {
    switch (period) {
      case TimePeriod.daily:
        return DateHelper.formatFull(date, isBangla: isBangla);
      case TimePeriod.weekly:
        final weekday = date.weekday;
        final start = date.subtract(Duration(days: weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateHelper.formatShort(start, isBangla: isBangla)} - ${DateHelper.formatShort(end, isBangla: isBangla)}';
      case TimePeriod.monthly:
        return DateHelper.formatMonthYear(date, isBangla: isBangla);
      case TimePeriod.yearly:
        return '${BanglaNumber.format(date.year, isBanglaDigits: isBangla, decimalDigits: 0)} সাল';
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = themeProvider.isBanglaDigits;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                onChanged: (val) {
                  txProvider.setSearchQuery(val);
                },
              )
            : const Text(AppStrings.navTransactions),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearchVisible) {
                  _searchController.clear();
                  txProvider.setSearchQuery('');
                  _isSearchVisible = false;
                } else {
                  _isSearchVisible = true;
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: AppStrings.tabAll),
            Tab(text: AppStrings.tabIncome),
            Tab(text: AppStrings.tabExpense),
          ],
        ),
      ),
      body: Column(
        children: [
          // ১. সময় নির্বাচন ফিল্টার (দৈনিক, সাপ্তাহিক, মাসিক, বাৎসরিক)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPeriodChip(TimePeriod.daily, AppStrings.filterDaily, txProvider),
                _buildPeriodChip(TimePeriod.weekly, AppStrings.filterWeekly, txProvider),
                _buildPeriodChip(TimePeriod.monthly, AppStrings.filterMonthly, txProvider),
                _buildPeriodChip(TimePeriod.yearly, AppStrings.filterYearly, txProvider),
              ],
            ),
          ),

          // ২. সময়ের আগের ও পরের তারিখে যাওয়ার বোতাম
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () => txProvider.previousPeriod(),
                  tooltip: 'আগের সময়',
                ),
                Text(
                  _getPeriodLabel(txProvider.selectedPeriod, txProvider.currentDate, isBangla),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () => txProvider.nextPeriod(),
                  tooltip: 'পরের সময়',
                ),
              ],
            ),
          ),

          // ৩. ক্যাটাগরি ফিল্টার চিপস
          if (categoryProvider.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  FilterChip(
                    label: const Text('সকল ক্যাটাগরি'),
                    selected: txProvider.selectedCategoryIds.isEmpty,
                    onSelected: (_) => txProvider.clearCategoryFilter(),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ...categoryProvider.categories.map((cat) {
                    final isSelected = txProvider.selectedCategoryIds.contains(cat.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (_) {
                          if (cat.id != null) {
                            txProvider.toggleCategoryFilter(cat.id!);
                          }
                        },
                        selectedColor: Color(cat.colorValue).withOpacity(0.25),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // ৪. এই ফিল্টারের মোট আয়, ব্যয় ও ব্যালেন্স সারাংশ বার
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'আয়',
                  txProvider.totalIncome,
                  AppColors.income,
                  isBangla,
                ),
                Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.3)),
                _buildSummaryItem(
                  'ব্যয়',
                  txProvider.totalExpense,
                  AppColors.expense,
                  isBangla,
                ),
                Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.3)),
                _buildSummaryItem(
                  'ব্যালেন্স',
                  txProvider.balance,
                  txProvider.balance >= 0 ? AppColors.primary : AppColors.expense,
                  isBangla,
                ),
              ],
            ),
          ),

          // ৫. লেনদেনের মূল তালিকা
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : txProvider.transactions.isEmpty
                    ? const EmptyState(
                        title: 'এই সময়ে কোনো লেনদেন পাওয়া যায়নি',
                        subtitle: 'তারিখ বা ফিল্টার পরিবর্তন করে দেখতে পারেন।',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: txProvider.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = txProvider.transactions[index];
                          return TransactionCard(
                            transaction: tx,
                            isBanglaDigits: isBangla,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditTransactionScreen(transaction: tx),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          AppStrings.addTransaction,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(TimePeriod period, String label, TransactionProvider provider) {
    final isSelected = provider.selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setPeriod(period),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, bool isBangla) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          '${AppStrings.currencySymbol} ${BanglaNumber.format(amount, isBanglaDigits: isBangla)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
