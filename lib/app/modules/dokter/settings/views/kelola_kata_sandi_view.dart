import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../controllers/kelola_kata_sandi_controller.dart';

class KelolaKataSandiView extends GetView<KelolaKataSandiController> {
  const KelolaKataSandiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah di-inject
    Get.lazyPut(() => KelolaKataSandiController());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kelola Kata Sandi',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Kata sandi minimal 8 karakter untuk keamanan akun Anda',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Ubah Kata Sandi',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Kata Sandi Lama
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Kata Sandi Lama'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => CustomTextField(
                        controller: controller.passwordLamaController,
                        hintText: 'Masukkan kata sandi lama',
                        obscureText: controller.obscurePasswordLama.value,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePasswordLama.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.togglePasswordLama,
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: controller.validatePasswordLama,
                      )),
                      const SizedBox(height: 16),
                      
                      // Kata Sandi Baru
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
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
                      const SizedBox(height: 8),
                      Obx(() => CustomTextField(
                        controller: controller.passwordBaruController,
                        hintText: 'Masukkan kata sandi baru',
                        obscureText: controller.obscurePasswordBaru.value,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePasswordBaru.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.togglePasswordBaru,
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: controller.validatePasswordBaru,
                      )),
                      const SizedBox(height: 16),
                      
                      // Konfirmasi Kata Sandi
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Konfirmasi Kata Sandi'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => CustomTextField(
                        controller: controller.konfirmasiController,
                        hintText: 'Ulangi kata sandi baru',
                        obscureText: controller.obscureKonfirmasi.value,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureKonfirmasi.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.toggleKonfirmasi,
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: controller.validateKonfirmasi,
                      )),
                      
                      const SizedBox(height: 32),
                      
                      // Button Simpan
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'SIMPAN PERUBAHAN',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                        )),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
