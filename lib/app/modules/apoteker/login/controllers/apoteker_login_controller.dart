import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/validation_helper.dart';
import '../../../../routes/app_pages.dart';

class ApotekerLoginController extends GetxController {
  final StorageService _storage = StorageService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  
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

  Future<void> _checkAutoLogin() async {
    try {
      final savedCredentials = await _storage.auth.getSavedCredentials();
      if (savedCredentials != null && savedCredentials['role'] == 'apoteker') {
        emailController.text = savedCredentials['email']!;
        passwordController.text = savedCredentials['password']!;
        rememberMe.value = true;
        await login();
      }
    } catch (e) {
      print('Auto-login error: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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

      final userData = await _storage.auth.login(
        email: email,
        password: password,
        role: 'apoteker',
        rememberMe: rememberMe.value,
      );

      if (userData != null) {
        SnackbarHelper.showSuccess('Selamat datang, ${userData['namaLengkap']}!');
        emailController.clear();
        passwordController.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.apotekerDashboard);
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      SnackbarHelper.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
