import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    Key? key,
    this.title = AppStrings.noTransactionsYet,
    this.subtitle = 'নতুন লেনদেন যোগ করতে নিচের (+) বাটনে চাপ দিন।',
    this.icon = Icons.receipt_long_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightBorder.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
