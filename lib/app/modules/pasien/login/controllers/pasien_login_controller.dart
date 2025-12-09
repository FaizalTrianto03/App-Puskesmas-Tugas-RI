import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class PasienLoginController extends GetxController {
  final StorageService _storageService = StorageService();
  final SessionService _sessionService = Get.find<SessionService>();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Observable states
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Validasi Email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    
    // Validasi format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    // Validasi Gmail untuk pasien
    final gmailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
    if (!gmailRegex.hasMatch(value)) {
      return 'Email harus menggunakan Gmail (@gmail.com)';
    }
    
    return null;
  }
  
  // Validasi Password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi harus diisi';
    }
    
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    
    return null;
  }
  
  // Login Function
  Future<void> login() async {
    // Validasi input
    final emailError = validateEmail(emailController.text.trim());
    final passwordError = validatePassword(passwordController.text);
    
    if (emailError != null) {
      SnackbarHelper.showError(emailError);
      return;
    }
    
    if (passwordError != null) {
      SnackbarHelper.showError(passwordError);
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Cari user di database dummy
      final user = _storageService.findUserByEmail(emailController.text.trim());
      
      if (user == null) {
        SnackbarHelper.showError('Email tidak terdaftar');
        isLoading.value = false;
        return;
      }
      
      // Validasi password
      if (user['password'] != passwordController.text) {
        SnackbarHelper.showError('Kata sandi salah');
        isLoading.value = false;
        return;
      }
      
      // Validasi role
      if (user['role'] != 'pasien') {
        SnackbarHelper.showError('Akun ini bukan akun pasien');
        isLoading.value = false;
        return;
      }
      
      // Simpan session
      await _sessionService.saveUserSession(
        userId: user['id'],
        namaLengkap: user['namaLengkap'],
        email: user['email'],
        role: user['role'],
      );
      
      // Simpan data user lengkap
      await _sessionService.saveUserData(user['id'], user);
      
      // Tunggu sebentar untuk memastikan session tersimpan
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verifikasi session tersimpan
      print('=== PASIEN LOGIN DEBUG ===');
      print('User role dari DB: ${user['role']}');
      print('Session saved - Is logged in: ${_sessionService.isLoggedIn()}');
      print('Session saved - Role: ${_sessionService.getRole()}');
      print('Session saved - UserId: ${_sessionService.getUserId()}');
      print('==========================');
      
      // Clear form
      emailController.clear();
      passwordController.clear();
      
      isLoading.value = false;
      
      // Tampilkan pesan sukses
      SnackbarHelper.showSuccess(
        'Selamat datang, ${user['namaLengkap']}!',
      );
      
      // Navigate to dashboard - gunakan delay kecil untuk memastikan session tersimpan
      await Future.delayed(const Duration(milliseconds: 50));
      Get.offAllNamed(Routes.pasienDashboard);
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Terjadi kesalahan: $e');
    }
  }
  
  // Navigate to Register
  void goToRegister() {
    Get.toNamed(Routes.pasienRegister);
  }
  
  // Navigate to Lupa Kata Sandi
  void goToLupaKataSandi() {
    Get.toNamed(Routes.lupaKataSandi);
  }
}
