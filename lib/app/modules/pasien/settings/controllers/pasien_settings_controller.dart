import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class PasienSettingsController extends GetxController {
  final userName = ''.obs;
  final userRole = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final userData = AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? 'Pasien';
      userRole.value = 'Pasien';
      userEmail.value = userData['email'] ?? '';
    }
  }

  Future<void> logout() async {
    await AuthHelper.logout();
    Get.offAllNamed(Routes.splash);
    SnackbarHelper.showSuccess('Berhasil keluar dari akun');
  }
}
