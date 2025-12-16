import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/validation_helper.dart';
import '../../../../routes/app_pages.dart';

class AdminLoginController extends GetxController {
  final StorageService _storage = StorageService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxString selectedRole = 'admin'.obs;
  
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _checkAutoLogin();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check for saved credentials and auto-login
  Future<void> _checkAutoLogin() async {
    try {
      final savedCredentials = await _storage.auth.getSavedCredentials();
      if (savedCredentials != null) {
        // Only auto-login if role matches
        if (savedCredentials['role'] == selectedRole.value) {
          emailController.text = savedCredentials['email']!;
          passwordController.text = savedCredentials['password']!;
          rememberMe.value = true;
          
          // Auto-login
          await login();
        }
      }
    } catch (e) {
      print('Auto-login error: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  String? validateEmail(String? value) {
    return ValidationHelper.validateEmail(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi harus diisi';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Login using AuthService
      final userData = await _storage.auth.login(
        email: email,
        password: password,
        role: selectedRole.value,
        rememberMe: rememberMe.value,
      );

      if (userData != null) {
        SnackbarHelper.showSuccess('Selamat datang, ${userData['namaLengkap']}!');

        // Clear fields
        emailController.clear();
        passwordController.clear();

        // Navigate to dashboard based on role
        await Future.delayed(const Duration(milliseconds: 500));
        
        switch (selectedRole.value) {
          case 'admin':
            Get.offAllNamed(Routes.adminDashboard);
            break;
          case 'dokter':
            Get.offAllNamed(Routes.dokterDashboard);
            break;
          case 'perawat':
            Get.offAllNamed(Routes.perawatDashboard);
            break;
          case 'apoteker':
            Get.offAllNamed(Routes.apotekerDashboard);
            break;
        }
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      SnackbarHelper.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
