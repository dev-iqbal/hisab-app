import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/category_model.dart';
import '../../../providers/category_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final String defaultType;
  final CategoryModel? editingCategory;

  const AddCategoryDialog({
    Key? key,
    this.defaultType = 'expense',
    this.editingCategory,
  }) : super(key: key);

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late TextEditingController _nameController;
  late String _type;
  late int _selectedIcon;
  late int _selectedColor;
  String? _errorMessage;

  final List<int> _availableIcons = [
    0xe59c, // shopping_cart
    0xe318, // home
    0xe1d5, // directions_car
    0xe3e8, // lightbulb
    0xe3bb, // local_hospital
    0xe532, // restaurant
    0xe54d, // school
    0xe040, // attach_money
    0xe11e, // business
    0xe3ac, // laptop
    0xe047, // account_balance
    0xe227, // fitness_center
    0xe25a, // flight
    0xe400, // more_horiz
  ];

  final List<int> _availableColors = [
    0xFF10B981, // Emerald
    0xFFEF4444, // Red
    0xFF6366F1, // Indigo
    0xFFF59E0B, // Amber
    0xFF0EA5E9, // Sky Blue
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF14B8A6, // Teal
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.editingCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _type = cat?.type ?? widget.defaultType;
    _selectedIcon = cat?.iconCode ?? _availableIcons.first;
    _selectedColor = cat?.colorValue ?? _availableColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'ক্যাটাগরির নাম লিখুন');
      return;
    }

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    try {
      if (widget.editingCategory != null) {
        final updated = widget.editingCategory!.copyWith(
          name: name,
          type: _type,
          iconCode: _selectedIcon,
          colorValue: _selectedColor,
        );
        await categoryProvider.updateCategory(updated);
        if (mounted) Navigator.pop(context, updated);
      } else {
        final created = await categoryProvider.addCategory(
          name: name,
          type: _type,
          iconCode: _selectedIcon,
          colorValue: _selectedColor,
        );
        if (mounted) Navigator.pop(context, created);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingCategory != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEditing ? AppStrings.editCategory : AppStrings.addCategory,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // টাইপ সিলেক্টর (যদি নতুন হয়)
            if (!isEditing) ...[
              const Text('ধরন নির্বাচন করুন:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ব্যয়')),
                      selected: _type == 'expense',
                      selectedColor: AppColors.expenseLight,
                      onSelected: (_) => setState(() => _type = 'expense'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('আয়')),
                      selected: _type == 'income',
                      selectedColor: AppColors.incomeLight,
                      onSelected: (_) => setState(() => _type = 'income'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // নাম ইনপুট
            const Text('ক্যাটাগরির নাম:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'যেমন: চা নাস্তা, বই কেনা...',
                errorText: _errorMessage,
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 16),

            // আইকন নির্বাচন
            const Text('আইকন পছন্দ করুন:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                itemBuilder: (ctx, i) {
                  final code = _availableIcons[i];
                  final isSel = _selectedIcon == code;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = code),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(code, fontFamily: 'MaterialIcons'),
                        color: isSel ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // রঙ নির্বাচন
            const Text('রঙ পছন্দ করুন:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (ctx, i) {
                  final colVal = _availableColors[i];
                  final isSel = _selectedColor == colVal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colVal),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Color(colVal),
                        shape: BoxShape.circle,
                        border: isSel ? Border.all(color: Colors.black87, width: 2.5) : null,
                      ),
                      child: isSel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? 'আপডেট' : 'যোগ করুন'),
        ),
      ],
    );
  }
}
