import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/bangla_number.dart';
import '../../core/utils/date_helper.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/success_dialog.dart';
import '../categories/widgets/add_category_dialog.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type; // 'income' অথবা 'expense'
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _type = tx?.type ?? 'expense';
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
      text: tx != null ? (tx.amount % 1 == 0 ? tx.amount.toInt().toString() : tx.amount.toString()) : '',
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedCategoryId = tx?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'তারিখ নির্বাচন করুন',
      confirmText: 'বাছাই',
      cancelText: 'বাতিল',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _openAddNewCategoryModal() async {
    final newCategory = await showDialog<CategoryModel>(
      context: context,
      builder: (_) => AddCategoryDialog(defaultType: _type),
    );

    if (newCategory != null && mounted) {
      setState(() {
        _selectedCategoryId = newCategory.id;
      });
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.selectCategoryError),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.enterAmountError),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (isEditing) {
      final updated = widget.transaction!.copyWith(
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await txProvider.updateTransaction(updated);
      if (mounted) {
        await SuccessDialog.show(context, AppStrings.successUpdated);
        if (mounted) Navigator.pop(context);
      }
    } else {
      final newTx = TransactionModel(
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await txProvider.addTransaction(newTx);
      if (mounted) {
        await SuccessDialog.show(context, AppStrings.successSaved);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'লেনদেন মুছুন',
        message: AppStrings.confirmDelete,
        onConfirm: () async {
          final txProvider = Provider.of<TransactionProvider>(context, listen: false);
          await txProvider.deleteTransaction(widget.transaction!.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.successDeleted),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isBangla = themeProvider.isBanglaDigits;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = _type == 'income'
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    // যদি বর্তমান নির্বাচিত ক্যাটাগরি অন্য টাইপের হয়, তাহলে রিসেট করা
    if (_selectedCategoryId != null && !categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    } else if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final isIncome = _type == 'income';
    final activeColor = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTransaction : AppStrings.addTransaction),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
              onPressed: _deleteTransaction,
              tooltip: 'মুছে ফেলুন',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১. আয় নাকি ব্যয় টগল বাটন
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _selectedCategoryId = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isIncome ? AppColors.income : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  color: isIncome ? Colors.white : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'আয় (Income)',
                                  style: TextStyle(
                                    color: isIncome ? Colors.white : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _selectedCategoryId = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isIncome ? AppColors.expense : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  color: !isIncome ? Colors.white : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ব্যয় (Expense)',
                                  style: TextStyle(
                                    color: !isIncome ? Colors.white : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ২. টাকার পরিমাণ ইনপুট
              Center(
                child: Column(
                  children: [
                    Text(
                      AppStrings.amountLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: activeColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '${AppStrings.currencySymbol} ',
                          prefixStyle: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'টাকার পরিমাণ লিখুন';
                          }
                          final numVal = double.tryParse(val.trim());
                          if (numVal == null || numVal <= 0) {
                            return 'সঠিক পরিমাণ দিন';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ৩. শিরোনাম বা নাম
              const Text(
                'লেনদেনের শিরোনাম *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'যেমন: চাল ডাল কেনা, বিদ্যুৎ বিল, বেতন...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.enterTitleError;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ৪. ক্যাটাগরি বাছাই + নতুন ক্যাটাগরি তৈরি বাটন
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ক্যাটাগরি *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _openAddNewCategoryModal,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('নতুন ক্যাটাগরি'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: const Text(AppStrings.categoryLabel),
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(cat.colorValue).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                                color: Color(cat.colorValue),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(cat.name, style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ৫. তারিখ নির্বাচন
              const Text(
                'তারিখ *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateHelper.formatFull(_selectedDate, isBangla: isBangla),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ৬. অতিরিক্ত নোট (ঐচ্ছিক)
              const Text(
                'অতিরিক্ত নোট (ঐচ্ছিক)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'লেনদেন সম্পর্কে বিশেষ কোনো মন্তব্য থাকলে লিখুন...',
                ),
              ),

              const SizedBox(height: 36),

              // ৭. সংরক্ষণ বাটন
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? AppStrings.updateBtn : AppStrings.saveBtn,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
