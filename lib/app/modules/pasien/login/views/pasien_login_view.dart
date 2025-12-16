import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../controllers/pasien_login_controller.dart';
import 'staff_selector_view.dart';

class PasienLoginView extends GetView<PasienLoginController> {
  const PasienLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PasienLoginViewContent();
  }
}

class _PasienLoginViewContent extends StatefulWidget {
  @override
  State<_PasienLoginViewContent> createState() => _PasienLoginViewContentState();
}

class _PasienLoginViewContentState extends State<_PasienLoginViewContent> with SingleTickerProviderStateMixin {
  late final PasienLoginController controller;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _usernameError;
  String? _passwordError;
  bool _isHoverDaftar = false;
  bool _isPressedDaftar = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    controller = Get.put(PasienLoginController());
    
    // Clear fields saat halaman dibuka
    _usernameController.clear();
    _passwordController.clear();
    _usernameError = null;
    _passwordError = null;
    _rememberMe = false;
    _isPasswordVisible = false;
    
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      Icons.person,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Masuk untuk akses layanan Puskesmas Dau',
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
                      TextSpan(text: 'Username atau NIK'),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _usernameController,
                  hintText: 'Masukkan username atau NIK',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  backgroundColor: AppColors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: _usernameError != null ? Colors.red : AppColors.white,
                  borderWidth: _usernameError != null ? 2 : 0,
                  onChanged: (value) {
                    if (_usernameError != null && value.trim().isNotEmpty) {
                      setState(() {
                        _usernameError = null;
                      });
                    }
                  },
                ),
                if (_usernameError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      _usernameError!,
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
                      
                      if (_usernameController.text.trim().isEmpty) {
                        setState(() {
                          _usernameError = 'Username atau NIK wajib diisi';
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
                      
                      setState(() => _isLoading = false);
                      Get.offAllNamed(Routes.pasienDashboard);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.white, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ATAU',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.white, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) {
                    setState(() => _isHoverDaftar = true);
                  },
                  onExit: (_) {
                    setState(() => _isHoverDaftar = false);
                  },
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isPressedDaftar = true),
                    onTapUp: (_) {
                      setState(() => _isPressedDaftar = false);
                      Get.toNamed(Routes.pasienRegister);
                    },
                    onTapCancel: () => setState(() => _isPressedDaftar = false),
                    child: AnimatedScale(
                      scale: _isPressedDaftar ? 0.95 : (_isHoverDaftar ? 1.02 : 1.0),
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isHoverDaftar 
                              ? AppColors.white.withOpacity(0.9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                          boxShadow: _isHoverDaftar
                              ? [
                                  BoxShadow(
                                    color: AppColors.white.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Daftar sebagai Pasien Baru',
                            style: AppTextStyles.button.copyWith(
                              color: _isHoverDaftar ? AppColors.primary : AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pasien Baru?',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jika Anda belum pernah berobat di puskesmas kami, silahkan klik tombol "Daftar sebagai Pasien Baru" untuk registrasi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const StaffSelectorView()),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          const TextSpan(text: 'Masuk sebagai staf Puskesmas? '),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
