import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/snackbar_helper.dart';

class KelolaKataSandiController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  
  // Form controllers
  late TextEditingController passwordLamaController;
  late TextEditingController passwordBaruController;
  late TextEditingController konfirmasiPasswordController;
  
  // Password visibility
  final showPasswordLama = false.obs;
  final showPasswordBaru = false.obs;
  final showKonfirmasiPassword = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    passwordLamaController = TextEditingController();
    passwordBaruController = TextEditingController();
    konfirmasiPasswordController = TextEditingController();
  }
  
  @override
  void onClose() {
    passwordLamaController.dispose();
    passwordBaruController.dispose();
    konfirmasiPasswordController.dispose();
    super.onClose();
  }
  
  void togglePasswordLamaVisibility() {
    showPasswordLama.value = !showPasswordLama.value;
  }
  
  void togglePasswordBaruVisibility() {
    showPasswordBaru.value = !showPasswordBaru.value;
  }
  
  void toggleKonfirmasiPasswordVisibility() {
    showKonfirmasiPassword.value = !showKonfirmasiPassword.value;
  }
  
  Future<void> updatePassword() async {
    try {
      isLoading.value = true;
      
      // Validation
      if (passwordLamaController.text.isEmpty || 
          passwordBaruController.text.isEmpty || 
          konfirmasiPasswordController.text.isEmpty) {
        SnackbarHelper.showError('Semua field harus diisi');
        return;
      }
      
      if (passwordBaruController.text.length < 6) {
        SnackbarHelper.showError('Password baru minimal 6 karakter');
        return;
      }
      
      if (passwordBaruController.text != konfirmasiPasswordController.text) {
        SnackbarHelper.showError('Konfirmasi password tidak cocok');
        return;
      }
      
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        SnackbarHelper.showError('User tidak ditemukan');
        return;
      }
      
      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordLamaController.text,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update to new password
      await user.updatePassword(passwordBaruController.text);
      
      SnackbarHelper.showSuccess('Password berhasil diubah');
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        SnackbarHelper.showError('Password lama salah');
      } else if (e.code == 'weak-password') {
        SnackbarHelper.showError('Password terlalu lemah');
      } else {
        SnackbarHelper.showError('Gagal mengubah password: ${e.message}');
      }
    } catch (e) {
      print('Error updating password: $e');
      SnackbarHelper.showError('Gagal mengubah password');
    } finally {
      isLoading.value = false;
    }
  }
}
