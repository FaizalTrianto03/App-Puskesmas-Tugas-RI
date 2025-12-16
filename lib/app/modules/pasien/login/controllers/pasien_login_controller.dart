import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

class PasienLoginController extends GetxController with GetSingleTickerProviderStateMixin {
  
  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Animation controller
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  
  // Observable states
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final usernameError = Rxn<String>();
  final passwordError = Rxn<String>();
  final isHoverDaftar = false.obs;
  final isPressedDaftar = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize animation
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
    animationController.forward();
    
    // Clear fields
    usernameController.clear();
    passwordController.clear();
    usernameError.value = null;
    passwordError.value = null;
    rememberMe.value = false;
    isPasswordVisible.value = false;
  }
  
  @override
  void onClose() {
    animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }
  
  void setHoverDaftar(bool value) {
    isHoverDaftar.value = value;
  }
  
  void setPressedDaftar(bool value) {
    isPressedDaftar.value = value;
  }
  
  void clearUsernameError() {
    if (usernameError.value != null && usernameController.text.trim().isNotEmpty) {
      usernameError.value = null;
    }
  }
  
  void clearPasswordError() {
    if (passwordError.value != null && passwordController.text.trim().isNotEmpty) {
      passwordError.value = null;
    }
  }
  
  Future<void> login() async {
    // Validasi field harus diisi
    bool isValid = true;
    
    if (usernameController.text.trim().isEmpty) {
      usernameError.value = 'Username atau NIK wajib diisi';
      isValid = false;
    }
    
    if (passwordController.text.trim().isEmpty) {
      passwordError.value = 'Kata sandi wajib diisi';
      isValid = false;
    }
    
    if (!isValid) {
      return;
    }
    
    isLoading.value = true;
    
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    Get.offAllNamed(Routes.pasienDashboard);
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
