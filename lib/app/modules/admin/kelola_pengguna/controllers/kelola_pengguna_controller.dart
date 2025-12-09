import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';

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
      final users = _storage.getAllUsers();
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
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateNIK(String? value, {String? excludeId}) {
    if (value == null || value.isEmpty) {
      return 'NIK tidak boleh kosong';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return 'NIK harus berupa angka';
    }
    if (_storage.isNIKExists(value, excludeId: excludeId)) {
      return 'NIK sudah terdaftar';
    }
    return null;
  }

  String? validateEmail(String? value, {String? excludeId}) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    if (_storage.isEmailExists(value, excludeId: excludeId)) {
      return 'Email sudah terdaftar';
    }
    return null;
  }

  String? validateNoHp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return 'Nomor HP harus berupa angka';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor HP tidak valid (10-13 digit)';
    }
    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }

  String? validatePassword(String? value, {bool isRequired = true}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }
    if (isRequired && (value == null || value.isEmpty)) {
      return 'Password tidak boleh kosong';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, {bool isRequired = true}) {
    if (!isRequired && (value == null || value.isEmpty) && passwordController.text.isEmpty) {
      return null;
    }
    if (value != passwordController.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  // CRUD Operations
  Future<void> addUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final userId = _storage.generateUserId(selectedRole.value);
      final newUser = {
        'id': userId,
        'namaLengkap': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'noHp': noHpController.text.trim(),
        'jenisKelamin': selectedJenisKelamin.value,
        'tanggalLahir': tanggalLahir.value?.toIso8601String().split('T')[0] ?? '',
        'alamat': alamatController.text.trim(),
        'password': passwordController.text,
        'role': selectedRole.value,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _storage.addUser(newUser);
      await loadUsers();

      SnackbarHelper.showSuccess('Pengguna berhasil ditambahkan');
      
      // Delay sebentar agar snackbar terlihat
      await Future.delayed(const Duration(milliseconds: 600));

      Get.back();
      clearForm();
    } catch (e) {
      SnackbarHelper.showError('Gagal menambahkan pengguna: ${e.toString()}');
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

      // Update password only if filled
      if (passwordController.text.isNotEmpty) {
        updates['password'] = passwordController.text;
      }

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
