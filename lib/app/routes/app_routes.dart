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
  static const adminSettings = _Paths.adminSettings;

  // Dokter
  static const dokterLogin = _Paths.dokterLogin;
  static const dokterDashboard = _Paths.dokterDashboard;
  static const dokterSettings = _Paths.dokterSettings;

  // Perawat
  static const perawatLogin = _Paths.perawatLogin;
  static const perawatDashboard = _Paths.perawatDashboard;
  static const perawatRiwayatPemeriksaan = _Paths.perawatRiwayatPemeriksaan;
  static const perawatRiwayatPemeriksaanDetail = _Paths.perawatRiwayatPemeriksaanDetail;
  static const perawatSettings = _Paths.perawatSettings;

  // Apoteker
  static const apotekerLogin = _Paths.apotekerLogin;
  static const apotekerDashboard = _Paths.apotekerDashboard;
  static const apotekerSettings = _Paths.apotekerSettings;

  // Pasien
  static const pasienLogin = _Paths.pasienLogin;
  static const pasienRegister = _Paths.pasienRegister;
  static const pasienDashboard = _Paths.pasienDashboard;
  static const pasienPendaftaran = _Paths.pasienPendaftaran;
  static const pasienProfile = _Paths.pasienProfile;
  static const pasienSettings = _Paths.pasienSettings;
  static const pasienKelolaDataDiri = _Paths.pasienKelolaDataDiri;
  static const pasienKelolaKataSandi = _Paths.pasienKelolaKataSandi;
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
  static const adminSettings = '/admin/settings';

  // Dokter
  static const dokterLogin = '/dokter/login';
  static const dokterDashboard = '/dokter/dashboard';
  static const dokterSettings = '/dokter/settings';

  // Perawat
  static const perawatLogin = '/perawat/login';
  static const perawatDashboard = '/perawat/dashboard';
  static const perawatRiwayatPemeriksaan = '/perawat/riwayat-pemeriksaan';
  static const perawatRiwayatPemeriksaanDetail = '/perawat/riwayat-pemeriksaan/detail';
  static const perawatSettings = '/perawat/settings';

  // Apoteker
  static const apotekerLogin = '/apoteker/login';
  static const apotekerDashboard = '/apoteker/dashboard';
  static const apotekerSettings = '/apoteker/settings';

  // Pasien
  static const pasienLogin = '/pasien-login';
  static const pasienRegister = '/pasien-register';
  static const pasienDashboard = '/pasien-dashboard';
  static const pasienPendaftaran = '/pasien-pendaftaran';
  static const pasienProfile = '/pasien-profile';
  static const pasienSettings = '/pasien-settings';
  static const pasienKelolaDataDiri = '/pasien-kelola-data-diri';
  static const pasienKelolaKataSandi = '/pasien-kelola-kata-sandi';
  static const pasienRiwayat = '/pasien-riwayat';
}
