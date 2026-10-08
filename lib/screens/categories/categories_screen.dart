import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import 'widgets/add_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddCategory(String defaultType) {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(defaultType: defaultType),
    );
  }

  void _openEditCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(
        defaultType: category.type,
        editingCategory: category,
      ),
    );
  }

  void _deleteCategory(CategoryModel category) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'ক্যাটাগরি মুছবেন?',
        message: '"${category.name}" ক্যাটাগরিটি মুছে ফেলতে চান?',
        onConfirm: () async {
          try {
            await categoryProvider.deleteCategory(category.id!);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ক্যাটাগরি সফলভাবে মুছে ফেলা হয়েছে'),
                  backgroundColor: AppColors.income,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.expense),
                      SizedBox(width: 8),
                      Text('সতর্কতা', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text(
                    AppStrings.categoryDeleteWarning,
                    style: TextStyle(height: 1.4),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('বুঝেছি'),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navCategories),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'ব্যয় ক্যাটাগরি'),
            Tab(text: 'আয় ক্যাটাগরি'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(categoryProvider.expenseCategories, isDark),
          _buildCategoryList(categoryProvider.incomeCategories, isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCategory(_tabController.index == 0 ? 'expense' : 'income'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          AppStrings.addCategory,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> list, bool isDark) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'কোনো ক্যাটাগরি নেই',
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = list[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(cat.colorValue).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                  color: Color(cat.colorValue),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  cat.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                onPressed: () => _openEditCategory(cat),
                tooltip: 'সম্পাদনা',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.expense),
                onPressed: () => _deleteCategory(cat),
                tooltip: 'মুছুন',
              ),
            ],
          ),
        );
      },
    );
  }
}
