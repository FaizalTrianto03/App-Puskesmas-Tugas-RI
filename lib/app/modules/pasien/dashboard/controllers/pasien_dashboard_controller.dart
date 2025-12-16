import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';

class PasienDashboardController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  // Observable states
  final userName = ''.obs;
  final userEmail = ''.obs;
  final noRekamMedis = ''.obs;
  final hasActiveQueue = false.obs;
  final queueNumber = ''.obs;
  final isLoading = false.obs;
  
  StreamSubscription? _antrianSubscription;
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
    print('PasienDashboardController: onInit()');
    watchUserProfile();
    watchActiveQueue();
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }
  
  void watchUserProfile() {
    print('PasienDashboardController: watchUserProfile()');
    
    // Add timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 5), () {
      if (userName.value.isEmpty) {
        print('PasienDashboardController: Timeout - falling back to direct fetch');
        loadUserData();
      }
    });
    
    _profileSubscription = _profileService.watchUserProfile().listen(
      (profile) {
        if (profile != null) {
          userName.value = profile.namaLengkap;
          userEmail.value = profile.email;
          noRekamMedis.value = profile.noRekamMedis ?? '-';
          print('PasienDashboardController: Loaded user - ${userName.value}');
        } else {
          print('PasienDashboardController: Profile is null - trying direct fetch');
          loadUserData();
        }
      },
      onError: (error) {
        print('PasienDashboardController: Error watching profile - $error');
        loadUserData(); // Fallback to direct fetch on error
      },
    );
  }
  
  Future<void> loadUserData() async {
    print('PasienDashboardController: loadUserData()');
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        userName.value = profile.namaLengkap;
        userEmail.value = profile.email;
        noRekamMedis.value = profile.noRekamMedis ?? '-';
        print('PasienDashboardController: Loaded user - ${userName.value}');
      }
    } catch (e) {
      print('PasienDashboardController: Error loading user data - $e');
    }
  }
  
  void watchActiveQueue() {
    // Listen to real-time antrian updates from Firestore
    _antrianSubscription = _antrianService.watchActiveAntrian().listen(
      (antrian) {
        if (antrian != null) {
          hasActiveQueue.value = true;
          queueNumber.value = antrian.queueNumber;
          print('Active antrian: ${antrian.queueNumber}');
        } else {
          hasActiveQueue.value = false;
          queueNumber.value = '';
          print('No active antrian');
        }
      },
      onError: (error) {
        print('Error watching active antrian: $error');
        hasActiveQueue.value = false;
        queueNumber.value = '';
      },
    );
  }
  
  Future<void> checkActiveQueue() async {
    // Refresh active queue manually
    try {
      final antrian = await _antrianService.getActiveAntrian();
      if (antrian != null) {
        hasActiveQueue.value = true;
        queueNumber.value = antrian.queueNumber;
      } else {
        hasActiveQueue.value = false;
        queueNumber.value = '';
      }
    } catch (e) {
      print('Error checking active queue: $e');
    }
  }
  
  // Navigation functions
  void goToPendaftaran() {
    Get.toNamed(Routes.pasienPendaftaran);
  }
  
  void goToStatusAntrean() {
    Get.snackbar('Info', 'Fitur Status Antrian sedang dalam pengembangan');
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
