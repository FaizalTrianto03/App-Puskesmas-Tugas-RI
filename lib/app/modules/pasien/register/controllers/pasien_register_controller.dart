import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/notification/fcm_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/validation_helper.dart';

class PasienRegisterController extends GetxController {
  final StorageService _storage = StorageService();

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
    return ValidationHelper.validateName(value);
  }

  // Validasi NIK
  String? validateNIK(String? value) {
    return ValidationHelper.validateNIK(value);
  }

  // Validasi Tanggal Lahir
  String? validateTanggalLahir(String? value) {
    return ValidationHelper.validateRequired(value, 'Tanggal lahir');
  }

  // Validasi Tempat Lahir
  String? validateTempatLahir(String? value) {
    return ValidationHelper.validateRequired(value, 'Tempat lahir');
  }

  // Validasi Alamat
  String? validateAlamat(String? value) {
    return ValidationHelper.validateAddress(value);
  }

  // Validasi No HP
  String? validateNoHp(String? value) {
    return ValidationHelper.validatePhoneNumber(value);
  }

  // Validasi Email
  String? validateEmail(String? value) {
    return ValidationHelper.validateEmail(value);
  }

  // Validasi Password
  String? validatePassword(String? value) {
    return ValidationHelper.validatePassword(value);
  }

  // Validasi Konfirmasi Password
  String? validateKonfirmasiPassword(String? value) {
    return ValidationHelper.validatePasswordConfirmation(
      value,
      passwordController.text,
    );
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
    // Reset loading state at the beginning
    isLoading.value = false;

    // Validasi semua field
    final namaError = validateNamaLengkap(namaLengkapController.text.trim());
    final nikError = validateNIK(nikController.text.trim());
    final tempatLahirError = validateTempatLahir(
      tempatLahirController.text.trim(),
    );
    final tanggalLahirError = validateTanggalLahir(
      tanggalLahirController.text.trim(),
    );
    final alamatError = validateAlamat(alamatController.text.trim());
    final noHpError = validateNoHp(noHpController.text.trim());
    final emailError = validateEmail(emailController.text.trim());
    final passwordError = validatePassword(passwordController.text);
    final konfirmasiPasswordError = validateKonfirmasiPassword(
      konfirmasiPasswordController.text,
    );
    final jenisKelaminValid = validateJenisKelaminField();

    // Cek jika ada error dan tampilkan error spesifik
    if (namaError != null ||
        nikError != null ||
        tempatLahirError != null ||
        tanggalLahirError != null ||
        !jenisKelaminValid ||
        alamatError != null ||
        noHpError != null ||
        emailError != null ||
        passwordError != null ||
        konfirmasiPasswordError != null) {
      // Tampilkan error pertama yang ditemukan
      String errorMessage =
          namaError ??
          nikError ??
          tempatLahirError ??
          tanggalLahirError ??
          alamatError ??
          noHpError ??
          emailError ??
          passwordError ??
          konfirmasiPasswordError ??
          jenisKelaminError.value ??
          'Silakan isi semua field sesuai ketentuan';

      SnackbarHelper.showError(errorMessage);
      // Ensure loading state is false when validation fails
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      // Register user using AuthService with self-registration
      // Convert tanggal lahir from dd-MM-yyyy to ISO format
      DateTime? parsedDate;
      try {
        final parts = tanggalLahirController.text.trim().split('-');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        // Keep null if parsing fails
      }
      
      final userData = await _storage.auth.registerUser(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        namaLengkap: namaLengkapController.text.trim(),
        role: 'pasien',
        nik: nikController.text.trim(),
        noHp: noHpController.text.trim(),
        jenisKelamin: selectedJenisKelamin.value!,
        tanggalLahir: parsedDate?.toIso8601String().split('T')[0] ?? '',
        alamat: alamatController.text.trim(),
        additionalData: {
          'tempatLahir': tempatLahirController.text.trim(),
          'noRekamMedis': 'RM${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (userData != null) {
        // Small delay before login
        await Future.delayed(const Duration(milliseconds: 500));

        // Login immediately after registration
        final loginResult = await _storage.auth.login(
          email: emailController.text.trim().toLowerCase(),
          password: passwordController.text,
          role: 'pasien',
          rememberMe: false,
        );

        if (loginResult != null) {
          // Setup FCM topics for new registration (always enables notifications)
          await FCMService.to.setupUserTopicsOnRegistration('pasien');
          
          isLoading.value = false;
          _clearForm();

          SnackbarHelper.showSuccess(
            'Pendaftaran berhasil! Selamat datang di Puskesmas Dau.',
          );

          await Future.delayed(const Duration(milliseconds: 300));
          Get.offAllNamed(Routes.pasienDashboard);
        } else {
          isLoading.value = false;
          SnackbarHelper.showError(
            'Pendaftaran berhasil, silakan login manual',
          );
          Get.back();
        }
      } else {
        isLoading.value = false;
        SnackbarHelper.showError('Pendaftaran gagal. Silakan coba lagi.');
      }
    } catch (e) {
      isLoading.value = false;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      SnackbarHelper.showError(errorMessage);
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
