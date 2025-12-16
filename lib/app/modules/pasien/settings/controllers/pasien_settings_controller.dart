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

  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
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
