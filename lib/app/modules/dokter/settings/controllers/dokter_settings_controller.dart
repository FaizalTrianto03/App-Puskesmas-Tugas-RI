import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class DokterSettingsController extends GetxController {
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
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
      userEmail.value = userData['email'] ?? '';
    }
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'dokter':
        return 'Dokter';
      case 'admin':
        return 'Admin';
      case 'perawat':
        return 'Perawat';
      case 'apoteker':
        return 'Apoteker';
      default:
        return 'Pasien';
    }
  }

  Future<void> logout() async {
    await AuthHelper.logout();
    Get.offAllNamed(Routes.splash);
    SnackbarHelper.showSuccess('Berhasil keluar dari akun');
  }
}
