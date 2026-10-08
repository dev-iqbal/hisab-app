import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/bangla_number.dart';
import '../../../core/utils/date_helper.dart';
import '../../../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isBanglaDigits;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.isBanglaDigits,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.isIncome;
    final accentColor = isIncome ? AppColors.income : AppColors.expense;
    final lightAccent = isIncome ? AppColors.incomeLight : AppColors.expenseLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ক্যাটাগরি আইকন
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: lightAccent.withOpacity(isDark ? 0.2 : 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                transaction.categoryIcon != null
                    ? IconData(transaction.categoryIcon!, fontFamily: 'MaterialIcons')
                    : (isIncome ? Icons.trending_up_rounded : Icons.shopping_bag_rounded),
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // টাইটেল, ক্যাটাগরি ও তারিখ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (transaction.categoryColor != null 
                              ? Color(transaction.categoryColor!) 
                              : AppColors.primary).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.categoryName ?? (isIncome ? 'আয়' : 'ব্যয়'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: transaction.categoryColor != null
                                ? Color(transaction.categoryColor!)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateHelper.formatShort(transaction.date, isBangla: isBanglaDigits),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // টাকার পরিমাণ
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${AppStrings.currencySymbol} ${BanglaNumber.format(transaction.amount, isBanglaDigits: isBanglaDigits)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateHelper.getWeekday(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
