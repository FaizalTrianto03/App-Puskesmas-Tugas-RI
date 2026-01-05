import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';

class PasienDashboardController extends GetxController with WidgetsBindingObserver {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  // Observable states
  final userName = ''.obs;
  final userEmail = ''.obs;
  final noRekamMedis = ''.obs;
  final hasActiveQueue = false.obs;
  final queueNumber = ''.obs;
  final jenisLayanan = ''.obs;
  final estimatedTime = ''.obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  
  // ✅ TAMBAH: Status dan timeline info untuk preview di dashboard
  final currentStatus = ''.obs; // Status raw dari Firestore
  final currentStatusText = ''.obs; // Status yang user-friendly
  final currentTimelineStage = ''.obs; // 'perawat', 'dokter', 'apoteker', dll
  final currentTimelineDescription = ''.obs; // Deskripsi detail untuk preview
  
  StreamSubscription? _profileSubscription;
  StreamSubscription? _activeAntrianSubscription; // ✅ TAMBAH: Listener untuk antrian aktif
  
  // UI State for hover and press effects
  final isHoverDaftarBaru = false.obs;
  final isHoverStatusAntrean = false.obs;
  final isHoverRiwayat = false.obs;
  final isHoverLayananLain = false.obs;
  final isHoverProfileCard = false.obs;
  final isPressedProfileCard = false.obs;
  final isPressedDaftarBaru = false.obs;
  final isPressedStatusAntrean = false.obs;
  final isPressedRiwayat = false.obs;
  final isPressedLayananLain = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    watchUserProfile();
    watchActiveAntrianRealtime(); // ✅ TAMBAH: Real-time listener untuk antrian
    _initQueueState();
  }

  @override
  void onReady() {
    super.onReady();
    // Force refetch data setiap kali halaman dashboard muncul/ready
    Future.microtask(() async {
      await refreshData();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileSubscription?.cancel();
    _activeAntrianSubscription?.cancel(); // ✅ TAMBAH: Cancel listener antrian
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refetch data setiap kali app kembali ke foreground
      refreshData();
    }
  }

  Future<void> _initQueueState() async {
    isLoading.value = true;
    
    // Load langsung dari Firestore, simpan di state
    await checkActiveQueue();
    
    isLoading.value = false;
  }
  
  void watchUserProfile() {
    // Add timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 5), () {
      if (userName.value.isEmpty) {
        loadUserData();
      }
    });
    
    _profileSubscription = _profileService.watchUserProfile().listen(
      (profile) {
        if (profile != null) {
          userName.value = profile.namaLengkap;
          userEmail.value = profile.email;
          noRekamMedis.value = profile.noRekamMedis ?? '-';
        } else {
          loadUserData();
        }
      },
      onError: (error) {
        loadUserData(); // Fallback to direct fetch on error
      },
    );
  }
  
  Future<void> loadUserData() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        userName.value = profile.namaLengkap;
        userEmail.value = profile.email;
        noRekamMedis.value = profile.noRekamMedis ?? '-';
      }
    } catch (e) {
    }
  }
  
  // ✅ TAMBAH: Watch active antrian secara real-time
  void watchActiveAntrianRealtime() {
    _activeAntrianSubscription?.cancel();
    _activeAntrianSubscription = _antrianService.watchActiveAntrian().listen(
      (antrian) {
        if (antrian != null) {
          hasActiveQueue.value = true;
          queueNumber.value = antrian.queueNumber;
          jenisLayanan.value = antrian.jenisLayanan;
          currentStatus.value = antrian.status;
          _updateTimelineInfo(antrian.status);
          _calculateEstimatedTime(antrian.jenisLayanan);
        } else {
          hasActiveQueue.value = false;
          queueNumber.value = '';
          jenisLayanan.value = '';
          estimatedTime.value = '';
          currentStatus.value = '';
          currentStatusText.value = '';
          currentTimelineStage.value = '';
          currentTimelineDescription.value = '';
        }
      },
      onError: (e) {
        // Fallback ke manual check
        checkActiveQueue();
      }
    );
  }
  
  // ✅ TAMBAH: Update timeline info berdasarkan status
  void _updateTimelineInfo(String status) {
    // Status text yang user-friendly
    switch (status) {
      case 'menunggu':
      case 'menunggu_verifikasi':
        currentStatusText.value = 'Menunggu Verifikasi';
        currentTimelineStage.value = 'perawat';
        currentTimelineDescription.value = 'Antrian sedang diverifikasi perawat';
        break;
      case 'menunggu_perawat':
        currentStatusText.value = 'Menunggu Perawat';
        currentTimelineStage.value = 'perawat';
        currentTimelineDescription.value = 'Menunggu giliran pemeriksaan awal';
        break;
      case 'dilayani_perawat':
        currentStatusText.value = 'Diperiksa Perawat';
        currentTimelineStage.value = 'perawat';
        currentTimelineDescription.value = 'Sedang diperiksa oleh perawat';
        break;
      case 'menunggu_dokter':
        currentStatusText.value = 'Menunggu Dokter';
        currentTimelineStage.value = 'dokter';
        currentTimelineDescription.value = 'Menunggu giliran pemeriksaan dokter';
        break;
      case 'sedang_dilayani':
      case 'dilayani_dokter':
        currentStatusText.value = 'Diperiksa Dokter';
        currentTimelineStage.value = 'dokter';
        currentTimelineDescription.value = 'Sedang diperiksa oleh dokter';
        break;
      case 'selesai_diperiksa':
        currentStatusText.value = 'Selesai Diperiksa';
        currentTimelineStage.value = 'apoteker';
        currentTimelineDescription.value = 'Menunggu penyiapan obat';
        break;
      case 'menunggu_apoteker':
        currentStatusText.value = 'Menunggu Obat';
        currentTimelineStage.value = 'apoteker';
        currentTimelineDescription.value = 'Obat sedang disiapkan apoteker';
        break;
      case 'dilayani_apoteker':
        currentStatusText.value = 'Obat Disiapkan';
        currentTimelineStage.value = 'apoteker';
        currentTimelineDescription.value = 'Apoteker sedang menyiapkan obat';
        break;
      case 'siap_ambil_obat':
        currentStatusText.value = 'Obat Siap';
        currentTimelineStage.value = 'pembayaran';
        currentTimelineDescription.value = 'Silakan bayar dan ambil obat';
        break;
      case 'pending':
        currentStatusText.value = 'Tertunda';
        currentTimelineStage.value = 'pending';
        currentTimelineDescription.value = 'Antrian tertunda - Harap tunggu';
        break;
      case 'dilewati':
        currentStatusText.value = 'Dilewati';
        currentTimelineStage.value = 'dilewati';
        currentTimelineDescription.value = 'Antrian dilewati sementara';
        break;
      case 'dipanggil':
        currentStatusText.value = 'Dipanggil';
        currentTimelineStage.value = 'dipanggil';
        currentTimelineDescription.value = 'Segera ke ruangan!';
        break;
      default:
        currentStatusText.value = 'Dalam Proses';
        currentTimelineStage.value = '';
        currentTimelineDescription.value = 'Antrian sedang diproses';
    }
  }
  
  Future<void> checkActiveQueue() async {
    // Refresh active queue manually - SELALU ambil data REAL dari Firestore
    try {
      final antrian = await _antrianService.getActiveAntrian();
      
      if (antrian != null) {
        hasActiveQueue.value = true;
        queueNumber.value = antrian.queueNumber;
        jenisLayanan.value = antrian.jenisLayanan;
        currentStatus.value = antrian.status;
        _updateTimelineInfo(antrian.status);
        await _calculateEstimatedTime(antrian.jenisLayanan);
      } else {
        hasActiveQueue.value = false;
        queueNumber.value = '';
        jenisLayanan.value = '';
        estimatedTime.value = '';
        currentStatus.value = '';
        currentStatusText.value = '';
        currentTimelineStage.value = '';
        currentTimelineDescription.value = '';
      }
    } catch (e) {
      // Jika error, set state kosong
      hasActiveQueue.value = false;
      queueNumber.value = '';
      jenisLayanan.value = '';
      estimatedTime.value = '';
      currentStatus.value = '';
      currentStatusText.value = '';
      currentTimelineStage.value = '';
      currentTimelineDescription.value = '';
    }
  }

  Future<void> _calculateEstimatedTime(String poli) async {
    try {
      // Hitung jumlah antrian yang masih menunggu
      final count = await _antrianService.getTodayQueueCountByPoli(poli);
      // Asumsi 15 menit per pasien
      const minutesPerPatient = 15;
      final totalMinutes = count * minutesPerPatient;
      
      if (totalMinutes < 60) {
        estimatedTime.value = '$totalMinutes menit';
      } else {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        if (minutes == 0) {
          estimatedTime.value = '$hours jam';
        } else {
          estimatedTime.value = '$hours jam $minutes menit';
        }
      }
    } catch (e) {
      estimatedTime.value = '15 menit';
    }
  }
  
  Future<void> refreshData() async {
    // Method untuk pull-to-refresh
    isRefreshing.value = true;
    
    try {
      // Refresh user profile
      await loadUserData();
      
      // Refresh antrian - ambil data REAL dari Firestore
      await checkActiveQueue();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }
  
  // Navigation functions
  void goToPendaftaran() {
    Get.toNamed(Routes.pasienPendaftaran);
  }
  
  void goToStatusAntrean() {
    Get.toNamed(Routes.pasienStatusAntrean);
  }
  
  void goToRiwayatKunjungan() {
    Get.toNamed(Routes.pasienRiwayat);
  }
  
  void goToLayananLainnya() {
    Get.snackbar('Info', 'Fitur Layanan Lainnya sedang dalam pengembangan');
  }
  
  void goToProfile() {
    Get.snackbar('Info', 'Fitur Profile sedang dalam pengembangan');
  }
  
  void goToSettings() {
    Get.toNamed(Routes.pasienSettings);
  }
  
  void showActiveQueueWarning() {
    Get.snackbar(
      'Tidak Dapat Diproses',
      'Maaf, Anda masih memiliki antrian aktif yang sedang diproses. Tindakan tidak dapat diproses.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF4242),
      colorText: Colors.white,
      icon: const Icon(Icons.block, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
  
  Future<void> logout() async {
    isLoading.value = true;
    // TODO: Add Firebase Auth sign out
    // await FirebaseAuth.instance.signOut();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
