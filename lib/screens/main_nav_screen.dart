import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'transactions/add_edit_transaction_screen.dart';
import 'analytics/analytics_screen.dart';
import 'categories/categories_screen.dart';
import 'profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _navigateToTransactions() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      DashboardScreen(onNavigateToTransactions: _navigateToTransactions),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const CategoriesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.18),
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: AppStrings.navHome,
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              label: AppStrings.navTransactions,
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded, color: AppColors.primary),
              label: AppStrings.navAnalytics,
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category_rounded, color: AppColors.primary),
              label: AppStrings.navCategories,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
