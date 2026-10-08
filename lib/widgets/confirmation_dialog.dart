import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = AppStrings.deleteBtn,
    this.cancelText = AppStrings.cancelBtn,
    required this.onConfirm,
    this.isDestructive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isDestructive ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: isDestructive ? AppColors.expense : AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.expense : AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
