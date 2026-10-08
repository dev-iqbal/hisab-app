import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadUser(),
      categoryProvider.loadCategories(),
      transactionProvider.fetchTransactions(),
    ]);

    if (userProvider.user != null) {
      themeProvider.initFromUser(userProvider.user!);
    }

    // সুন্দর স্প্ল্যাশ প্রদর্শনের জন্য অন্তত ১.৫ সেকেন্ড বিরতি
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (userProvider.hasUser) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '৳',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'সহজ ও স্মার্ট অফলাইন হিসাবরক্ষণ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
