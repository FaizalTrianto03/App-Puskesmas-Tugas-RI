import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class PerawatSettingsController extends GetxController {
  final userName = ''.obs;
  final userRole = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    print('=== PERAWAT SETTINGS DEBUG ===');
    print('Loading user data...');
    
    final userData = await AuthHelper.currentUserData;
    print('UserData from Firestore: $userData');
    
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
      userEmail.value = userData['email'] ?? '';
      
      print('Loaded:');
      print('  - Name: ${userName.value}');
      print('  - Role: ${userRole.value}');
      print('  - Email: ${userEmail.value}');
    } else {
      print('ERROR: userData is NULL!');
    }
    print('=== END PERAWAT SETTINGS DEBUG ===');
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'perawat':
        return 'Perawat';
      case 'admin':
        return 'Admin';
      case 'dokter':
        return 'Dokter';
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
