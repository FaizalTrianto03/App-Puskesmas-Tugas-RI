import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaKataSandiController extends GetxController {
  final passwordLamaController = TextEditingController();
  final passwordBaruController = TextEditingController();
  final konfirmasiController = TextEditingController();

  final obscurePasswordLama = true.obs;
  final obscurePasswordBaru = true.obs;
  final obscureKonfirmasi = true.obs;
  final isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  void togglePasswordLama() {
    obscurePasswordLama.value = !obscurePasswordLama.value;
  }

  void togglePasswordBaru() {
    obscurePasswordBaru.value = !obscurePasswordBaru.value;
  }

  void toggleKonfirmasi() {
    obscureKonfirmasi.value = !obscureKonfirmasi.value;
  }

  String? validatePasswordLama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi lama harus diisi';
    }
    return null;
  }

  String? validatePasswordBaru(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi baru harus diisi';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }

  String? validateKonfirmasi(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi harus diisi';
    }
    if (value != passwordBaruController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  void changePassword() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        final oldPassword = passwordLamaController.text;
        final newPassword = passwordBaruController.text;

        final result = await AuthHelper.changePassword(oldPassword, newPassword);

        if (result) {
          SnackbarHelper.showSuccess('Kata sandi berhasil diubah');
          await Future.delayed(const Duration(milliseconds: 600));
          Get.back();
        } else {
          SnackbarHelper.showError('Kata sandi lama tidak sesuai');
        }
      } catch (e) {
        SnackbarHelper.showError('Gagal mengubah kata sandi: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
