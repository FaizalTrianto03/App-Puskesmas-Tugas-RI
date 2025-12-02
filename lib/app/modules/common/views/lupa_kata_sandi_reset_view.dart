import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LupaKataSandiResetView extends StatefulWidget {
  const LupaKataSandiResetView({Key? key}) : super(key: key);

  @override
  State<LupaKataSandiResetView> createState() => _LupaKataSandiResetViewState();
}

class _LupaKataSandiResetViewState extends State<LupaKataSandiResetView> {
  final _otpController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  String? _otpError;
  String? _passwordBaruError;
  String? _konfirmasiError;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false;
  int _otpTimer = 60;
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    _otpController.clear();
    _passwordBaruController.clear();
    _konfirmasiController.clear();
    _otpError = null;
    _passwordBaruError = null;
    _konfirmasiError = null;
    _startOTPTimer();
  }
  
  void _startOTPTimer() {
    setState(() {
      _otpTimer = 60;
      _canResendOTP = false;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _otpTimer > 0) {
        setState(() => _otpTimer--);
        _startOTPTimer();
      } else if (mounted) {
        setState(() => _canResendOTP = true);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_isLoading) return;
    
    bool isValid = true;
    
    // Validasi OTP harus diisi
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _otpError = 'OTP wajib diisi';
      });
      _showErrorSnackBar('OTP wajib diisi');
      isValid = false;
    } else if (_otpController.text.trim().length < 6) {
      // Validasi panjang OTP (minimal 6 digit)
      setState(() {
        _otpError = 'OTP harus 6 digit';
      });
      _showErrorSnackBar('OTP harus 6 digit');
      isValid = false;
    }

    // Validasi password baru harus diisi
    if (_passwordBaruController.text.trim().isEmpty) {
      setState(() {
        _passwordBaruError = 'Kata sandi wajib diisi';
      });
      if (isValid) _showErrorSnackBar('Kata sandi wajib diisi');
      isValid = false;
    } else if (_passwordBaruController.text.trim().length < 8) {
      // Validasi password minimal 8 karakter
      setState(() {
        _passwordBaruError = 'Kata sandi minimal 8 karakter';
      });
      if (isValid) _showErrorSnackBar('Kata sandi minimal 8 karakter');
      isValid = false;
    }

    // Validasi konfirmasi password harus diisi
    if (_konfirmasiController.text.trim().isEmpty) {
      setState(() {
        _konfirmasiError = 'Konfirmasi kata sandi wajib diisi';
      });
      if (isValid) _showErrorSnackBar('Konfirmasi kata sandi wajib diisi');
      isValid = false;
    } else if (_passwordBaruController.text.trim() != _konfirmasiController.text.trim()) {
      // Validasi password dan konfirmasi harus sama
      setState(() {
        _konfirmasiError = 'Konfirmasi kata sandi tidak sama';
      });
      if (isValid) _showErrorSnackBar('Konfirmasi kata sandi tidak sama');
      isValid = false;
    }

    if (!isValid) {
      return;
    }

    // Show loading
    setState(() => _isLoading = true);
    
    // Simulate reset process
    await Future.delayed(const Duration(seconds: 2));
    
    // Tampilkan dialog sukses (loading akan hilang setelah dialog muncul)
    _showSuccessDialog();
    
    // Hide loading after dialog is shown
    setState(() => _isLoading = false);
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
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Berhasil!',
                style: AppTextStyles.h2.copyWith(
                  color: const Color(0xFF02B1BA),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Kata sandi berhasil diubah. Silakan login dengan kata sandi baru Anda.',
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
                    // Kembali ke halaman login (pop semua halaman lupa kata sandi)
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
                      // Label Kode OTP
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(text: 'Kode OTP'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // OTP Field
                      CustomTextField(
                        controller: _otpController,
                        hintText: 'Masukkan 6 digit kode OTP',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: _otpError != null ? Colors.red : AppColors.white,
                        borderWidth: _otpError != null ? 2 : 0,
                        onChanged: (value) {
                          if (_otpError != null && value.trim().isNotEmpty) {
                            setState(() {
                              _otpError = null;
                            });
                          }
                        },
                      ),
                      if (_otpError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _otpError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // OTP Timer & Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _otpTimer > 0 
                                ? 'Kode berlaku selama ${_otpTimer}s'
                                : 'Kode OTP telah kadaluarsa',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _otpTimer > 0 ? AppColors.white : Colors.red[300],
                              fontSize: 12,
                            ),
                          ),
                          if (_canResendOTP)
                            TextButton(
                              onPressed: () {
                                _startOTPTimer();
                                Get.snackbar(
                                  'Berhasil',
                                  'Kode OTP baru telah dikirim',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: const Color(0xFF4CAF50),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              child: Text(
                                'Kirim Ulang',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Label Kata Sandi Baru
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(text: 'Kata Sandi Baru'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Password Baru Field
                      CustomTextField(
                        controller: _passwordBaruController,
                        hintText: 'Masukkan kata sandi baru',
                        obscureText: _obscurePasswordBaru,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePasswordBaru
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePasswordBaru = !_obscurePasswordBaru;
                            });
                          },
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: _passwordBaruError != null ? Colors.red : AppColors.white,
                        borderWidth: _passwordBaruError != null ? 2 : 0,
                        onChanged: (value) {
                          if (_passwordBaruError != null && value.trim().isNotEmpty) {
                            setState(() {
                              _passwordBaruError = null;
                            });
                          }
                        },
                      ),
                      if (_passwordBaruError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _passwordBaruError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Label Konfirmasi Kata Sandi Baru
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(text: 'Konfirmasi Kata Sandi Baru'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Konfirmasi Password Field
                      CustomTextField(
                        controller: _konfirmasiController,
                        hintText: 'Masukkan konfirmasi kata sandi',
                        obscureText: _obscureKonfirmasi,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKonfirmasi
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureKonfirmasi = !_obscureKonfirmasi;
                            });
                          },
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: _konfirmasiError != null ? Colors.red : AppColors.white,
                        borderWidth: _konfirmasiError != null ? 2 : 0,
                        onChanged: (value) {
                          if (_konfirmasiError != null && value.trim().isNotEmpty) {
                            setState(() {
                              _konfirmasiError = null;
                            });
                          }
                        },
                      ),
                      if (_konfirmasiError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _konfirmasiError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      // Tombol Perbarui Kata Sandi
                      Semantics(
                        button: true,
                        label: 'Tombol perbarui kata sandi',
                        enabled: !_isLoading,
                        child: CustomButton(
                          text: 'Perbarui Kata Sandi',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleResetPassword,
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
