import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/validation_helper.dart';

class KelolaPenggunaController extends GetxController {
  final StorageService _storage = StorageService();
  
  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final selectedRole = 'dokter'.obs;
  final selectedJenisKelamin = 'Laki-laki'.obs;
  final tanggalLahir = Rx<DateTime?>(null);
  
  final userList = <Map<String, dynamic>>[].obs;
  final filteredUserList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedRoleFilter = 'Semua'.obs;
  
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  
  final roles = ['dokter', 'perawat', 'apoteker'];
  final roleFilters = ['Semua', 'Admin', 'Dokter', 'Perawat', 'Apoteker', 'Pasien'];
  final jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // JANGAN dispose controller di sini karena dialog masih menggunakan controller yang sama
  // Controller akan otomatis di-dispose saat navigasi keluar dari halaman
  // @override
  // void onClose() {
  //   namaController.dispose();
  //   nikController.dispose();
  //   emailController.dispose();
  //   noHpController.dispose();
  //   alamatController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.onClose();
  // }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      final users = await _storage.getAllUsers();
      userList.value = users;
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = userList.toList();
    
    // Filter by role
    if (selectedRoleFilter.value != 'Semua') {
      filtered = filtered.where((user) => 
        user['role'].toString().toLowerCase() == selectedRoleFilter.value.toLowerCase()
      ).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((user) =>
        user['namaLengkap'].toString().toLowerCase().contains(query) ||
        user['email'].toString().toLowerCase().contains(query) ||
        user['nik'].toString().toLowerCase().contains(query)
      ).toList();
    }
    
    filteredUserList.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void onRoleFilterChanged(String role) {
    selectedRoleFilter.value = role;
    applyFilters();
  }

  // Validation methods
  String? validateNama(String? value) {
    return ValidationHelper.validateName(value);
  }

  String? validateNIK(String? value, {String? excludeId}) {
    // Basic validation only - will check existence before submit
    return ValidationHelper.validateNIK(value);
  }

  String? validateEmail(String? value, {String? excludeId}) {
    // Basic validation only - will check existence before submit
    return ValidationHelper.validateEmail(value);
  }

  String? validateNoHp(String? value) {
    return ValidationHelper.validatePhoneNumber(value);
  }

  String? validateAlamat(String? value) {
    return ValidationHelper.validateAddress(value);
  }

  String? validatePassword(String? value, {bool isRequired = true}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }
    return ValidationHelper.validatePassword(value);
  }

  String? validateConfirmPassword(String? value, {bool isRequired = true}) {
    if (!isRequired && (value == null || value.isEmpty) && passwordController.text.isEmpty) {
      return null;
    }
    return ValidationHelper.validatePasswordConfirmation(value, passwordController.text);
  }

  // Async validation for email and NIK existence
  Future<bool> validateEmailExists(String email, {String? excludeId}) async {
    return await _storage.isEmailExists(email, excludeId: excludeId);
  }

  Future<bool> validateNIKExists(String nik, {String? excludeId}) async {
    return await _storage.isNIKExists(nik, excludeId: excludeId);
  }

  // CRUD Operations
  Future<void> addUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Check email exists
      final emailExists = await validateEmailExists(emailController.text.trim().toLowerCase());
      if (emailExists) {
        SnackbarHelper.showError('Email sudah terdaftar');
        isLoading.value = false;
        return;
      }

      // Check NIK exists
      final nikExists = await validateNIKExists(nikController.text.trim());
      if (nikExists) {
        SnackbarHelper.showError('NIK sudah terdaftar');
        isLoading.value = false;
        return;
      }

      // Register user using AuthService (creates Firebase Auth + Firestore)
      final userData = await _storage.auth.registerUser(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        namaLengkap: namaController.text.trim(),
        role: selectedRole.value,
        nik: nikController.text.trim(),
        noHp: noHpController.text.trim(),
        jenisKelamin: selectedJenisKelamin.value,
        tanggalLahir: tanggalLahir.value?.toIso8601String().split('T')[0] ?? '',
        alamat: alamatController.text.trim(),
      );

      if (userData != null) {
        await loadUsers();
        SnackbarHelper.showSuccess('Pengguna berhasil ditambahkan');
        
        // Delay sebentar agar snackbar terlihat
        await Future.delayed(const Duration(milliseconds: 600));

        Get.back();
        clearForm();
      } else {
        SnackbarHelper.showError('Gagal menambahkan pengguna');
      }
    } catch (e) {
      SnackbarHelper.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String userId) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Check email exists (excluding current user)
      final emailExists = await validateEmailExists(
        emailController.text.trim().toLowerCase(),
        excludeId: userId,
      );
      if (emailExists) {
        SnackbarHelper.showError('Email sudah terdaftar');
        isLoading.value = false;
        return;
      }

      // Check NIK exists (excluding current user)
      final nikExists = await validateNIKExists(
        nikController.text.trim(),
        excludeId: userId,
      );
      if (nikExists) {
        SnackbarHelper.showError('NIK sudah terdaftar');
        isLoading.value = false;
        return;
      }

      final updates = {
        'namaLengkap': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'noHp': noHpController.text.trim(),
        'jenisKelamin': selectedJenisKelamin.value,
        'tanggalLahir': tanggalLahir.value?.toIso8601String().split('T')[0] ?? '',
        'alamat': alamatController.text.trim(),
        'role': selectedRole.value,
      };

      // Note: Password update for existing users should be done via Firebase Auth
      // and requires re-authentication. For now, we skip password updates in edit.
      // Admin should use "Reset Password" feature for existing users.

      final success = await _storage.updateUser(userId, updates);

      if (success) {
        await loadUsers();

        SnackbarHelper.showSuccess('Data pengguna berhasil diperbarui');
        
        // Delay sebentar agar snackbar terlihat
        await Future.delayed(const Duration(milliseconds: 600));

        Get.back();
        clearForm();
      } else {
        SnackbarHelper.showError('Pengguna tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memperbarui pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId, String nama) async {
    final confirmed = await ConfirmationDialog.show(
      title: 'Hapus Pengguna',
      message: 'Apakah Anda yakin ingin menghapus pengguna "$nama"?\n\nData yang dihapus tidak dapat dikembalikan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      type: ConfirmationType.danger,
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final success = await _storage.deleteUser(userId);

      if (success) {
        await loadUsers();

        SnackbarHelper.showSuccess('Pengguna berhasil dihapus');
      } else {
        SnackbarHelper.showError('Pengguna tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal menghapus pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    namaController.clear();
    nikController.clear();
    emailController.clear();
    noHpController.clear();
    alamatController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = 'dokter';
    selectedJenisKelamin.value = 'Laki-laki';
    tanggalLahir.value = null;
  }

  void populateFormForEdit(Map<String, dynamic> user) {
    namaController.text = user['namaLengkap'] ?? '';
    nikController.text = user['nik'] ?? '';
    emailController.text = user['email'] ?? '';
    noHpController.text = user['noHp'] ?? '';
    alamatController.text = user['alamat'] ?? '';
    selectedRole.value = user['role'] ?? 'dokter';
    selectedJenisKelamin.value = user['jenisKelamin'] ?? 'Laki-laki';
    
    if (user['tanggalLahir'] != null && user['tanggalLahir'].toString().isNotEmpty) {
      try {
        tanggalLahir.value = DateTime.parse(user['tanggalLahir']);
      } catch (e) {
        tanggalLahir.value = null;
      }
    } else {
      tanggalLahir.value = null;
    }
    
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
