import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasienRegisterController extends GetxController {
  final namaLengkapController = TextEditingController();
  final nikController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final kataSandiController = TextEditingController();
  final konfirmasiKataSandiController = TextEditingController();

  var jenisKelamin = ''.obs;
  var isPasswordVisible = false.obs;
  var isKonfirmasiPasswordVisible = false.obs;

  @override
  void onClose() {
    namaLengkapController.dispose();
    nikController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    tanggalLahirController.dispose();
    kataSandiController.dispose();
    konfirmasiKataSandiController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleKonfirmasiPasswordVisibility() {
    isKonfirmasiPasswordVisible.value = !isKonfirmasiPasswordVisible.value;
  }

  void setJenisKelamin(String value) {
    jenisKelamin.value = value;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF02B1BA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      tanggalLahirController.text = 
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void register() {
    // Validasi sederhana
    if (namaLengkapController.text.isEmpty ||
        nikController.text.isEmpty ||
        alamatController.text.isEmpty ||
        noHpController.text.isEmpty ||
        jenisKelamin.value.isEmpty ||
        tanggalLahirController.text.isEmpty ||
        kataSandiController.text.isEmpty ||
        konfirmasiKataSandiController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (kataSandiController.text != konfirmasiKataSandiController.text) {
      Get.snackbar(
        'Error',
        'Kata sandi dan konfirmasi kata sandi tidak cocok',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Simulasi registrasi berhasil
    Get.snackbar(
      'Berhasil',
      'Pendaftaran berhasil! Silakan login',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
    
    // Kembali ke halaman login
    Get.back();
  }
}
