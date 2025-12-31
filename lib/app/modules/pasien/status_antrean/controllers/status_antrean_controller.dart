import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class StatusAntreanController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();

  final antrianData = Rxn<AntrianModel>();
  final userProfile = Rxn<UserProfileModel>();
  final queuePosition = 0.obs;
  final totalQueue = 0.obs; // Total antrian hari ini untuk poli yang sama
  final progressPercentage = 0.0.obs; // Progress dalam persen (0.0 - 1.0)
  final estimatedTime = ''.obs; // minutes remaining as string, or '0' for segera
  final isLoading = false.obs;
  final isInitialLoading = true.obs; // Flag untuk loading pertama kali
  
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _loadAntrianData();
    _startAutoRefresh();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      userProfile.value = profile;
    } catch (e) {
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadAntrianData() async {
    try {
      print('[StatusAntreanController] ===== _loadAntrianData: START =====');
      isInitialLoading.value = true;
      
      // Fetch antrian aktif langsung dari Firestore
      final antrian = await _antrianService.getActiveAntrian();
      print('[StatusAntreanController] _loadAntrianData: result = ${antrian?.toMap()}');
      
      isInitialLoading.value = false;
      
      if (antrian == null) {
        print('[StatusAntreanController] ❌ NO ACTIVE ANTRIAN - redirecting to dashboard');
        SnackbarHelper.showInfo('Tidak ada antrian aktif');
        Get.offAllNamed(Routes.pasienDashboard);
        return;
      }

      print('[StatusAntreanController] ✅ FOUND: ${antrian.queueNumber}, ${antrian.jenisLayanan}');
      antrianData.value = antrian;
      
      // Update posisi antrian
      await _updateQueuePosition();
      
      print('[StatusAntreanController] ===== _loadAntrianData: END ===== queueNumber=${antrian.queueNumber}');
    } catch (error) {
      isInitialLoading.value = false;
      print('[StatusAntreanController] ❌ _loadAntrianData ERROR: $error');
      SnackbarHelper.showError('Gagal memuat data antrian');
    }
  }

  void _startAutoRefresh() {
    // Auto refresh data setiap 30 detik untuk update posisi
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadAntrianData();
    });
  }

  Future<void> _updateQueuePosition() async {
    if (antrianData.value == null) return;

    try {
      // Get posisi antrian saat ini
      final position = await _antrianService.getQueuePosition(
        antrianData.value!.queueNumber,
        antrianData.value!.jenisLayanan,
      );
      
      // Get total antrian hari ini untuk poli yang sama
      final total = await _antrianService.getTodayQueueCountByPoli(
        antrianData.value!.jenisLayanan,
      );
      
      queuePosition.value = position;
      totalQueue.value = total;
      
      // ✅ HITUNG PROGRESS BERDASARKAN STATUS + POSISI ANTRIAN
      final status = antrianData.value?.status ?? '';
      double baseProgress = 0.0;
      
      // Base progress berdasarkan status workflow (lebih realistis)
      switch (status) {
        case 'menunggu':
          baseProgress = 0.1; // 10% - Baru daftar, belum verifikasi
          break;
        case 'menunggu_verifikasi':
          baseProgress = 0.2; // 20% - Upload dokumen lengkap
          break;
        case 'menunggu_dokter':
          baseProgress = 0.35; // 35% - Sudah diverifikasi perawat ✅ (lebih rendah)
          break;
        case 'sedang_dilayani':
          baseProgress = 0.75; // 75% - Dokter sedang periksa ✅
          break;
        case 'dipanggil':
          baseProgress = 0.9; // 90% - Dipanggil ke ruangan
          break;
        case 'selesai':
          baseProgress = 1.0; // 100% - Selesai
          break;
        default:
          baseProgress = 0.05; // 5% - Status tidak diketahui
      }
      
      // Tambah progress berdasarkan posisi antrian (max 30% dari base)
      // Semakin sedikit antrian di depan, semakin tinggi progress
      double positionBonus = 0.0;
      if (total > 0 && position > 0) {
        // Formula: (total - position) / total * 0.3
        // Contoh: Posisi 1 dari 10 = (10-1)/10 * 0.3 = 0.27 (27% bonus)
        //         Posisi 5 dari 10 = (10-5)/10 * 0.3 = 0.15 (15% bonus)
        //         Posisi 10 dari 10 = (10-10)/10 * 0.3 = 0.0 (0% bonus)
        positionBonus = ((total - position) / total) * 0.30;
      }
      
      progressPercentage.value = (baseProgress + positionBonus).clamp(0.0, 1.0);
      
      print('[StatusAntreanController] Status: $status, Base: ${(baseProgress*100).toInt()}%, Bonus: ${(positionBonus*100).toInt()}%, Total: ${(progressPercentage.value*100).toInt()}%');
      
      // Hitung estimasi waktu
      if (position > 0) {
        final minutes = position * 15; // 15 menit per pasien
        estimatedTime.value = minutes.toString();
      } else {
        estimatedTime.value = '0';
      }
      
      print('[StatusAntreanController] Position: $position/$total, Progress: ${(progressPercentage.value * 100).toStringAsFixed(0)}%');
    } catch (e) {
      print('[StatusAntreanController] _updateQueuePosition error: $e');
    }
  }

  Future<void> refreshData() async {
    // Manual refresh
    isLoading.value = true;
    await _loadAntrianData();
    isLoading.value = false;
  }

  String getStatusText() {
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi Perawat';
      case 'menunggu_dokter':
        return 'Menunggu Dokter'; // ✅ TAMBAH
      case 'sedang_dilayani':
        return 'Sedang Dilayani Dokter'; // ✅ TAMBAH
      case 'dipanggil':
        return 'Dipanggil - Segera ke Ruangan';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  String getStatusColor() {
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
        return 'orange';
      case 'menunggu_verifikasi':
        return 'orange';
      case 'menunggu_dokter':
        return 'blue'; // ✅ TAMBAH - Biru untuk menunggu dokter
      case 'sedang_dilayani':
        return 'green'; // ✅ TAMBAH - Hijau untuk sedang dilayani
      case 'dipanggil':
        return 'green';
      case 'selesai':
        return 'gray';
      case 'dibatalkan':
        return 'red';
      default:
        return 'gray';
    }
  }

  Future<void> batalkanAntrian() async {
    if (antrianData.value == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Batalkan Antrian?'),
        content: const Text('Apakah Anda yakin ingin membatalkan antrian ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      final antrianId = antrianData.value!.id;
      if (antrianId != null) {
        await _antrianService.cancelAntrian(antrianId);
        SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.pasienDashboard);
        });
      } else {
        SnackbarHelper.showError('ID antrian tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal membatalkan antrian');
    } finally {
      isLoading.value = false;
    }
  }

  void kembaliKeDashboard() {
    Get.offAllNamed(Routes.pasienDashboard);
  }
}
