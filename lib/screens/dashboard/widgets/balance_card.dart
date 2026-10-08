import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/animated_number.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.income,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalBalance,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      balance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      balance >= 0 ? 'পজিটিভ' : 'ঘাটতি',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedNumber(
            value: balance,
            prefix: '${AppStrings.currencySymbol} ',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // মোট আয়
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.income.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.totalIncome,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedNumber(
                              value: income,
                              prefix: '+${AppStrings.currencySymbol} ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ডিভাইডার
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.white.withOpacity(0.25),
                ),
                const SizedBox(width: 12),

                // মোট ব্যয়
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.totalExpense,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedNumber(
                              value: expense,
                              prefix: '-${AppStrings.currencySymbol} ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
