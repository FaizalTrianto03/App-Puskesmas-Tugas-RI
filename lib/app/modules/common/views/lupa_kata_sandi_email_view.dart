import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class LupaKataSandiEmailView extends StatefulWidget {
  const LupaKataSandiEmailView({Key? key}) : super(key: key);

  @override
  State<LupaKataSandiEmailView> createState() => _LupaKataSandiEmailViewState();
}

class _LupaKataSandiEmailViewState extends State<LupaKataSandiEmailView> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleKirimOTP() async {
    if (_isLoading) return;
    
    // Validasi email harus diisi
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Email wajib diisi');
      return;
    }

    // Validasi format email Gmail
    final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      // Cek dulu apakah format email dasar valid
      final basicEmailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!basicEmailRegex.hasMatch(_emailController.text.trim())) {
        _showErrorSnackBar('Format email tidak valid');
      } else {
        _showErrorSnackBar('Email harus menggunakan Gmail (@gmail.com)');
      }
      return;
    }

    // Show loading
    setState(() => _isLoading = true);
    
    // Simulate sending OTP
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    // Navigasi ke halaman reset (OTP + Password baru jadi satu)
    Get.toNamed(
      Routes.lupaKataSandiReset,
      arguments: {'email': _emailController.text.trim()},
    );
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Terjadi kesalahan,',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF3B30),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      showProgressIndicator: false,
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      titleText: const Text(
        'Terjadi kesalahan,',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,
              AppColors.gradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar manual
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Icon ilustrasi
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      // Label Email
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Masukkan email Anda',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.white,
                        borderWidth: 0,
                      ),
                      const SizedBox(height: 270),
                      // Tombol Kirim Kode OTP
                      Semantics(
                        button: true,
                        label: 'Tombol kirim kode OTP',
                        enabled: !_isLoading,
                        child: CustomButton(
                          text: 'Kirim Kode OTP',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleKirimOTP,
                        ),
                      ),
                      const SizedBox(height: 32),
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
