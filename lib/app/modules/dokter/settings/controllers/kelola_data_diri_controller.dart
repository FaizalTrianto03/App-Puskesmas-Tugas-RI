import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaDataDiriController extends GetxController {
  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();
  final emailController = TextEditingController();
  
  final jenisKelamin = 'L'.obs;
  final tanggalLahir = Rx<DateTime?>(null);
  final isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final userData = AuthHelper.currentUserData;
    if (userData != null) {
      namaController.text = userData['namaLengkap'] ?? '';
      nikController.text = userData['nik'] ?? '';
      alamatController.text = userData['alamat'] ?? '';
      noHpController.text = userData['noHp'] ?? '';
      emailController.text = userData['email'] ?? '';
      jenisKelamin.value = userData['jenisKelamin'] ?? 'L';
      
      if (userData['tanggalLahir'] != null) {
        tanggalLahir.value = DateTime.parse(userData['tanggalLahir']);
      }
    }
  }

  void saveProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;
        
        SnackbarHelper.showInfo('Menyimpan perubahan data...');
        
        final updates = {
          'namaLengkap': namaController.text.trim(),
          'nik': nikController.text.trim(),
          'alamat': alamatController.text.trim(),
          'noHp': noHpController.text.trim(),
          'email': emailController.text.trim(),
          'jenisKelamin': jenisKelamin.value,
          'tanggalLahir': tanggalLahir.value?.toIso8601String(),
        };

        await AuthHelper.updateProfile(updates);
        
        SnackbarHelper.showSuccess('Data profil berhasil diperbarui');
        
        await Future.delayed(const Duration(milliseconds: 600));
        Get.back();
      } catch (e) {
        SnackbarHelper.showError('Gagal menyimpan data: $e');
      } finally {
        isLoading.value = false;
      }
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
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP harus diisi';
    }
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor HP harus 10-13 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Nomor HP harus berupa angka';
    }
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
