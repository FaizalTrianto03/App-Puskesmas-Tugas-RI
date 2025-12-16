import 'package:get/get.dart';

import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
// Admin
import '../modules/admin/login/bindings/admin_login_binding.dart';
import '../modules/admin/login/views/admin_login_view.dart';
import '../modules/admin/settings/views/admin_settings_view.dart';
import '../modules/apoteker/dashboard/bindings/apoteker_dashboard_binding.dart';
import '../modules/apoteker/dashboard/views/apoteker_dashboard_view.dart';
// Apoteker
import '../modules/apoteker/login/bindings/apoteker_login_binding.dart';
import '../modules/apoteker/login/views/apoteker_login_view.dart';
import '../modules/apoteker/settings/views/apoteker_settings_view.dart';
// Common
import '../modules/common/views/lupa_kata_sandi_email_view.dart';
import '../modules/common/views/lupa_kata_sandi_reset_view.dart';
import '../modules/dokter/dashboard/bindings/dokter_dashboard_binding.dart';
import '../modules/dokter/dashboard/views/dokter_dashboard_view.dart';
// Dokter
import '../modules/dokter/login/bindings/dokter_login_binding.dart';
import '../modules/dokter/login/views/dokter_login_view.dart';
import '../modules/dokter/settings/views/dokter_settings_view.dart';
import '../modules/pasien/dashboard/bindings/pasien_dashboard_binding.dart';
import '../modules/pasien/dashboard/views/pasien_dashboard_view.dart';
// Pasien
import '../modules/pasien/login/bindings/pasien_login_binding.dart';
import '../modules/pasien/login/views/pasien_login_view.dart';
import '../modules/pasien/pendaftaran/bindings/pendaftaran_binding.dart';
import '../modules/pasien/pendaftaran/views/pasien_pendaftaran_view.dart';
import '../modules/pasien/profile/bindings/pasien_profile_binding.dart';
import '../modules/pasien/profile/views/pasien_profile_view.dart';
import '../modules/pasien/register/bindings/pasien_register_binding.dart';
import '../modules/pasien/register/views/pasien_register_view.dart';
import '../modules/pasien/riwayat/views/riwayat_kunjungan_view.dart';
import '../modules/pasien/settings/bindings/pasien_settings_binding.dart';
import '../modules/pasien/settings/views/kelola_data_diri_view.dart';
import '../modules/pasien/settings/views/kelola_kata_sandi_view.dart';
import '../modules/pasien/settings/views/pasien_settings_view.dart';
import '../modules/perawat/dashboard/bindings/perawat_dashboard_binding.dart';
import '../modules/perawat/dashboard/views/perawat_dashboard_view.dart';
// Perawat
import '../modules/perawat/login/bindings/perawat_login_binding.dart';
import '../modules/perawat/login/views/perawat_login_view.dart';
import '../modules/perawat/riwayat_pemeriksaan/bindings/riwayat_pemeriksaan_binding.dart';
import '../modules/perawat/riwayat_pemeriksaan/views/detail_riwayat_view.dart';
import '../modules/perawat/riwayat_pemeriksaan/views/riwayat_pemeriksaan_view.dart';
import '../modules/perawat/settings/views/perawat_settings_view.dart';
// Splash
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    // Splash
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Common
    GetPage(
      name: _Paths.lupaKataSandi,
      page: () => const LupaKataSandiEmailView(),
    ),
    GetPage(
      name: _Paths.lupaKataSandiReset,
      page: () => const LupaKataSandiResetView(),
    ),

    // Admin
    GetPage(
      name: _Paths.adminLogin,
      page: () => const AdminLoginView(),
      binding: AdminLoginBinding(),
    ),
    GetPage(
      name: _Paths.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: _Paths.adminSettings,
      page: () => const AdminSettingsView(),
    ),

    // Dokter
    GetPage(
      name: _Paths.dokterLogin,
      page: () => const DokterLoginView(),
      binding: DokterLoginBinding(),
    ),
    GetPage(
      name: _Paths.dokterDashboard,
      page: () => const DokterDashboardView(),
      binding: DokterDashboardBinding(),
    ),
    GetPage(
      name: _Paths.dokterSettings,
      page: () => const DokterSettingsView(),
    ),

    // Perawat
    GetPage(
      name: _Paths.perawatLogin,
      page: () => const PerawatLoginView(),
      binding: PerawatLoginBinding(),
    ),
    GetPage(
      name: _Paths.perawatDashboard,
      page: () => const PerawatDashboardView(),
      binding: PerawatDashboardBinding(),
    ),
    GetPage(
      name: _Paths.perawatRiwayatPemeriksaan,
      page: () => const RiwayatPemeriksaanView(),
      binding: RiwayatPemeriksaanBinding(),
    ),
    GetPage(
      name: _Paths.perawatRiwayatPemeriksaanDetail,
      page: () => const DetailRiwayatView(),
      binding: RiwayatPemeriksaanBinding(),
    ),
    GetPage(
      name: _Paths.perawatSettings,
      page: () => const PerawatSettingsView(),
    ),

    // Apoteker
    GetPage(
      name: _Paths.apotekerLogin,
      page: () => const ApotekerLoginView(),
      binding: ApotekerLoginBinding(),
    ),
    GetPage(
      name: _Paths.apotekerDashboard,
      page: () => const ApotekerDashboardView(),
      binding: ApotekerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.apotekerSettings,
      page: () => const ApotekerSettingsView(),
    ),

    // Pasien
    GetPage(
      name: _Paths.pasienLogin,
      page: () => const PasienLoginView(),
      binding: PasienLoginBinding(),
    ),
    GetPage(
      name: _Paths.pasienRegister,
      page: () => const PasienRegisterView(),
      binding: PasienRegisterBinding(),
    ),
    GetPage(
      name: _Paths.pasienDashboard,
      page: () => const PasienDashboardView(),
      binding: PasienDashboardBinding(),
    ),
    GetPage(
      name: _Paths.pasienPendaftaran,
      page: () => const PasienPendaftaranView(),
      binding: PendaftaranBinding(),
    ),
    GetPage(
      name: _Paths.pasienProfile,
      page: () => const PasienProfileView(),
      binding: PasienProfileBinding(),
    ),
    GetPage(
      name: _Paths.pasienSettings,
      page: () => const PasienSettingsView(),
      binding: PasienSettingsBinding(),
    ),
    GetPage(
      name: _Paths.pasienKelolaDataDiri,
      page: () => const KelolaDataDiriView(),
      binding: PasienSettingsBinding(),
    ),
    GetPage(
      name: _Paths.pasienKelolaKataSandi,
      page: () => const KelolaKataSandiView(),
      binding: PasienSettingsBinding(),
    ),
    GetPage(
      name: _Paths.pasienRiwayat,
      page: () => const RiwayatKunjunganView(),
    ),
  ];
}