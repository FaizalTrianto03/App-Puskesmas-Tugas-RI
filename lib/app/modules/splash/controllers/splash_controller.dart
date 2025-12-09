import 'package:get/get.dart';

import '../../../data/services/auth/session_service.dart';
import '../../admin/dashboard/views/admin_dashboard_view.dart';
import '../../apoteker/dashboard/views/apoteker_dashboard_view.dart';
import '../../dokter/dashboard/views/dokter_dashboard_view.dart';
import '../../pasien/dashboard/views/pasien_dashboard_view.dart';
import '../../pasien/login/views/pasien_login_view.dart';
import '../../perawat/dashboard/views/perawat_dashboard_view.dart';

class SplashController extends GetxController {
  final _sessionService = SessionService();

  @override
  void onInit() {
    super.onInit();
    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Cek apakah user sudah login (remember me)
    if (_sessionService.isLoggedIn()) {
      // Normalisasi role ke lowercase untuk konsistensi
      final role = _sessionService.getRole()?.toLowerCase();
      
      // Auto-login ke dashboard sesuai role
      switch (role) {
        case 'admin':
          Get.offAll(() => AdminDashboardView());
          break;
        case 'dokter':
          Get.offAll(() => DokterDashboardView());
          break;
        case 'perawat':
          Get.offAll(() => PerawatDashboardView());
          break;
        case 'apoteker':
          Get.offAll(() => ApotekerDashboardView());
          break;
        case 'pasien':
          Get.offAll(() => PasienDashboardView());
          break;
        default:
          // Jika role tidak dikenali, tetap arahkan ke login pasien tanpa menghapus session
          Get.offAll(() => const PasienLoginView());
      }
    } else {
      // Belum login, ke halaman login pasien
      Get.offAll(() => const PasienLoginView());
    }
  }
}
