import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

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
    SnackbarHelper.showError(message);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Icon ilustrasi dengan container background
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Judul
                Text(
                  'Lupa Kata Sandi?',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Deskripsi
                Text(
                  'Masukkan email yang terdaftar. Kami akan mengirimkan kode OTP untuk verifikasi akun Anda.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                      // Label Email
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(text: 'Email'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ],
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
                const SizedBox(height: 24),
                // Tombol Kembali ke Login
                TextButton(
                  onPressed: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.white,
                      ),
                      children: const [
                        TextSpan(text: 'Kembali ke Halaman '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
