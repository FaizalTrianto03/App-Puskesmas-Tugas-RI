import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaDataDiriController extends GetxController {
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  final isLoading = false.obs;
  
  // Form controllers
  late TextEditingController namaController;
  late TextEditingController nikController;
  late TextEditingController alamatController;
  late TextEditingController noHpController;
  late TextEditingController emailController;
  
  final jenisKelamin = 'P'.obs;
  final tanggalLahir = '09/09/2003'.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    namaController = TextEditingController();
    nikController = TextEditingController();
    alamatController = TextEditingController();
    noHpController = TextEditingController();
    emailController = TextEditingController();
    
    loadUserData();
  }

  @override
  void onClose() {
    namaController.dispose();
    nikController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final profile = await _profileService.getUserProfile();
      
      if (profile != null) {
        namaController.text = profile.namaLengkap;
        nikController.text = profile.nik ?? '';
        alamatController.text = profile.alamat ?? '';
        
        // Format nomor HP: hilangkan +62 prefix untuk ditampilkan di field
        String phoneNumber = profile.noHp ?? '';
        if (phoneNumber.startsWith('+62')) {
          phoneNumber = phoneNumber.substring(3);
        } else if (phoneNumber.startsWith('62')) {
          phoneNumber = phoneNumber.substring(2);
        } else if (phoneNumber.startsWith('0')) {
          phoneNumber = phoneNumber.substring(1);
        }
        noHpController.text = phoneNumber;
        
        emailController.text = profile.email;
        
        // Set jenis kelamin - map dari database format
        if (profile.jenisKelamin != null && profile.jenisKelamin!.isNotEmpty) {
          // Support both "Laki-laki"/"Perempuan" and "L"/"P"
          if (profile.jenisKelamin == 'Laki-laki' || profile.jenisKelamin == 'L') {
            jenisKelamin.value = 'L';
          } else if (profile.jenisKelamin == 'Perempuan' || profile.jenisKelamin == 'P') {
            jenisKelamin.value = 'P';
          } else {
            jenisKelamin.value = profile.jenisKelamin!;
          }
        }
        
        // Parse tanggal lahir dari format ISO (yyyy-MM-dd) ke dd/MM/yyyy
        if (profile.tanggalLahir != null && profile.tanggalLahir!.isNotEmpty) {
          try {
            final dateStr = profile.tanggalLahir!;
            if (dateStr.contains('-')) {
              // Check if ISO format (yyyy-MM-dd)
              final parts = dateStr.split('-');
              if (parts.length == 3 && parts[0].length == 4) {
                // ISO format: yyyy-MM-dd -> convert to dd/MM/yyyy
                final date = DateTime.parse(dateStr);
                tanggalLahir.value = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              } else {
                // Already in dd-MM-yyyy or dd/MM/yyyy format
                tanggalLahir.value = dateStr.replaceAll('-', '/');
              }
            } else if (dateStr.contains('/')) {
              // Already in dd/MM/yyyy format
              tanggalLahir.value = dateStr;
            } else {
              tanggalLahir.value = dateStr;
            }
          } catch (e) {
            // Keep default if parsing fails
          }
        }
      }
    } catch (e) {
      // Silent error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDataDiri() async {
    try {
      isLoading.value = true;
      
      // Format nomor HP dengan +62 prefix sebelum save
      String phoneNumber = noHpController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+62')) {
        phoneNumber = '+62$phoneNumber';
      }
      
      // Convert tanggal lahir from dd/MM/yyyy to ISO format yyyy-MM-dd
      String tanggalLahirISO = tanggalLahir.value;
      try {
        final parts = tanggalLahir.value.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          tanggalLahirISO = '$year-$month-$day';
        }
      } catch (e) {
        // Keep original if conversion fails
      }
      
      // Map jenis kelamin to full format for consistency
      String jenisKelaminFull = jenisKelamin.value;
      if (jenisKelamin.value == 'L') {
        jenisKelaminFull = 'Laki-laki';
      } else if (jenisKelamin.value == 'P') {
        jenisKelaminFull = 'Perempuan';
      }
      
      await _profileService.updateDataDiri(
        namaLengkap: namaController.text.trim(),
        nik: nikController.text.trim(),
        noHp: phoneNumber,
        alamat: alamatController.text.trim(),
        jenisKelamin: jenisKelaminFull,
        tanggalLahir: tanggalLahirISO,
      );
      
      // Kembali dulu dengan result true
      Get.back(result: true);
      
      // Delay singkat baru tampilkan snackbar di halaman tujuan
      await Future.delayed(const Duration(milliseconds: 200));
      SnackbarHelper.showSuccess('Data berhasil diperbarui');
    } catch (e) {
      SnackbarHelper.showError('Gagal memperbarui data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateNIK(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIK harus diisi';
    }
    if (value.trim().length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'NIK harus berupa angka';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validateNoHp(String? value) {
    // Validation sudah sesuai dengan format +62 prefix di controller
    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat harus diisi';
    }
    if (value.trim().length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }
}
