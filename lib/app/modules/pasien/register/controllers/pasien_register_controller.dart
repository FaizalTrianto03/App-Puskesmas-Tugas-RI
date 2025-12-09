import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class PasienRegisterController extends GetxController {
  final StorageService _storageService = StorageService();
  final SessionService _sessionService = Get.find<SessionService>();
  
  // Form controllers
  final namaLengkapController = TextEditingController();
  final nikController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiPasswordController = TextEditingController();
  
  // Observable states
  final selectedJenisKelamin = Rxn<String>();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isKonfirmasiPasswordVisible = false.obs;
  final jenisKelaminError = Rxn<String>();
  
  @override
  void onClose() {
    namaLengkapController.dispose();
    nikController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    konfirmasiPasswordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  void toggleKonfirmasiPasswordVisibility() {
    isKonfirmasiPasswordVisible.value = !isKonfirmasiPasswordVisible.value;
  }
  
  void selectJenisKelamin(String jenisKelamin) {
    selectedJenisKelamin.value = jenisKelamin;
    jenisKelaminError.value = null;
  }
  
  // Validasi Nama Lengkap
  String? validateNamaLengkap(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (value.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null;
  }
  
  // Validasi NIK
  String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK harus diisi';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'NIK hanya boleh angka';
    }
    return null;
  }
  
  // Validasi Tanggal Lahir
  String? validateTanggalLahir(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal lahir harus diisi';
    }
    return null;
  }
  
  // Validasi Tempat Lahir
  String? validateTempatLahir(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tempat lahir harus diisi';
    }
    return null;
  }
  
  // Validasi Alamat
  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat harus diisi';
    }
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }
  
  // Validasi No HP
  String? validateNoHp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP harus diisi';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor HP tidak valid (10-13 digit)';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Nomor HP hanya boleh angka';
    }
    return null;
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
  
  // Validasi Konfirmasi Password
  String? validateKonfirmasiPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi harus diisi';
    }
    if (value != passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }
  
  // Validasi Jenis Kelamin
  bool validateJenisKelaminField() {
    if (selectedJenisKelamin.value == null) {
      jenisKelaminError.value = 'Pilih jenis kelamin';
      return false;
    }
    jenisKelaminError.value = null;
    return true;
  }
  
  // Register Function
  Future<void> register() async {
    // Validasi semua field
    final namaError = validateNamaLengkap(namaLengkapController.text.trim());
    final nikError = validateNIK(nikController.text.trim());
    final tempatLahirError = validateTempatLahir(tempatLahirController.text.trim());
    final tanggalLahirError = validateTanggalLahir(tanggalLahirController.text.trim());
    final alamatError = validateAlamat(alamatController.text.trim());
    final noHpError = validateNoHp(noHpController.text.trim());
    final emailError = validateEmail(emailController.text.trim());
    final passwordError = validatePassword(passwordController.text);
    final konfirmasiPasswordError = validateKonfirmasiPassword(konfirmasiPasswordController.text);
    final jenisKelaminValid = validateJenisKelaminField();
    
    // Cek jika ada error - error sudah ditampilkan di field
    if (namaError != null || nikError != null || tempatLahirError != null || 
        tanggalLahirError != null || !jenisKelaminValid || alamatError != null || 
        noHpError != null || emailError != null || passwordError != null || 
        konfirmasiPasswordError != null) {
      // Show general error message for clarity
      SnackbarHelper.showError('Silakan isi semua field sesuai ketentuan');
      return; // Validasi gagal, error sudah muncul di field
    }
    
    try {
      isLoading.value = true;
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Cek apakah email sudah terdaftar
      final existingUser = _storageService.findUserByEmail(emailController.text.trim());
      if (existingUser != null) {
        SnackbarHelper.showError('Email sudah terdaftar');
        isLoading.value = false;
        return;
      }
      
      // Generate user ID
      final allUsers = _storageService.getAllUsers();
      final newId = 'P${(allUsers.length + 1).toString().padLeft(3, '0')}';
      
      // Generate No Rekam Medis
      final noRekamMedis = 'RM${(allUsers.length + 1).toString().padLeft(3, '0')}';
      
      // Buat user baru
      final newUser = {
        'id': newId,
        'namaLengkap': namaLengkapController.text.trim(),
        'nik': nikController.text.trim(),
        'tempatLahir': tempatLahirController.text.trim(),
        'tanggalLahir': tanggalLahirController.text.trim(),
        'jenisKelamin': selectedJenisKelamin.value,
        'alamat': alamatController.text.trim(),
        'noHp': noHpController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'role': 'pasien',
        'noRekamMedis': noRekamMedis,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Simpan ke database
      await _storageService.addUser(newUser);
      
      // Simpan session langsung
      await _sessionService.saveUserSession(
        userId: newId,
        namaLengkap: namaLengkapController.text.trim(),
        email: emailController.text.trim(),
        role: 'pasien',
      );
      
      // Simpan data user lengkap
      await _sessionService.saveUserData(newId, newUser);
      
      isLoading.value = false;
      
      // Clear form
      _clearForm();
      
      // Navigate to dashboard (langsung login)
      Get.offAllNamed(Routes.pasienDashboard);
      
      SnackbarHelper.showSuccess(
        'Pendaftaran berhasil! Selamat datang di Puskesmas Dau.',
      );
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Terjadi kesalahan: $e');
    }
  }
  
  void _clearForm() {
    namaLengkapController.clear();
    nikController.clear();
    tempatLahirController.clear();
    tanggalLahirController.clear();
    alamatController.clear();
    noHpController.clear();
    emailController.clear();
    passwordController.clear();
    konfirmasiPasswordController.clear();
    selectedJenisKelamin.value = null;
    jenisKelaminError.value = null;
  }
  
  // Navigate back to login
  void backToLogin() {
    Get.back();
  }
}
