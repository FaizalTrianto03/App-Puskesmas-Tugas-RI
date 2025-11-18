import 'package:get/get.dart';

// Admin
import '../modules/admin/login/bindings/admin_login_binding.dart';
import '../modules/admin/login/views/admin_login_view.dart';
import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';

// Dokter
import '../modules/dokter/login/bindings/dokter_login_binding.dart';
import '../modules/dokter/login/views/dokter_login_view.dart';
import '../modules/dokter/dashboard/bindings/dokter_dashboard_binding.dart';
import '../modules/dokter/dashboard/views/dokter_dashboard_view.dart';

// Perawat
import '../modules/perawat/login/bindings/perawat_login_binding.dart';
import '../modules/perawat/login/views/perawat_login_view.dart';
import '../modules/perawat/dashboard/bindings/perawat_dashboard_binding.dart';
import '../modules/perawat/dashboard/views/perawat_dashboard_view.dart';

// Apoteker
import '../modules/apoteker/login/bindings/apoteker_login_binding.dart';
import '../modules/apoteker/login/views/apoteker_login_view.dart';
import '../modules/apoteker/dashboard/bindings/apoteker_dashboard_binding.dart';
import '../modules/apoteker/dashboard/views/apoteker_dashboard_view.dart';

// Pasien
import '../modules/pasien/login/bindings/pasien_login_binding.dart';
import '../modules/pasien/login/views/pasien_login_view.dart';
import '../modules/pasien/dashboard/bindings/pasien_dashboard_binding.dart';
import '../modules/pasien/dashboard/views/pasien_dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.adminLogin;

  static final routes = [
    // Admin Routes
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

    // Dokter Routes
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

    // Perawat Routes
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

    // Apoteker Routes
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

    // Pasien Routes
    GetPage(
      name: _Paths.pasienLogin,
      page: () => const PasienLoginView(),
      binding: PasienLoginBinding(),
    ),
    GetPage(
      name: _Paths.pasienDashboard,
      page: () => const PasienDashboardView(),
      binding: PasienDashboardBinding(),
    ),
  ];
}
