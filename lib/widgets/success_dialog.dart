import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SuccessDialog extends StatefulWidget {
  final String message;
  const SuccessDialog({Key? key, required this.message}) : super(key: key);

  static Future<void> show(BuildContext context, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SuccessDialog(message: message),
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();

    // ১.২ সেকেন্ড পর স্বয়ংক্রিয়ভাবে বন্ধ হবে
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.incomeLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.income,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
