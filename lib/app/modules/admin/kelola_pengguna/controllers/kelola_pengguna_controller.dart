import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/form_modal.dart';
import '../../../../utils/confirmation_dialog.dart';

class KelolaPenggunaController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final selectedRole = 'Dokter'.obs;
  final userList = <Map<String, dynamic>>[].obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  
  final roles = ['Dokter', 'Perawat', 'Apoteker'];

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final List<dynamic> decoded = json.decode(usersJson);
    userList.value = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', json.encode(userList));
  }

  void addUser() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      SnackbarHelper.showError('Semua field harus diisi');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      SnackbarHelper.showError('Password dan konfirmasi password tidak sama');
      return;
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'role': selectedRole.value,
    };

    userList.add(newUser);
    saveUsers();

    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = 'Dokter';

    Get.back();
    SnackbarHelper.showSuccess('Pengguna berhasil ditambahkan');
  }

  void updateUser(String id) {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty) {
      SnackbarHelper.showError('Semua field harus diisi');
      return;
    }

    // If password fields are filled, validate them
    if (passwordController.text.isNotEmpty || confirmPasswordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        SnackbarHelper.showError('Password dan konfirmasi password tidak sama');
        return;
      }
    }

    final index = userList.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      userList[index] = {
        'id': id,
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text.isNotEmpty 
          ? passwordController.text 
          : userList[index]['password'],
        'role': selectedRole.value,
      };
      saveUsers();

      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      selectedRole.value = 'Dokter';

      Get.back();
      SnackbarHelper.showSuccess('Pengguna berhasil diperbarui');
    }
  }

  void deleteUser(String id) {
    userList.removeWhere((user) => user['id'] == id);
    saveUsers();
    SnackbarHelper.showSuccess('Pengguna berhasil dihapus');
  }

  void showAddUserDialog() {
    // Clear fields
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = 'Dokter';

    FormModal.show(
      title: 'Tambah Pengguna',
      titleIcon: Icons.person_add,
      fields: [
        FormFieldConfig(
          label: 'Username',
          type: FormFieldType.text,
          controller: usernameController,
          icon: Icons.person_outline,
        ),
        FormFieldConfig(
          label: 'Email',
          type: FormFieldType.email,
          controller: emailController,
          icon: Icons.email_outlined,
        ),
        FormFieldConfig(
          label: 'Role',
          type: FormFieldType.dropdown,
          icon: Icons.badge_outlined,
          dropdownItems: roles,
          dropdownValue: selectedRole.value,
          onDropdownChanged: (value) => selectedRole.value = value,
        ),
        FormFieldConfig(
          label: 'Password',
          type: FormFieldType.password,
          controller: passwordController,
          icon: Icons.lock_outline,
          obscureText: isPasswordVisible,
          onToggleVisibility: togglePasswordVisibility,
        ),
        FormFieldConfig(
          label: 'Konfirmasi Password',
          type: FormFieldType.password,
          controller: confirmPasswordController,
          icon: Icons.lock_outline,
          obscureText: isConfirmPasswordVisible,
          onToggleVisibility: toggleConfirmPasswordVisibility,
        ),
      ],
      onSubmit: addUser,
      onCancel: () {
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      },
    );
  }

  void showEditUserDialog(Map<String, dynamic> user) {
    // Populate fields with existing data
    usernameController.text = user['username'];
    emailController.text = user['email'];
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = user['role'];

    FormModal.show(
      title: 'Edit Pengguna',
      titleIcon: Icons.edit,
      fields: [
        FormFieldConfig(
          label: 'Username',
          type: FormFieldType.text,
          controller: usernameController,
          icon: Icons.person_outline,
        ),
        FormFieldConfig(
          label: 'Email',
          type: FormFieldType.email,
          controller: emailController,
          icon: Icons.email_outlined,
        ),
        FormFieldConfig(
          label: 'Role',
          type: FormFieldType.dropdown,
          icon: Icons.badge_outlined,
          dropdownItems: roles,
          dropdownValue: selectedRole.value,
          onDropdownChanged: (value) => selectedRole.value = value,
        ),
        FormFieldConfig(
          label: 'Password Baru',
          type: FormFieldType.password,
          controller: passwordController,
          icon: Icons.lock_outline,
          obscureText: isPasswordVisible,
          onToggleVisibility: togglePasswordVisibility,
          required: false,
          hint: 'Kosongkan jika tidak ingin mengubah',
        ),
        FormFieldConfig(
          label: 'Konfirmasi Password Baru',
          type: FormFieldType.password,
          controller: confirmPasswordController,
          icon: Icons.lock_outline,
          obscureText: isConfirmPasswordVisible,
          onToggleVisibility: toggleConfirmPasswordVisibility,
          required: false,
          hint: 'Kosongkan jika tidak ingin mengubah',
        ),
      ],
      onSubmit: () => updateUser(user['id']),
      onCancel: () {
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      },
      submitText: 'Perbarui',
    );
  }

  void confirmDeleteUser(String id, String username) {
    ConfirmationDialog.show(
      title: 'Hapus Pengguna',
      message: 'Apakah Anda yakin ingin menghapus pengguna "$username"?',
      type: ConfirmationType.danger,
      confirmText: 'Hapus',
      cancelText: 'Batal',
      onConfirm: () => deleteUser(id),
    );
  }
}
