import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../dashboard/controllers/pasien_dashboard_controller.dart';

class PendaftaranController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  
  final jenisLayananController = TextEditingController();
  final keluhanController = TextEditingController();
  final nomorBPJSController = TextEditingController();
  
  final selectedLayanan = ''.obs;
  final useBPJS = false.obs;
  final isLoading = false.obs;
  
  final layananOptions = [
    {'value': 'Umum', 'label': 'Poli Umum', 'icon': Icons.medical_services},
    {'value': 'Gigi', 'label': 'Poli Gigi', 'icon': Icons.coronavirus},
    {'value': 'KB', 'label': 'Poli KB/KIA', 'icon': Icons.pregnant_woman},
    {'value': 'Lansia', 'label': 'Poli Lansia', 'icon': Icons.elderly},
    {'value': 'Imunisasi', 'label': 'Poli Imunisasi', 'icon': Icons.vaccines},
  ];

  @override
  void onInit() {
    super.onInit();
    _checkActiveQueue();
  }

  @override
  void onClose() {
    jenisLayananController.dispose();
    keluhanController.dispose();
    nomorBPJSController.dispose();
    super.onClose();
  }

  void _checkActiveQueue() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      // Check if user has active queue using getActiveAntrian
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        SnackbarHelper.showWarning(
          'Anda masih memiliki antrian aktif (${activeAntrian.queueNumber})',
        );
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed(Routes.pasienDashboard);
        });
      }
    } catch (e) {
      print('Error checking active queue: $e');
    }
  }

  void setLayanan(String layanan) {
    selectedLayanan.value = layanan;
    jenisLayananController.text = layanan;
  }

  void toggleBPJS(bool value) {
    useBPJS.value = value;
    if (!value) {
      nomorBPJSController.clear();
    }
  }

  String? validateLayanan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pilih jenis layanan';
    }
    return null;
  }

  String? validateKeluhan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Keluhan tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Keluhan minimal 10 karakter';
    }
    return null;
  }

  String? validateBPJS(String? value) {
    if (!useBPJS.value) return null;
    
    if (value == null || value.isEmpty) {
      return 'Nomor BPJS tidak boleh kosong';
    }
    if (value.length != 13) {
      return 'Nomor BPJS harus 13 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor BPJS hanya boleh angka';
    }
    return null;
  }

  Future<void> submitPendaftaran() async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Mohon lengkapi form dengan benar');
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      SnackbarHelper.showError('Sesi tidak valid, silakan login kembali');
      Get.offAllNamed(Routes.pasienLogin);
      return;
    }

    isLoading.value = true;

    try {
      // Get user profile
      final profile = await _profileService.getUserProfile();
      if (profile == null) {
        throw Exception('Profile tidak ditemukan');
      }

      // Check active queue
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        isLoading.value = false;
        SnackbarHelper.showWarning(
          'Anda masih memiliki antrian aktif (${activeAntrian.queueNumber})'
        );
        return;
      }

      // Create antrian
      await _antrianService.createAntrian(
        namaLengkap: profile.namaLengkap,
        noRekamMedis: profile.noRekamMedis ?? 'RM-${userId.substring(0, 8)}',
        jenisLayanan: selectedLayanan.value,
        keluhan: keluhanController.text.trim(),
        nomorBPJS: useBPJS.value ? nomorBPJSController.text.trim() : null,
      );

      isLoading.value = false;

      SnackbarHelper.showSuccess('Pendaftaran Berhasil!');

      await Future.delayed(Duration(milliseconds: 500));
      
      Get.delete<PasienDashboardController>();
      Get.offAllNamed(Routes.pasienDashboard);
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Gagal mendaftar: ${e.toString()}');
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    jenisLayananController.clear();
    keluhanController.clear();
    nomorBPJSController.clear();
    selectedLayanan.value = '';
    useBPJS.value = false;
  }
}
