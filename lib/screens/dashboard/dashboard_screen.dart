import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/bangla_number.dart';
import '../../core/utils/date_helper.dart';
import '../../models/transaction_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../transactions/add_edit_transaction_screen.dart';
import '../transactions/widgets/transaction_card.dart';
import 'widgets/balance_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardScreen({Key? key, required this.onNavigateToTransactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = userProvider.user?.name ?? 'ব্যবহারকারী';
    final avatarPath = userProvider.user?.avatarPath;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await txProvider.fetchTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. ইউজার প্রোফাইল হেডার
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: avatarPath != null
                            ? DecorationImage(
                                image: FileImage(File(avatarPath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarPath == null
                          ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.welcome},',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTransactionScreen(),
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 26),
                      tooltip: AppStrings.addTransaction,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ২. ব্যালেন্স কার্ড (কাউন্ট-আপ অ্যানিমেশনসহ)
                BalanceCard(
                  balance: txProvider.allTimeBalance,
                  income: txProvider.allTimeIncome,
                  expense: txProvider.allTimeExpense,
                ),

                const SizedBox(height: 28),

                // ৩. সাম্প্রতিক লেনদেন হেডার
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.recentTransactions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToTransactions,
                      child: const Row(
                        children: [
                          Text(
                            AppStrings.viewAll,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ৪. সাম্প্রতিক লেনদেনের তালিকা
                if (txProvider.recentTransactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.noTransactionsYet,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'নিচের (+) বাটনে চাপ দিয়ে আয় বা ব্যয় যোগ করুন।',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: txProvider.recentTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = txProvider.recentTransactions[index];
                      return TransactionCard(
                        transaction: tx,
                        isBanglaDigits: themeProvider.isBanglaDigits,
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

                const SizedBox(height: 80), // FAB স্পেস
              ],
            ),
          ),
        ),
      ),
    );
  }
}
