part of 'app_pages.dart';

// NOTE: Semua route menggunakan lowerCamelCase sesuai Dart convention
abstract class Routes {
  Routes._();

  // Splash & Onboarding
  static const splash = _Paths.splash;
  static const onboarding = _Paths.onboarding;

  // Common (Shared across all roles)
  static const lupaKataSandi = _Paths.lupaKataSandi;
  static const lupaKataSandiReset = _Paths.lupaKataSandiReset;

  // Admin
  static const adminLogin = _Paths.adminLogin;
  static const adminDashboard = _Paths.adminDashboard;

  // Dokter
  static const dokterLogin = _Paths.dokterLogin;
  static const dokterDashboard = _Paths.dokterDashboard;

  // Perawat
  static const perawatLogin = _Paths.perawatLogin;
  static const perawatDashboard = _Paths.perawatDashboard;

  // Apoteker
  static const apotekerLogin = _Paths.apotekerLogin;
  static const apotekerDashboard = _Paths.apotekerDashboard;

  // Pasien
  static const pasienLogin = _Paths.pasienLogin;
  static const pasienRegister = _Paths.pasienRegister;
  static const pasienDashboard = _Paths.pasienDashboard;
  static const pasienPendaftaran = _Paths.pasienPendaftaran;
  static const pasienSettings = _Paths.pasienSettings;
  static const pasienRiwayat = _Paths.pasienRiwayat;
}

abstract class _Paths {
  _Paths._();

  // Splash & Onboarding
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // Common (Shared across all roles)
  static const lupaKataSandi = '/lupa-kata-sandi';
  static const lupaKataSandiReset = '/lupa-kata-sandi/reset';

  // Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';

  // Dokter
  static const dokterLogin = '/dokter/login';
  static const dokterDashboard = '/dokter/dashboard';

  // Perawat
  static const perawatLogin = '/perawat/login';
  static const perawatDashboard = '/perawat/dashboard';

  // Apoteker
  static const apotekerLogin = '/apoteker/login';
  static const apotekerDashboard = '/apoteker/dashboard';

  // Pasien
  static const pasienLogin = '/pasien/login';
  static const pasienRegister = '/pasien/register';
  static const pasienDashboard = '/pasien/dashboard';
  static const pasienPendaftaran = '/pasien/pendaftaran';
  static const pasienSettings = '/pasien/settings';
  static const pasienRiwayat = '/pasien/riwayat';
}
