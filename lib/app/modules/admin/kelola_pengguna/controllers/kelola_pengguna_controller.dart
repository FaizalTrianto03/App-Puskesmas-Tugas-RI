import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/validation_helper.dart';

class KelolaPenggunaController extends GetxController {
  final StorageService _storage = StorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Dialog password controller
  final dialogPasswordController = TextEditingController();
  
  // Search controller
  final searchController = TextEditingController();
  
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
  
  final nikError = ''.obs;
  
  // Dialog observables
  final dialogPasswordVisible = false.obs;
  final dialogLoading = false.obs;
  
  final roles = ['admin', 'dokter', 'perawat', 'apoteker'];
  final roleFilters = ['Semua', 'Admin', 'Dokter', 'Perawat', 'Apoteker', 'Pasien'];
  final jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    
    // Listen to NIK changes for validation
    nikController.addListener(() {
      final nik = nikController.text;
      if (nik.isEmpty) {
        nikError.value = 'NIK harus diisi';
      } else if (nik.length < 16) {
        nikError.value = 'NIK harus 16 digit';
      } else {
        nikError.value = '';
      }
    });
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
      
      // Get current logged in user ID
      final currentUserId = _storage.getUserId();
      
      // Filter out current logged in user and ensure all required fields exist
      userList.value = users.where((user) {
        // Skip current logged in user
        if (user['id'] == currentUserId) return false;
        
        // Ensure all required fields exist with default values
        user['namaLengkap'] = user['namaLengkap'] ?? 'Nama Tidak Tersedia';
        user['email'] = user['email'] ?? '-';
        user['role'] = user['role'] ?? '-';
        user['nik'] = user['nik'] ?? '';
        user['noHp'] = user['noHp'] ?? '';
        user['alamat'] = user['alamat'] ?? '';
        
        return true;
      }).toList();
      
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
      filtered = filtered.where((user) {
        final role = user['role'];
        if (role == null) return false;
        return role.toString().toLowerCase() == selectedRoleFilter.value.toLowerCase();
      }).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((user) {
        final nama = user['namaLengkap']?.toString() ?? '';
        final email = user['email']?.toString() ?? '';
        final nik = user['nik']?.toString() ?? '';
        
        return nama.toLowerCase().contains(query) ||
               email.toLowerCase().contains(query) ||
               nik.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredUserList.value = filtered;
  }

  Map<String, int> getUserStatistics() {
    final stats = <String, int>{
      'total': userList.length,
      'admin': 0,
      'dokter': 0,
      'perawat': 0,
      'apoteker': 0,
      'pasien': 0,
    };

    for (var user in userList) {
      final role = user['role'];
      if (role != null) {
        final roleStr = role.toString().toLowerCase();
        if (stats.containsKey(roleStr)) {
          stats[roleStr] = (stats[roleStr] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    searchController.text = query;
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

  /// Setup notification topics for newly created user
  /// This pre-configures the topics in Firestore so they're ready when user logs in
  Future<void> _setupNotificationTopicsForNewUser(String? userId, String role) async {
    if (userId == null || userId.isEmpty) return;
    
    try {
      // Get user's firebaseUid from the document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;
      
      final firebaseUid = userDoc.data()?['firebaseUid'] ?? userId;
      final personalTopic = 'user-$firebaseUid';
      
      // Build topics list based on role
      // Broadcast topics only for admin, perawat, apoteker
      // Dokter and Pasien only get personal topic (specific notifications)
      const broadcastRoleTopics = ['admin', 'perawat', 'apoteker'];
      final topicsToSubscribe = <String>[personalTopic, 'general'];
      
      if (broadcastRoleTopics.contains(role)) {
        topicsToSubscribe.add(role);
      }
      
      // Update Firestore with initial topic setup
      await _firestore.collection('users').doc(userId).update({
        'notificationSubscription': true,
        'notificationCreatedAt': FieldValue.serverTimestamp(),
        'subscribedTopics': topicsToSubscribe,
        'lastTopicUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail - topics will be set up on first login
    }
  }

  // CRUD Operations
  Future<void> createUser() async {
    // Alias for addUser - same implementation
    await addUser();
  }

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
      // Format nomor HP dengan +62 prefix
      String phoneNumber = noHpController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+62')) {
        phoneNumber = '+62$phoneNumber';
      }
      
      final userData = await _storage.auth.registerUser(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        namaLengkap: namaController.text.trim(),
        role: selectedRole.value,
        nik: nikController.text.trim(),
        noHp: phoneNumber,
        jenisKelamin: selectedJenisKelamin.value,
        tanggalLahir: tanggalLahir.value?.toIso8601String().split('T')[0] ?? '',
        alamat: alamatController.text.trim(),
      );

      if (userData != null) {
        // Setup notification topics for new user in Firestore
        // (FCM subscription will happen when user logs in for the first time)
        await _setupNotificationTopicsForNewUser(userData['id'], selectedRole.value);
        
        await loadUsers();
        clearForm();
        
        // Kembali ke halaman sebelumnya
        Get.back();
        
        // Delay sebentar baru tampilkan snackbar
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Pengguna berhasil ditambahkan');
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

    // Validate userId
    if (userId.isEmpty) {
      SnackbarHelper.showError('ID pengguna tidak valid');
      return;
    }

    isLoading.value = true;

    try {
      // Verify user exists first
      final existingUser = await _storage.findUserById(userId);
      if (existingUser == null) {
        SnackbarHelper.showError('Pengguna dengan ID $userId tidak ditemukan di database');
        isLoading.value = false;
        return;
      }

      // Check email exists (excluding current user)
      final emailExists = await validateEmailExists(
        emailController.text.trim().toLowerCase(),
        excludeId: userId,
      );
      if (emailExists) {
        SnackbarHelper.showError('Email sudah digunakan oleh pengguna lain');
        isLoading.value = false;
        return;
      }

      // Check NIK exists (excluding current user)
      final nikExists = await validateNIKExists(
        nikController.text.trim(),
        excludeId: userId,
      );
      if (nikExists) {
        SnackbarHelper.showError('NIK sudah digunakan oleh pengguna lain');
        isLoading.value = false;
        return;
      }

      // Format nomor HP dengan +62 prefix
      String phoneNumber = noHpController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+62')) {
        phoneNumber = '+62$phoneNumber';
      }

      // Check if role is changed
      final oldRole = existingUser['role']?.toString().toLowerCase();
      final newRole = selectedRole.value.toLowerCase();
      final roleChanged = oldRole != newRole;
      
      final updates = {
        'namaLengkap': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'noHp': phoneNumber,
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
        // If role changed, update the subscribedTopics in Firestore
        if (roleChanged) {
          await _updateUserTopicsOnRoleChange(userId, existingUser, newRole);
        }
        
        await loadUsers();
        clearForm();
        
        // Kembali ke halaman sebelumnya
        Get.back();
        
        // Delay sebentar baru tampilkan snackbar
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Data pengguna berhasil diperbarui');
      } else {
        SnackbarHelper.showError('Gagal memperbarui data pengguna');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
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
    selectedJenisKelamin.value = 'L';
    tanggalLahir.value = null;
  }

  void populateFormForEdit(Map<String, dynamic> user) {
    namaController.text = user['namaLengkap'] ?? '';
    nikController.text = user['nik'] ?? '';
    emailController.text = user['email'] ?? '';
    
    // Format nomor HP: hilangkan +62 prefix untuk ditampilkan di field
    String phoneNumber = user['noHp'] ?? '';
    if (phoneNumber.startsWith('+62')) {
      phoneNumber = phoneNumber.substring(3);
    } else if (phoneNumber.startsWith('62')) {
      phoneNumber = phoneNumber.substring(2);
    } else if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    noHpController.text = phoneNumber;
    
    alamatController.text = user['alamat'] ?? '';
    
    // Set role dari user data tanpa perubahan
    String userRole = (user['role'] ?? 'dokter').toString().toLowerCase();
    selectedRole.value = userRole;
    
    // Set jenis kelamin - langsung pakai value dari database (L/P)
    selectedJenisKelamin.value = user['jenisKelamin'] ?? 'L';
    
    // Parse tanggal lahir - support ISO (yyyy-MM-dd), dd-MM-yyyy, and dd/MM/yyyy
    if (user['tanggalLahir'] != null && user['tanggalLahir'].toString().isNotEmpty) {
      try {
        final dateStr = user['tanggalLahir'].toString();
        if (dateStr.contains('-')) {
          // Check if ISO format (yyyy-MM-dd)
          if (dateStr.split('-')[0].length == 4) {
            tanggalLahir.value = DateTime.parse(dateStr);
          } else {
            // dd-MM-yyyy format
            final parts = dateStr.split('-');
            if (parts.length == 3) {
              tanggalLahir.value = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          }
        } else if (dateStr.contains('/')) {
          // dd/MM/yyyy format
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            tanggalLahir.value = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } else {
          tanggalLahir.value = DateTime.parse(dateStr);
        }
      } catch (e) {
        tanggalLahir.value = null;
      }
    } else {
      tanggalLahir.value = null;
    }
    
    passwordController.clear();
    confirmPasswordController.clear();
  }

  /// Verify admin password before allowing role change to admin
  Future<bool> verifyAdminPassword() async {
    // Clear and reset dialog state
    dialogPasswordController.clear();
    dialogPasswordVisible.value = false;
    dialogLoading.value = false;
    
    final result = await Get.dialog<bool>(
        PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop && !dialogLoading.value) {
              Get.back(result: false);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Color(0xFFD97706),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'Verifikasi Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Message
                  const Text(
                    'Untuk menambahkan admin baru, masukkan password akun admin Anda:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Input
                  Obx(() => TextField(
                    controller: dialogPasswordController,
                    obscureText: !dialogPasswordVisible.value,
                    enabled: !dialogLoading.value,
                    decoration: InputDecoration(
                      labelText: 'Password Admin',
                      hintText: 'Masukkan password Anda',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6B7C93), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          dialogPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => dialogPasswordVisible.value = !dialogPasswordVisible.value,
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                  
                  // Actions
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: dialogLoading.value ? null : () => Get.back(result: false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: dialogLoading.value
                              ? null
                              : () async {
                                  if (dialogPasswordController.text.isEmpty) {
                                    SnackbarHelper.showError('Password harus diisi');
                                    return;
                                  }
                                  
                                  try {
                                    dialogLoading.value = true;
                                    final email = _storage.getEmail();
                                    if (email == null) {
                                      SnackbarHelper.showError('Session tidak valid');
                                      Get.back(result: false);
                                      return;
                                    }
                                    
                                    final result = await _storage.auth.login(
                                      email: email,
                                      password: dialogPasswordController.text,
                                      role: 'admin',
                                      rememberMe: false,
                                    );
                                    
                                    if (result != null) {
                                      Get.back(result: true);
                                    } else {
                                      SnackbarHelper.showError('Password salah');
                                    }
                                  } catch (e) {
                                    SnackbarHelper.showError('Password salah');
                                  } finally {
                                    dialogLoading.value = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE2E8F0),
                            disabledForegroundColor: const Color(0xFF94A3B8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: dialogLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Verifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      return result ?? false;
  }

  /// Reset password by sending email
  Future<void> resetPassword({
    required String userId,
    required String email,
    required String nama,
  }) async {
    final confirmed = await ConfirmationDialog.show(
      title: 'Reset Password',
      message: 'Kirim email reset password ke "$nama"?\n\nUser akan menerima email untuk membuat password baru.',
      confirmText: 'Kirim Email',
      cancelText: 'Batal',
      type: ConfirmationType.warning,
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      // Kirim email reset password
      await _storage.auth.resetPasswordByAdmin(
        userId: userId,
        email: email,
      );

      SnackbarHelper.showSuccess('Email reset password berhasil dikirim ke $nama');
    } catch (e) {
      SnackbarHelper.showError('Gagal mengirim email: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user's subscribed topics when role is changed by admin
  /// This updates the Firestore document so Cloud Functions can send
  /// notifications to the correct topic
  Future<void> _updateUserTopicsOnRoleChange(
    String userId,
    Map<String, dynamic> existingUser,
    String newRole,
  ) async {
    try {
      // Get firebaseUid - we need this to update the correct user document
      final firebaseUid = existingUser['firebaseUid']?.toString();
      
      if (firebaseUid == null || firebaseUid.isEmpty) {
        return;
      }
      
      // Update subscribedTopics to new role
      // Replace old role topic with new role topic
      await _firestore.collection('users').doc(firebaseUid).update({
        'subscribedTopics': [newRole, 'general'],
        'roleChangedAt': FieldValue.serverTimestamp(),
        'roleChangedFrom': existingUser['role'],
        'roleChangedTo': newRole,
      });
      
      
      // Note: The actual FCM topic subscription change will happen when
      // the user logs in again - FCM subscribes user to topics on login
      // based on their role in Firestore
    } catch (e) {
      // Don't throw - this is a non-critical operation
    }
  }
}
