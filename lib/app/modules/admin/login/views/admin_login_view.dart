import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../controllers/admin_login_controller.dart';

class AdminLoginView extends GetView<AdminLoginController> {
  const AdminLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.delete<AdminLoginController>();
    final controller = Get.put(AdminLoginController());
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientTop, AppColors.gradientBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Form(
              key: controller.formKey,
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
                        Icons.admin_panel_settings,
                        size: 80,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Masuk sebagai Admin untuk akses layanan Puskesmas',
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
                    controller: controller.emailController,
                    hintText: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                    backgroundColor: AppColors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    borderColor: AppColors.white,
                    borderWidth: 0,
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
                  Obx(
                    () => CustomTextField(
                      controller: controller.passwordController,
                      hintText: 'Masukkan kata sandi',
                      obscureText: !controller.isPasswordVisible.value,
                      validator: controller.validatePassword,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      backgroundColor: AppColors.white,
                      textColor: Colors.black87,
                      hintColor: Colors.grey,
                      borderColor: AppColors.white,
                      borderWidth: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: null,
                        checkColor: AppColors.white,
                        fillColor: MaterialStateProperty.all(AppColors.primary),
                        side: const BorderSide(
                          color: AppColors.white,
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
                  Obx(
                    () => CustomButton(
                      text:
                          controller.isLoading.value ? 'MEMPROSES...' : 'MASUK',
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      borderWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
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
