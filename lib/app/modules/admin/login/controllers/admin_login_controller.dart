import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../routes/app_pages.dart';

class AdminLoginController extends GetxController {
  final StorageService _storage = StorageService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'admin'.obs;
  
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initDummyData();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _initDummyData() async {
    await _storage.initDummyUsers();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi harus diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final email = emailController.text.trim();
      final password = passwordController.text;

      // Find user by email
      final user = _storage.findUserByEmail(email);

      if (user == null) {
        SnackbarHelper.showError('Email tidak terdaftar');
        isLoading.value = false;
        return;
      }

      // Check if role matches
      if (user['role'] != selectedRole.value) {
        SnackbarHelper.showError('Role tidak sesuai. Anda terdaftar sebagai ${user['role']}');
        isLoading.value = false;
        return;
      }

      // Validate password
      if (user['password'] != password) {
        SnackbarHelper.showError('Password salah');
        isLoading.value = false;
        return;
      }

      // Save session
      await _storage.saveUserSession(
        userId: user['id'],
        namaLengkap: user['namaLengkap'],
        email: user['email'],
        role: user['role'],
      );

      SnackbarHelper.showSuccess('Selamat datang, ${user['namaLengkap']}!');

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
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

