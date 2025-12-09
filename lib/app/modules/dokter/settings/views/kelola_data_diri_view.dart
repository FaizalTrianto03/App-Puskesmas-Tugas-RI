import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../utils/snackbar_helper.dart';
import '../controllers/kelola_data_diri_controller.dart';

class KelolaDataDiriView extends GetView<KelolaDataDiriController> {
  const KelolaDataDiriView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.delete<KelolaDataDiriController>();
    final controller = Get.put(KelolaDataDiriController());
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
          'Kelola Data Diri',
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
                      Text(
                        'Informasi Pribadi',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Nama Lengkap
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Nama Lengkap'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.namaController,
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // NIK
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'NIK'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.nikController,
                        hintText: 'Masukkan 16 digit NIK',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIK harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Alamat
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Alamat'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.alamatController,
                        hintText: 'Masukkan alamat lengkap',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Nomor HP
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Nomor HP'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.noHpController,
                        hintText: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor HP harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
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
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Jenis Kelamin & Tanggal Lahir
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Jenis Kelamin'),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: AppColors.accent),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.jenisKelamin.value = 'L';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: controller.jenisKelamin.value == 'L'
                                                  ? AppColors.primary
                                                  : AppColors.white,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(11),
                                                bottomLeft: Radius.circular(11),
                                              ),
                                            ),
                                            child: Text(
                                              'L',
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              color: controller.jenisKelamin.value == 'L'
                                                  ? AppColors.white
                                                  : AppColors.primary,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 48,
                                        color: AppColors.primary,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.jenisKelamin.value = 'P';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: controller.jenisKelamin.value == 'P'
                                                  ? AppColors.primary
                                                  : AppColors.white,
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(11),
                                                bottomRight: Radius.circular(11),
                                              ),
                                            ),
                                            child: Text(
                                              'P',
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: controller.jenisKelamin.value == 'P'
                                                  ? AppColors.white
                                                  : AppColors.primary,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Tanggal Lahir'),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: AppColors.accent),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2003, 7, 9),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: AppColors.primary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      controller.tanggalLahir.value = picked;
                                    }
                                  },
                                  child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.tanggalLahir.value == null 
                                                ? 'dd/mm/yyyy' 
                                                : '${controller.tanggalLahir.value!.day.toString().padLeft(2, '0')}/${controller.tanggalLahir.value!.month.toString().padLeft(2, '0')}/${controller.tanggalLahir.value!.year}',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: controller.tanggalLahir.value == null ? Colors.grey : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
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
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Button Simpan
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () {
                            if (controller.formKey.currentState!.validate()) {
                              // Tampilkan info snackbar saat mulai menyimpan
                              SnackbarHelper.showInfo('Menyimpan perubahan...');
                              controller.saveProfile();
                            }
                          },
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
