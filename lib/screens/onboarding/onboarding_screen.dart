import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _pickedImagePath;
  int _selectedDefaultAvatar = 0;
  String? _errorText;

  final List<String> _defaultAvatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
    'assets/images/avatar4.png',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _pickedImagePath = picked.path;
        });
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
              title: const Text('ক্যামেরা দিয়ে ছবি তুলুন'),
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

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = 'অনুগ্রহ করে আপনার নামটি লিখুন';
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.saveUser(
      name: name,
      avatarPath: _pickedImagePath,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'স্বাগতম!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার আয় ও ব্যয়ের নিখুঁত হিসাব রাখতে চলুন একটি প্রোফাইল তৈরি করি।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 36),

              // প্রোফাইল ছবি
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: AppColors.primary, width: 3),
                        image: _pickedImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_pickedImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _pickedImagePath == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: Colors.grey.shade500,
                            )
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
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: const Text('প্রোফাইল ছবি দিন (ঐচ্ছিক)'),
              ),

              const SizedBox(height: 32),

              // নাম ইনপুট
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'আপনার নাম',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'যেমন: মোহাম্মদ রহিম',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
              ),

              const SizedBox(height: 48),

              // শুরু করুন বাটন
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'শুরু করুন',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
