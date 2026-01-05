import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../widgets/custom_date_picker_modal.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/kelola_pengguna_controller.dart';

class TambahPenggunaView extends GetView<KelolaPenggunaController> {
  const TambahPenggunaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEdit = Get.arguments?['isEdit'] ?? false;
    final userId = Get.arguments?['userId'];
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informasi Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF02B1BA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Nama Lengkap
                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.namaController,
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // NIK (16 digit, digits only)
                _buildLabel('NIK'),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.nikError.value.isNotEmpty ? Colors.red : const Color(0xFF02B1BA),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12, right: 8),
                            child: Icon(Icons.badge_outlined, color: Colors.grey, size: 20),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: controller.nikController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Masukkan 16 digit NIK',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                errorStyle: TextStyle(height: 0, fontSize: 0),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                if (value.length != 16) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
                    Obx(() {
                      if (controller.nikError.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            controller.nikError.value,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Email
                _buildLabel('Email'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Masukkan email',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isEdit, // Readonly saat edit
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  backgroundColor: isEdit ? Colors.grey.shade100 : Colors.white,
                  textColor: isEdit ? Colors.black54 : Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: isEdit ? Colors.grey.shade300 : const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // No HP dengan +62 prefix
                _buildLabel('Nomor HP'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF02B1BA), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.phone_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: const Text(
                          '+62',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.noHpController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            if (value.startsWith('0')) {
                              controller.noHpController.text = value.substring(1);
                              controller.noHpController.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.noHpController.text.length),
                              );
                            } else if (value.startsWith('62')) {
                              controller.noHpController.text = value.substring(2);
                              controller.noHpController.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.noHpController.text.length),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: '8123456789',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Alamat
                _buildLabel('Alamat'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.alamatController,
                  hintText: 'Masukkan alamat lengkap',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Row: Jenis Kelamin & Tanggal Lahir
                Row(
                  children: [
                    // Jenis Kelamin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Jenis Kelamin'),
                          const SizedBox(height: 8),
                          Obx(() => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF02B1BA), width: 1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => controller.selectedJenisKelamin.value = 'L',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: controller.selectedJenisKelamin.value == 'L'
                                            ? const Color(0xFF02B1BA)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(11),
                                          bottomLeft: Radius.circular(11),
                                        ),
                                      ),
                                      child: Text(
                                        'L',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedJenisKelamin.value == 'L'
                                              ? Colors.white
                                              : const Color(0xFF02B1BA),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 1, height: 48, color: const Color(0xFF02B1BA)),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => controller.selectedJenisKelamin.value = 'P',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: controller.selectedJenisKelamin.value == 'P'
                                            ? const Color(0xFF02B1BA)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(11),
                                          bottomRight: Radius.circular(11),
                                        ),
                                      ),
                                      child: Text(
                                        'P',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedJenisKelamin.value == 'P'
                                              ? Colors.white
                                              : const Color(0xFF02B1BA),
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
                    // Tanggal Lahir
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tanggal Lahir'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await CustomDatePickerModal.show(
                                context,
                                initialDate: controller.tanggalLahir.value ?? DateTime(2000, 1, 1),
                              );
                              if (picked != null) {
                                controller.tanggalLahir.value = picked;
                              }
                            },
                            child: Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF02B1BA), width: 1),
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
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: controller.tanggalLahir.value == null
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Role Dropdown (completely hide when editing pasien user)
                Obx(() {
                  // Get current user data to check if role is pasien
                  final currentRole = controller.selectedRole.value;
                  final isPasienEdit = isEdit && currentRole == 'pasien';
                  
                  if (isPasienEdit) {
                    // Completely hide role section for pasien
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Role'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF02B1BA), width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedRole.value,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF02B1BA)),
                            items: controller.roles.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(
                                  role[0].toUpperCase() + role.substring(1),
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                // Verify admin password if selecting admin role
                                if (newValue == 'admin') {
                                  final verified = await controller.verifyAdminPassword();
                                  if (!verified) {
                                    // Keep current role if verification failed
                                    return;
                                  }
                                }
                                controller.selectedRole.value = newValue;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
                
                // Password Section (hanya saat tambah baru)
                if (!isEdit) ...[
                  const Text(
                    'Keamanan Akun',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF02B1BA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  Obx(() => CustomTextField(
                    controller: controller.passwordController,
                    hintText: 'Minimal 6 karakter',
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    borderColor: const Color(0xFF02B1BA),
                    borderWidth: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Konfirmasi Password'),
                  const SizedBox(height: 8),
                  Obx(() => CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: 'Ulangi password',
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    borderColor: const Color(0xFF02B1BA),
                    borderWidth: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password harus diisi';
                      }
                      if (value != controller.passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 32),
                ],
                
                // Submit Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller.formKey.currentState!.validate()) {
                              if (isEdit) {
                                controller.updateUser(userId);
                              } else {
                                controller.createUser();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
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
                            isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH PENGGUNA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF02B1BA),
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
