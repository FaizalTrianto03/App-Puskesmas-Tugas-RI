import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
      
      // Check if new password is same as old password
      if (passwordBaruController.text == passwordLamaController.text) {
        SnackbarHelper.showError('Password baru tidak boleh sama dengan password lama');
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
      
      // Clear saved credentials to force re-login with new password
      await _clearSavedCredentials();
      
      SnackbarHelper.showSuccess('Password berhasil diubah. Silakan login kembali dengan password baru.');
      
      // Sign out user to force re-login
      await _auth.signOut();
      
      // Navigate to login page
      Get.offAllNamed('/pasien-login');
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
  
  Future<void> _clearSavedCredentials() async {
    try {
      final box = GetStorage('credentials_box');
      await box.remove('savedEmail');
      await box.remove('savedPassword');
      await box.remove('savedRole');
      await box.remove('rememberMe');
    } catch (e) {
      print('Error clearing saved credentials: $e');
    }
  }
}
