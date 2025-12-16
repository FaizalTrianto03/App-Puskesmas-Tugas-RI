import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class AdminSettingsController extends GetxController {
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = 'Administrator'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  
  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? 'Admin';
      userEmail.value = userData['email'] ?? '-';
      userRole.value = _getRoleDisplay(userData['role']);
    }
  }
  
  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'dokter':
        return 'Dokter';
      case 'perawat':
        return 'Perawat';
      case 'apoteker':
        return 'Apoteker';
      default:
        return 'User';
    }
  }
  
  Future<void> logout() async {
    await AuthHelper.logout();
    Get.offAllNamed(Routes.splash);
    SnackbarHelper.showSuccess('Berhasil keluar dari akun');
  }
}
