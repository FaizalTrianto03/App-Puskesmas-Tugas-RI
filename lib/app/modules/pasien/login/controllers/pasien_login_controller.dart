import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../routes/app_pages.dart';

class PasienLoginController extends GetxController with GetSingleTickerProviderStateMixin {
  
  final StorageService _storage = StorageService();
  
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
    
    // Clear fields on init
    usernameController.clear();
    passwordController.clear();
    usernameError.value = null;
    passwordError.value = null;
    rememberMe.value = false;
    isPasswordVisible.value = false;
    
    // Check for auto-login ONLY if credentials are saved
    _checkAutoLogin();
  }
  
  @override
  void onClose() {
    animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  Future<void> _checkAutoLogin() async {
    try {
      final savedCredentials = await _storage.auth.getSavedCredentials();
      
      // Only auto-login if:
      // 1. Credentials exist
      // 2. Role matches 'pasien'
      if (savedCredentials != null && savedCredentials['role'] == 'pasien') {
        print('Auto-login: Credentials found for pasien');
        usernameController.text = savedCredentials['email']!;
        passwordController.text = savedCredentials['password']!;
        rememberMe.value = true;
        
        // Auto login
        await login();
      } else {
        print('Auto-login: No saved credentials or wrong role');
      }
    } catch (e) {
      print('Auto-login error: $e');
      // Clear invalid credentials
      await _storage.auth.clearSavedCredentials();
    }
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
    // Clear previous errors
    usernameError.value = null;
    passwordError.value = null;
    
    // Validasi field harus diisi
    bool isValid = true;
    
    if (usernameController.text.trim().isEmpty) {
      usernameError.value = 'Email wajib diisi';
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
    
    try {
      final email = usernameController.text.trim();
      final password = passwordController.text;
      
      // Login using AuthService
      final userData = await _storage.auth.login(
        email: email,
        password: password,
        role: 'pasien',
        rememberMe: rememberMe.value,
      );
      
      if (userData != null) {
        SnackbarHelper.showSuccess('Selamat datang, ${userData['namaLengkap']}!');
        usernameController.clear();
        passwordController.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.pasienDashboard);
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      SnackbarHelper.showError(errorMessage);
    } finally {
      isLoading.value = false;
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
