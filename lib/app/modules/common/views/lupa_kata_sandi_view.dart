import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/quarter_circle_background.dart';

class LupaKataSandiView extends StatefulWidget {
  const LupaKataSandiView({Key? key}) : super(key: key);

  @override
  State<LupaKataSandiView> createState() => _LupaKataSandiViewState();
}

class _LupaKataSandiViewState extends State<LupaKataSandiView> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isHoverKirim = false;
  bool _isPressedKirim = false;

  @override
  void initState() {
    super.initState();
    // Clear field saat halaman dibuka
    _emailController.clear();
    _emailError = null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleKirimLink() {
    setState(() {
      _emailError = null;

      // Validasi email harus diisi
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Email harus diisi';
        return;
      }

      // Validasi format email sederhana
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        _emailError = 'Format email tidak valid';
        return;
      }

      // Tampilkan dialog sukses (tanpa logika bisnis)
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'Link Terkirim',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Link reset kata sandi telah dikirim ke email Anda. Silakan cek inbox atau folder spam.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Kembali ke halaman login
            },
            child: Text(
              'OK',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Icon ilustrasi
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Judul
                Text(
                  'Reset Kata Sandi Anda',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Deskripsi
                Text(
                  'Masukkan email yang terdaftar pada akun Anda. Kami akan mengirimkan link untuk mereset kata sandi.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Masukkan email Anda',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.white),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    if (_emailError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _emailError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                // Tombol Kirim Link
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoverKirim = true),
                  onExit: (_) => setState(() => _isHoverKirim = false),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isPressedKirim = true),
                    onTapUp: (_) => setState(() => _isPressedKirim = false),
                    onTapCancel: () => setState(() => _isPressedKirim = false),
                    child: AnimatedScale(
                      scale: _isPressedKirim ? 0.95 : (_isHoverKirim ? 1.02 : 1.0),
                      duration: const Duration(milliseconds: 100),
                      child: CustomButton(
                        text: 'Kirim Link Reset',
                        onPressed: _handleKirimLink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Link kembali ke login
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.normal,
                        ),
                        children: const [
                          TextSpan(text: 'Kembali ke Halaman '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
