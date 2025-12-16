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
            opacity: controller.fadeAnimation,
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
                Obx(() => CustomTextField(
                  controller: controller.usernameController,
                  hintText: 'Masukkan username atau NIK',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  backgroundColor: AppColors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: controller.usernameError.value != null ? Colors.red : AppColors.white,
                  borderWidth: controller.usernameError.value != null ? 2 : 0,
                  onChanged: (value) => controller.clearUsernameError(),
                )),
                Obx(() => controller.usernameError.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        controller.usernameError.value!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
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
                Obx(() => CustomTextField(
                  controller: controller.passwordController,
                  hintText: 'Masukkan kata sandi',
                  obscureText: !controller.isPasswordVisible.value,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  backgroundColor: AppColors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: controller.passwordError.value != null ? Colors.red : AppColors.white,
                  borderWidth: controller.passwordError.value != null ? 2 : 0,
                  onChanged: (value) => controller.clearPasswordError(),
                )),
                Obx(() => controller.passwordError.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        controller.passwordError.value!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Obx(() => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: controller.toggleRememberMe,
                      checkColor: AppColors.white,
                      fillColor: MaterialStateProperty.all(AppColors.primary),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    )),
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
                Obx(() => Semantics(
                  button: true,
                  label: 'Tombol masuk',
                  enabled: !controller.isLoading.value,
                  child: CustomButton(
                    text: 'MASUK',
                    isLoading: controller.isLoading.value,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    onPressed: controller.isLoading.value ? null : controller.login,
                  ),
                )),
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
                Obx(() => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => controller.setHoverDaftar(true),
                  onExit: (_) => controller.setHoverDaftar(false),
                  child: GestureDetector(
                    onTapDown: (_) => controller.setPressedDaftar(true),
                    onTapUp: (_) {
                      controller.setPressedDaftar(false);
                      Get.toNamed(Routes.pasienRegister);
                    },
                    onTapCancel: () => controller.setPressedDaftar(false),
                    child: AnimatedScale(
                      scale: controller.isPressedDaftar.value ? 0.95 : (controller.isHoverDaftar.value ? 1.02 : 1.0),
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: 50,
                        decoration: BoxDecoration(
                          color: controller.isHoverDaftar.value 
                              ? AppColors.white.withOpacity(0.9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                          boxShadow: controller.isHoverDaftar.value
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
                              color: controller.isHoverDaftar.value ? AppColors.primary : AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
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
