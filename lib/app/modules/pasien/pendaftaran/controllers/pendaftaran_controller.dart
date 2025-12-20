import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/confirmation_dialog.dart';
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
  final hasActiveQueue = false.obs; // Flag untuk block form jika ada antrian aktif
  final activeQueueNumber = ''.obs; // Nomor antrian aktif
  
  final layananOptions = [
    {'value': 'Poli Umum', 'label': 'Poli Umum', 'icon': Icons.medical_services},
    {'value': 'Poli Gigi', 'label': 'Poli Gigi', 'icon': Icons.coronavirus},
    {'value': 'Poli KIA', 'label': 'Poli KB/KIA', 'icon': Icons.pregnant_woman},
    {'value': 'Poli Lansia', 'label': 'Poli Lansia', 'icon': Icons.elderly},
    {'value': 'Poli Imunisasi', 'label': 'Poli Imunisasi', 'icon': Icons.vaccines},
  ];

  @override
  void onInit() {
    super.onInit();
    _checkActiveQueue();
  }

  @override
  void onReady() {
    super.onReady();
    // Double check saat page ready
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
    if (userId == null) {
      print('[PendaftaranController] _checkActiveQueue: no user logged in');
      return;
    }
    
    isLoading.value = true;
    
    try {
      print('[PendaftaranController] _checkActiveQueue: checking for active queue...');
      // Check if user has active queue using getActiveAntrian
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        print('[PendaftaranController] ⚠️ Active queue found: ${activeAntrian.queueNumber}');
        hasActiveQueue.value = true;
        activeQueueNumber.value = activeAntrian.queueNumber;
        
        SnackbarHelper.showError(
          'TIDAK BISA DAFTAR! Anda masih memiliki antrian aktif: ${activeAntrian.queueNumber}',
        );
        
        // Redirect ke dashboard setelah 2 detik
        Future.delayed(Duration(seconds: 2), () {
          Get.back(result: false);
        });
      } else {
        print('[PendaftaranController] ✅ No active queue, user can register');
        hasActiveQueue.value = false;
        activeQueueNumber.value = '';
      }
    } catch (e) {
      print('[PendaftaranController] ❌ Error checking active queue: $e');
      hasActiveQueue.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void setLayanan(String layanan) {
    // Normalisasi ke format "Poli ..." supaya konsisten dengan service & view lain
    String mapped = layanan;
    switch (layanan) {
      case 'Umum':
        mapped = 'Poli Umum';
        break;
      case 'Gigi':
        mapped = 'Poli Gigi';
        break;
      case 'KB':
        mapped = 'Poli KIA';
        break;
      default:
        // Jika sudah dalam bentuk "Poli ..." atau lainnya, pakai apa adanya
        mapped = layanan;
    }

    selectedLayanan.value = mapped;
    jenisLayananController.text = mapped;
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
    // BLOCK SUBMIT jika ada antrian aktif
    if (hasActiveQueue.value) {
      await ConfirmationDialog.show(
        title: 'Tidak Bisa Mendaftar',
        message:
            'Anda masih memiliki antrian aktif: ${activeQueueNumber.value}. Selesaikan atau batalkan antrian tersebut sebelum mendaftar lagi.',
        type: ConfirmationType.warning,
        confirmText: 'Mengerti',
      );
      return;
    }
    
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

      // DOUBLE CHECK active queue sebelum create antrian
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        isLoading.value = false;
        hasActiveQueue.value = true;
        activeQueueNumber.value = activeAntrian.queueNumber;
        
        SnackbarHelper.showError(
          'TIDAK BISA DAFTAR! Anda masih memiliki antrian aktif: ${activeAntrian.queueNumber}',
        );
        
        // Redirect ke dashboard
        Future.delayed(Duration(seconds: 2), () {
          Get.back(result: false);
        });
        return;
      }

      // Create antrian
      final newAntrian = await _antrianService.createAntrian(
        namaLengkap: profile.namaLengkap,
        noRekamMedis: profile.noRekamMedis ?? 'RM-${userId.substring(0, 8)}',
        jenisLayanan: selectedLayanan.value,
        keluhan: keluhanController.text.trim(),
        nomorBPJS: useBPJS.value ? nomorBPJSController.text.trim() : null,
        tanggalLahir: profile.tanggalLahir,
      );

      print('[PendaftaranController] ✅ Antrian created: ${newAntrian.queueNumber}');
      
      isLoading.value = false;

      // LANGSUNG set state dashboard dengan data baru (tidak perlu tunggu fetch)
      try {
        final dashboardController = Get.find<PasienDashboardController>();
        print('[PendaftaranController] 🎯 Setting dashboard state directly...');
        dashboardController.hasActiveQueue.value = true;
        dashboardController.queueNumber.value = newAntrian.queueNumber;
        print('[PendaftaranController] ✅ Dashboard state set: hasActiveQueue=${dashboardController.hasActiveQueue.value}, queueNumber=${dashboardController.queueNumber.value}');
      } catch (e) {
        print('[PendaftaranController] ⚠️ Dashboard controller not found (will be created on navigation): $e');
      }

      // Tampilkan success message dengan nomor antrian
      SnackbarHelper.showSuccess('Pendaftaran Berhasil! Nomor Antrean: ${newAntrian.queueNumber}');

      // Delay sebentar untuk user lihat message
      await Future.delayed(Duration(milliseconds: 800));
      
      // Kembali ke dashboard
      Get.back(result: true);
      
      // Delay sebentar lalu refresh dashboard dari Firestore untuk memastikan data sync
      await Future.delayed(Duration(milliseconds: 500));
      
      try {
        final dashboardController = Get.find<PasienDashboardController>();
        print('[PendaftaranController] 🔄 Verify data from Firestore...');
        await dashboardController.checkActiveQueue();
        print('[PendaftaranController] ✅ Verified: hasActiveQueue=${dashboardController.hasActiveQueue.value}');
      } catch (e) {
        print('[PendaftaranController] ⚠️ Dashboard verify error: $e');
      }
      
      // Buka status antrian
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(Routes.pasienStatusAntrean);
      
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
