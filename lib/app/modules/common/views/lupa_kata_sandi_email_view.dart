import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth/auth_service.dart';
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
  final _authService = AuthService();

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

  void _handleKirimLink() async {
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
    
    try {
      // Send Firebase password reset email
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      
      setState(() => _isLoading = false);
      
      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorSnackBar(String message) {
    SnackbarHelper.showError(message);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: Color(0xFF4CAF50),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Email Terkirim!',
                style: AppTextStyles.h2.copyWith(
                  color: const Color(0xFF02B1BA),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Link reset kata sandi telah dikirim ke email Anda. Silakan cek inbox atau folder spam untuk melanjutkan proses reset kata sandi.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke halaman login
                    Get.until((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali ke Login',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.0,
            left: 24.0,
            right: 24.0,
            bottom: MediaQuery.of(context).padding.bottom + 40.0,
          ),
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
                  'Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset kata sandi Anda.',
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
                // Tombol Kirim Link Reset
                Semantics(
                  button: true,
                  label: 'Tombol kirim link reset',
                  enabled: !_isLoading,
                  child: CustomButton(
                    text: 'Kirim Link Reset',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleKirimLink,
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
      );
  }
}
