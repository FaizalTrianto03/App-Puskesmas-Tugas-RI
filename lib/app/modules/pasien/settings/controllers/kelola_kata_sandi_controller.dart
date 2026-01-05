import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaKataSandiController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionService _sessionService = SessionService();
  
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
        isLoading.value = false;
        return;
      }
      
      if (passwordBaruController.text.length < 6) {
        SnackbarHelper.showError('Password baru minimal 6 karakter');
        isLoading.value = false;
        return;
      }
      
      if (passwordBaruController.text != konfirmasiPasswordController.text) {
        SnackbarHelper.showError('Konfirmasi password tidak cocok');
        isLoading.value = false;
        return;
      }
      
      // Check if new password is same as old password
      if (passwordBaruController.text == passwordLamaController.text) {
        SnackbarHelper.showError('Password baru tidak boleh sama dengan password lama');
        isLoading.value = false;
        return;
      }
      
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        SnackbarHelper.showError('User tidak ditemukan');
        isLoading.value = false;
        return;
      }
      
      // Re-authenticate user with old password
      try {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: passwordLamaController.text,
        );
        
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          SnackbarHelper.showError('Password lama salah');
        } else if (e.code == 'invalid-email') {
          SnackbarHelper.showError('Email tidak valid');
        } else {
          SnackbarHelper.showError('Gagal memverifikasi password lama');
        }
        return;
      }
      
      // Update to new password
      await user.updatePassword(passwordBaruController.text);
      
      // Force reload user to ensure password is updated on server
      await user.reload();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear saved credentials to force re-login with new password
      await _clearSavedCredentials();
      
      // Clear session
      await _sessionService.clearSession();
      
      // Sign out user to force re-login
      await _auth.signOut();
      
      // Show success message before navigating
      SnackbarHelper.showSuccess('Password berhasil diubah. Silakan login kembali dengan password baru.');
      
      // Small delay to show snackbar
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Navigate to login page
      Get.offAllNamed('/pasien-login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        SnackbarHelper.showError('Password terlalu lemah');
      } else if (e.code == 'requires-recent-login') {
        SnackbarHelper.showError('Sesi login sudah kadaluarsa. Silakan login ulang');
      } else {
        SnackbarHelper.showError('Gagal mengubah password');
      }
    } catch (e) {
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
    }
  }
}
