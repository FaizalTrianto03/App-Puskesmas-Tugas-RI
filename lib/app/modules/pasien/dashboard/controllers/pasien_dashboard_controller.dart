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
  
  StreamSubscription? _profileSubscription;
  
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
    _initQueueState();
  }

  @override
  void onReady() {
    super.onReady();
    // Force refetch data setiap kali halaman dashboard muncul/ready
    print('[PasienDashboardController] ===== onReady: FORCE REFETCH =====');
    Future.microtask(() async {
      await refreshData();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refetch data setiap kali app kembali ke foreground
      print('[PasienDashboardController] App resumed: force refetch data');
      refreshData();
    }
  }

  Future<void> _initQueueState() async {
    print('[PasienDashboardController] ===== _initQueueState: START =====');
    isLoading.value = true;
    
    // Load langsung dari Firestore, simpan di state
    await checkActiveQueue();
    
    isLoading.value = false;
    print('[PasienDashboardController] ===== _initQueueState: END ===== hasActiveQueue=${hasActiveQueue.value}, queueNumber=${queueNumber.value}');
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
  
  Future<void> checkActiveQueue() async {
    // Refresh active queue manually - SELALU ambil data REAL dari Firestore
    try {
      print('[PasienDashboardController] ===== checkActiveQueue: START =====');
      final antrian = await _antrianService.getActiveAntrian();
      print('[PasienDashboardController] checkActiveQueue: result = ${antrian?.toMap()}');
      
      if (antrian != null) {
        print('[PasienDashboardController] ✅ FOUND: ${antrian.queueNumber}, ${antrian.jenisLayanan}');
        hasActiveQueue.value = true;
        queueNumber.value = antrian.queueNumber;
        jenisLayanan.value = antrian.jenisLayanan;
        await _calculateEstimatedTime(antrian.jenisLayanan);
        print('[PasienDashboardController] State updated: hasActiveQueue=${hasActiveQueue.value}, queueNumber=${queueNumber.value}');
      } else {
        print('[PasienDashboardController] ❌ NO ACTIVE ANTRIAN');
        hasActiveQueue.value = false;
        queueNumber.value = '';
        jenisLayanan.value = '';
        estimatedTime.value = '';
      }
      print('[PasienDashboardController] ===== checkActiveQueue: END =====');
    } catch (e) {
      print('[PasienDashboardController] ❌ checkActiveQueue ERROR: $e');
      // Jika error, set state kosong
      hasActiveQueue.value = false;
      queueNumber.value = '';
      jenisLayanan.value = '';
      estimatedTime.value = '';
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
    print('[PasienDashboardController] ===== refreshData: START =====');
    isRefreshing.value = true;
    
    try {
      // Refresh user profile
      await loadUserData();
      
      // Refresh antrian - ambil data REAL dari Firestore
      await checkActiveQueue();
      
      print('[PasienDashboardController] ===== refreshData: SUCCESS ===== hasActiveQueue=${hasActiveQueue.value}');
    } catch (e) {
      print('[PasienDashboardController] ===== refreshData: ERROR ===== $e');
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
  
  void goToNotifikasi() {
    Get.snackbar('Info', 'Fitur Notifikasi sedang dalam pengembangan');
  }
  
  Future<void> logout() async {
    isLoading.value = true;
    // TODO: Add Firebase Auth sign out
    // await FirebaseAuth.instance.signOut();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
