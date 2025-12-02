import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class PerawatLoginView extends StatefulWidget {
  const PerawatLoginView({Key? key}) : super(key: key);

  @override
  State<PerawatLoginView> createState() => _PerawatLoginViewState();
}

class _PerawatLoginViewState extends State<PerawatLoginView> 
    with SingleTickerProviderStateMixin {
  final _dataDiriController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _dataDiriError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Clear fields saat halaman dibuka
    _dataDiriController.clear();
    _passwordController.clear();
    _dataDiriError = null;
    _passwordError = null;
    _rememberMe = false;
    _isPasswordVisible = false;
    
    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dataDiriController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Masuk sebagai Perawat untuk akses layanan Puskesmas',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    children: const [
                      TextSpan(text: 'Data Diri (Email/Username)'),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _dataDiriController,
                  hintText: 'Masukkan email atau username',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  backgroundColor: AppColors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: _dataDiriError != null ? Colors.red : AppColors.white,
                  borderWidth: _dataDiriError != null ? 2 : 0,
                  onChanged: (value) {
                    if (_dataDiriError != null && value.trim().isNotEmpty) {
                      setState(() {
                        _dataDiriError = null;
                      });
                    }
                  },
                ),
                if (_dataDiriError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      _dataDiriError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    children: const [
                      TextSpan(text: 'Kata Sandi'),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Masukkan kata sandi',
                  obscureText: !_isPasswordVisible,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  backgroundColor: AppColors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: _passwordError != null ? Colors.red : AppColors.white,
                  borderWidth: _passwordError != null ? 2 : 0,
                  onChanged: (value) {
                    if (_passwordError != null && value.trim().isNotEmpty) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      checkColor: AppColors.white,
                      fillColor: MaterialStateProperty.all(AppColors.primary),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    Text(
                      'Ingat Saya',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.lupaKataSandi);
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Semantics(
                  button: true,
                  label: 'Tombol masuk',
                  enabled: !_isLoading,
                  child: CustomButton(
                    text: 'MASUK',
                    isLoading: _isLoading,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    onPressed: _isLoading ? null : () async {
                      // Validasi field harus diisi
                      bool isValid = true;
                      
                      if (_dataDiriController.text.trim().isEmpty) {
                        setState(() {
                          _dataDiriError = 'Email/Username wajib diisi';
                        });
                        isValid = false;
                      }
                      
                      if (_passwordController.text.trim().isEmpty) {
                        setState(() {
                          _passwordError = 'Kata sandi wajib diisi';
                        });
                        isValid = false;
                      }
                      
                      if (!isValid) {
                        return;
                      }
                      
                      setState(() => _isLoading = true);
                      
                      await Future.delayed(const Duration(seconds: 2));
                      
                      if (!mounted) return;
                      
                      setState(() => _isLoading = false);
                      Get.offAllNamed(Routes.perawatDashboard);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          const TextSpan(text: 'Kembali ke pilihan role? '),
                          TextSpan(
                            text: 'Klik di sini',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
