import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.saveUser(
          name: userProvider.user?.name ?? 'ব্যবহারকারী',
          avatarPath: picked.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('ক্যামেরা দিয়ে নতুন ছবি তুলুন'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              title: const Text('গ্যালারি থেকে ছবি নির্বাচন'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.saveUser(
        name: name,
        avatarPath: userProvider.user?.avatarPath,
      );
      setState(() => _isEditingName = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('নাম সফলভাবে পরিবর্তন করা হয়েছে!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isBangla = themeProvider.isBanglaDigits;
    final avatarPath = userProvider.user?.avatarPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // প্রোফাইল ছবি
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.12),
                      border: Border.all(color: AppColors.primary, width: 3),
                      image: avatarPath != null
                          ? DecorationImage(
                              image: FileImage(File(avatarPath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarPath == null
                        ? const Icon(Icons.person_rounded, size: 54, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // নাম এডিট
            if (_isEditingName)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check, color: AppColors.income),
                    onPressed: _saveName,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.expense),
                    onPressed: () => setState(() => _isEditingName = false),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userProvider.user?.name ?? 'ব্যবহারকারী',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => setState(() => _isEditingName = true),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // অ্যাপ সেটিংস সেকশন
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  // ডার্ক মোড
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.purple.shade900 : Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: isDark ? Colors.purple.shade200 : Colors.amber.shade800,
                        size: 20,
                      ),
                    ),
                    title: const Text('ডার্ক মোড (Dark Theme)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(isDark ? 'ডার্ক মোড সক্রিয়' : 'লাইট মোড সক্রিয়'),
                    value: isDark,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),

                  const Divider(height: 1),

                  // সংখ্যা বাংলা নাকি ইংরেজি
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pin_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text('বাংলা সংখ্যা (১২৩৪)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(isBangla ? 'টাকা ও তারিখ বাংলায় দেখাচ্ছে' : 'English digits (1234)'),
                    value: isBangla,
                    onChanged: (val) => themeProvider.toggleBanglaDigits(val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ডেটা তথ্য ও অফলাইন সিকিউরিটি কার্ড
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.income, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '১০০% অফলাইন ও নিরাপদ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'আপনার কোনো আর্থিক তথ্য কোনো অনলাইন সার্ভারে পাঠানো হয় না। সব তথ্য আপনার ফোনের নিজস্ব SQLite ডেটাবেসে সুরক্ষিতভাবে জমা থাকে।',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ভার্সন টেক্সট
            Text(
              '${AppStrings.appName} • সংস্করণ ১.০.০',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
