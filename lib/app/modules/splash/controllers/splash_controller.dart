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
      // Debug log dengan detail lengkap
      print('=== SPLASH CHECK DEBUG ===');
      final isLoggedIn = _sessionService.isLoggedIn();
      final role = _sessionService.getRole();
      final userId = _sessionService.getUserId();
      
      print('Is logged in: $isLoggedIn');
      print('Role from session: $role');
      print('UserId from session: $userId');
      print('=========================');
      
      // Cek apakah user sudah login (remember me)
      if (isLoggedIn) {
        // Normalisasi role ke lowercase untuk konsistensi
        final normalizedRole = role?.toLowerCase() ?? '';
        
        print('Normalized role: $normalizedRole');
        print('Navigating to dashboard...');
        
        // Auto-login ke dashboard sesuai role
        switch (normalizedRole) {
          case 'admin':
            print('→ Admin Dashboard');
            Get.offAllNamed(Routes.adminDashboard);
            break;
          case 'dokter':
            print('→ Dokter Dashboard');
            Get.offAllNamed(Routes.dokterDashboard);
            break;
          case 'perawat':
            print('→ Perawat Dashboard');
            Get.offAllNamed(Routes.perawatDashboard);
            break;
          case 'apoteker':
            print('→ Apoteker Dashboard');
            Get.offAllNamed(Routes.apotekerDashboard);
            break;
          case 'pasien':
            print('→ Pasien Dashboard');
            Get.offAllNamed(Routes.pasienDashboard);
            break;
          default:
            // Jika role tidak dikenali, arahkan ke login pasien
            print('→ Unknown role, going to Login');
            Get.offAllNamed(Routes.pasienLogin);
        }
      } else {
        // Belum login, ke halaman login pasien
        print('→ Not logged in, going to Login');
        Get.offAllNamed(Routes.pasienLogin);
      }
    } catch (e) {
      // Jika terjadi error, arahkan ke login pasien
      Get.offAllNamed(Routes.pasienLogin);
    }
  }
}
