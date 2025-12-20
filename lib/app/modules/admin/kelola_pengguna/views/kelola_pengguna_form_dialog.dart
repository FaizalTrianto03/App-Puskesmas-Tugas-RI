import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/kelola_pengguna_controller.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../widgets/custom_text_field.dart';

class KelolaPenggunaFormDialog extends StatelessWidget {
  final String? userId;
  final String title;

  const KelolaPenggunaFormDialog({
    Key? key,
    this.userId,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KelolaPenggunaController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap
                      _buildLabel('Nama Lengkap'),
                      CustomTextField(
                        controller: controller.namaController,
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: controller.validateNama,
                      ),
                      const SizedBox(height: 16),

                      // NIK
                      _buildLabel('NIK'),
                      CustomTextField(
                        controller: controller.nikController,
                        hintText: 'Masukkan NIK (16 digit)',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        keyboardType: TextInputType.number,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: (value) => controller.validateNIK(value, excludeId: userId),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildLabel('Email'),
                      CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: (value) => controller.validateEmail(value, excludeId: userId),
                      ),
                      const SizedBox(height: 16),

                      // No HP
                      _buildLabel('Nomor HP'),
                      CustomTextField(
                        controller: controller.noHpController,
                        hintText: 'Masukkan nomor HP',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: controller.validateNoHp,
                      ),
                      const SizedBox(height: 16),

                      // Role
                      _buildLabel('Role'),
                      Obx(() => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedRole.value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          items: controller.roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role[0].toUpperCase() + role.substring(1)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedRole.value = value;
                            }
                          },
                        ),
                      )),
                      const SizedBox(height: 16),

                      // Jenis Kelamin
                      _buildLabel('Jenis Kelamin'),
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => controller.selectedJenisKelamin.value = 'Laki-laki',
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: controller.selectedJenisKelamin.value == 'Laki-laki'
                                      ? AppColors.primary
                                      : Colors.white,
                                  border: Border.all(
                                    color: controller.selectedJenisKelamin.value == 'Laki-laki'
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: controller.selectedJenisKelamin.value == 'Laki-laki'
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Laki-laki',
                                      style: TextStyle(
                                        color: controller.selectedJenisKelamin.value == 'Laki-laki'
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => controller.selectedJenisKelamin.value = 'Perempuan',
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: controller.selectedJenisKelamin.value == 'Perempuan'
                                      ? AppColors.primary
                                      : Colors.white,
                                  border: Border.all(
                                    color: controller.selectedJenisKelamin.value == 'Perempuan'
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: controller.selectedJenisKelamin.value == 'Perempuan'
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Perempuan',
                                      style: TextStyle(
                                        color: controller.selectedJenisKelamin.value == 'Perempuan'
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 16),

                      // Tanggal Lahir
                      _buildLabel('Tanggal Lahir'),
                      Obx(() => InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.tanggalLahir.value ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.tanggalLahir.value = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                controller.tanggalLahir.value == null
                                    ? 'Pilih tanggal lahir'
                                    : DateFormat('dd/MM/yyyy').format(controller.tanggalLahir.value!),
                                style: TextStyle(
                                  color: controller.tanggalLahir.value == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),

                      // Alamat
                      _buildLabel('Alamat'),
                      CustomTextField(
                        controller: controller.alamatController,
                        hintText: 'Masukkan alamat lengkap',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        maxLines: 3,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: controller.validateAlamat,
                      ),
                      const SizedBox(height: 16),

                      // Password (required untuk add, optional untuk edit)
                      _buildLabel(userId == null ? 'Password' : 'Password (Kosongkan jika tidak diubah)'),
                      Obx(() => CustomTextField(
                        controller: controller.passwordController,
                        hintText: userId == null ? 'Masukkan password' : 'Masukkan password baru',
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: (value) => controller.validatePassword(value, isRequired: userId == null),
                      )),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildLabel('Konfirmasi Password'),
                      Obx(() => CustomTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'Ulangi password',
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey.shade600,
                        validator: (value) => controller.validateConfirmPassword(value, isRequired: userId == null),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (userId == null) {
                                controller.addUser();
                              } else {
                                controller.updateUser(userId!);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              userId == null ? 'Tambah' : 'Simpan',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
