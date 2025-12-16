import 'package:get/get.dart';

import '../../../data/services/auth/session_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  late final SessionService _sessionService;

  @override
  void onInit() {
    super.onInit();
    try {
      _sessionService = Get.find<SessionService>();
    } catch (e) {
      _sessionService = SessionService();
    }
    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final isLoggedIn = _sessionService.isLoggedIn();
      final role = _sessionService.getRole();
      final userId = _sessionService.getUserId();
      
      // Cek apakah user sudah login (remember me)
      if (isLoggedIn) {
        // Normalisasi role ke lowercase untuk konsistensi
        final normalizedRole = role?.toLowerCase() ?? '';

        // Auto-login ke dashboard sesuai role
        switch (normalizedRole) {
          case 'admin':
            Get.offAllNamed(Routes.adminDashboard);
            break;
          case 'dokter':
            Get.offAllNamed(Routes.dokterDashboard);
            break;
          case 'perawat':
            Get.offAllNamed(Routes.perawatDashboard);
            break;
          case 'apoteker':
            Get.offAllNamed(Routes.apotekerDashboard);
            break;
          case 'pasien':
            Get.offAllNamed(Routes.pasienDashboard);
            break;
          default:
            Get.offAllNamed(Routes.pasienLogin);
        }
      } else {
        Get.offAllNamed(Routes.pasienLogin);
      }
    } catch (e) {
      // Jika terjadi error, arahkan ke login pasien
      Get.offAllNamed(Routes.pasienLogin);
    }
  }
}
