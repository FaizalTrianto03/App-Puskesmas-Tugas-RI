import 'package:get/get.dart';

import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class PasienSettingsController extends GetxController {
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  final userName = ''.obs;
  final userRole = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        userName.value = profile.namaLengkap;
        userRole.value = 'Pasien';
        userEmail.value = profile.email;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> logout() async {
    await AuthHelper.logout();
    Get.offAllNamed(Routes.splash);
    SnackbarHelper.showSuccess('Berhasil keluar dari akun');
  }
}
