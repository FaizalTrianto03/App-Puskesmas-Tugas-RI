import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaDataDiriController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();
  final emailController = TextEditingController();

  final jenisKelamin = 'L'.obs;
  final tanggalLahir = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    if (userData != null) {
      namaController.text = userData['namaLengkap'] ?? '';
      nikController.text = userData['nik'] ?? '';
      alamatController.text = userData['alamat'] ?? '';
      noHpController.text = userData['noHp'] ?? '';
      emailController.text = userData['email'] ?? '';
      jenisKelamin.value = userData['jenisKelamin'] == 'Laki-laki' ? 'L' : 'P';
      tanggalLahir.value = userData['tanggalLahir'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final updates = {
        'namaLengkap': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'alamat': alamatController.text.trim(),
        'noHp': noHpController.text.trim(),
        'email': emailController.text.trim(),
        'jenisKelamin': jenisKelamin.value == 'L' ? 'Laki-laki' : 'Perempuan',
        'tanggalLahir': tanggalLahir.value,
      };

      final success = await AuthHelper.updateProfile(updates);

      if (success) {
        SnackbarHelper.showSuccess('Data berhasil diperbarui');
        await Future.delayed(const Duration(milliseconds: 600));
        Get.back();
      } else {
        SnackbarHelper.showError('Gagal memperbarui data');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
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
}
