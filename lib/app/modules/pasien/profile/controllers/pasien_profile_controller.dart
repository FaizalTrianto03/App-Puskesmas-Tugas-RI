import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/services/firestore/user_profile_firestore_service.dart';

class PasienProfileController extends GetxController {
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  // Observable user data
  final userName = ''.obs;
  final userNIK = ''.obs;
  final userRekamMedis = ''.obs;
  final cardValidUntil = '31 Desember 2026'.obs;
  final isLoading = false.obs;
  
  StreamSubscription? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    _watchUserProfile();
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }

  void _watchUserProfile() {
    isLoading.value = true;
    
    // Real-time listener untuk profile updates
    _profileSubscription = _profileService.watchUserProfile().listen(
      (profile) {
        isLoading.value = false;
        if (profile != null) {
          userName.value = profile.namaLengkap;
          userNIK.value = profile.nik ?? '-';
          userRekamMedis.value = profile.noRekamMedis ?? '-';
        } else {
          // Jika profile null, set default values
          userName.value = 'Pasien';
          userNIK.value = '-';
          userRekamMedis.value = '-';
        }
      },
      onError: (error) {
        isLoading.value = false;
        print('Error watching profile: $error');
        // Set default values on error
        userName.value = 'Pasien';
        userNIK.value = '-';
        userRekamMedis.value = '-';
      },
    );
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        userName.value = profile.namaLengkap;
        userNIK.value = profile.nik ?? '-';
        userRekamMedis.value = profile.noRekamMedis ?? '-';
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSettings() {
    Get.toNamed('/pasien-settings');
  }
  
  void navigateToProfile() {
    Get.toNamed('/pasien-profile');
  }
}
