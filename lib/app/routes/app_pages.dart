import 'package:get/get.dart';

import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/kelola_pengguna/bindings/kelola_pengguna_binding.dart';
import '../modules/admin/kelola_pengguna/views/tambah_pengguna_view.dart';
import '../modules/admin/kelola_poli/bindings/kelola_poli_binding.dart';
import '../modules/admin/kelola_poli/views/kelola_poli_list_view.dart';
import '../modules/admin/kelola_poli/views/tambah_poli_view.dart';
import '../modules/admin/kelola_ruangan/bindings/kelola_ruangan_binding.dart';
import '../modules/admin/kelola_ruangan/views/kelola_ruangan_list_view.dart';
import '../modules/admin/kelola_ruangan/views/tambah_ruangan_view.dart';
import '../modules/admin/kelola_informasi/bindings/kelola_informasi_binding.dart';
import '../modules/admin/kelola_informasi/views/kelola_informasi_view.dart';
// Admin
import '../modules/admin/login/bindings/admin_login_binding.dart';
import '../modules/admin/login/views/admin_login_view.dart';
import '../modules/admin/settings/bindings/admin_settings_binding.dart';
import '../modules/admin/settings/views/admin_settings_view.dart';
import '../modules/admin/settings/views/kelola_data_diri_view.dart' as admin_kelola_data;
import '../modules/admin/settings/views/kelola_kata_sandi_view.dart' as admin_kelola_sandi;
import '../modules/apoteker/dashboard/bindings/apoteker_dashboard_binding.dart';
import '../modules/apoteker/dashboard/views/apoteker_dashboard_view.dart';
// Apoteker
import '../modules/apoteker/login/bindings/apoteker_login_binding.dart';
import '../modules/apoteker/login/views/apoteker_login_view.dart';
import '../modules/apoteker/settings/bindings/apoteker_settings_binding.dart';
import '../modules/apoteker/settings/views/apoteker_settings_view.dart' as apoteker_settings;
import '../modules/apoteker/settings/views/kelola_data_diri_view.dart' as apoteker_kelola_data;
import '../modules/apoteker/settings/views/kelola_kata_sandi_view.dart' as apoteker_kelola_sandi;
import '../modules/apoteker/stok_obat/bindings/stok_obat_binding.dart';
import '../modules/apoteker/stok_obat/views/stok_obat_view.dart';
import '../modules/apoteker/stok_obat/views/tambah_obat_view.dart';
import '../modules/apoteker/riwayat_penyiapan/bindings/riwayat_penyiapan_binding.dart';
import '../modules/apoteker/riwayat_penyiapan/views/riwayat_penyiapan_view.dart';
import '../modules/apoteker/data_pasien/bindings/data_pasien_binding.dart' as apoteker_data_pasien_binding;
import '../modules/apoteker/data_pasien/views/data_pasien_view.dart' as apoteker_data_pasien_view;
// Common
import '../modules/common/views/lupa_kata_sandi_email_view.dart';
import '../modules/dokter/dashboard/bindings/dokter_dashboard_binding.dart';
import '../modules/dokter/dashboard/views/dokter_dashboard_view.dart';
import '../modules/dokter/riwayat_pemeriksaan/bindings/riwayat_pemeriksaan_binding.dart' as dokter_riwayat_binding;
import '../modules/dokter/riwayat_pemeriksaan/views/riwayat_pemeriksaan_view.dart' as dokter_riwayat_view;
import '../modules/dokter/laporan_kinerja/bindings/laporan_kinerja_binding.dart' as dokter_laporan_binding;
import '../modules/dokter/laporan_kinerja/views/laporan_kinerja_view.dart' as dokter_laporan_view;
import '../modules/dokter/data_pasien/bindings/data_pasien_binding.dart' as dokter_data_pasien_binding;
import '../modules/dokter/data_pasien/views/data_pasien_view.dart' as dokter_data_pasien_view;
// Dokter
import '../modules/dokter/login/bindings/dokter_login_binding.dart';
import '../modules/dokter/login/views/dokter_login_view.dart';
import '../modules/dokter/settings/bindings/dokter_settings_binding.dart';
import '../modules/dokter/settings/views/dokter_settings_view.dart' as dokter_settings;
import '../modules/dokter/settings/views/kelola_data_diri_view.dart' as dokter_kelola_data;
import '../modules/dokter/settings/views/kelola_kata_sandi_view.dart' as dokter_kelola_sandi;
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
import '../modules/pasien/status_antrean/bindings/status_antrean_binding.dart';
import '../modules/pasien/status_antrean/views/status_antrean_view.dart';
import '../modules/perawat/dashboard/bindings/perawat_dashboard_binding.dart';
import '../modules/perawat/dashboard/views/perawat_dashboard_view.dart';
import '../modules/perawat/laporan_kinerja/bindings/laporan_kinerja_binding.dart';
import '../modules/perawat/laporan_kinerja/views/laporan_kinerja_view.dart';
// Perawat
import '../modules/perawat/login/bindings/perawat_login_binding.dart';
import '../modules/perawat/login/views/perawat_login_view.dart';
import '../modules/perawat/referensi_selesai/bindings/referensi_selesai_binding.dart';
import '../modules/perawat/referensi_selesai/views/referensi_selesai_view.dart';
import '../modules/perawat/riwayat_pemeriksaan/bindings/riwayat_pemeriksaan_binding.dart';
import '../modules/perawat/riwayat_pemeriksaan/views/riwayat_pemeriksaan_view.dart';
import '../modules/perawat/settings/bindings/perawat_settings_binding.dart';
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
      binding: AdminSettingsBinding(),
    ),
    GetPage(
      name: _Paths.adminKelolaDataDiri,
      page: () => const admin_kelola_data.AdminKelolaDataDiriView(),
      binding: AdminSettingsBinding(),
    ),
    GetPage(
      name: _Paths.adminKelolaKataSandi,
      page: () => const admin_kelola_sandi.KelolaKataSandiView(),
      binding: AdminSettingsBinding(),
    ),
    GetPage(
      name: _Paths.adminTambahPengguna,
      page: () => const TambahPenggunaView(),
      binding: KelolaPenggunaBinding(),
    ),
    GetPage(
      name: _Paths.adminKelolaPoli,
      page: () => const KelolaPoliListView(),
      binding: KelolaPoliBinding(),
    ),
    GetPage(
      name: _Paths.adminTambahPoli,
      page: () => const TambahPoliView(),
      binding: KelolaPoliBinding(),
    ),
    GetPage(
      name: _Paths.adminKelolaRuangan,
      page: () => const KelolaRuanganListView(),
      binding: KelolaRuanganBinding(),
    ),
    GetPage(
      name: _Paths.adminTambahRuangan,
      page: () => const TambahRuanganView(),
      binding: KelolaRuanganBinding(),
    ),
    GetPage(
      name: _Paths.adminKelolaInformasi,
      page: () => const KelolaInformasiView(),
      binding: KelolaInformasiBinding(),
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
      page: () => const dokter_settings.DokterSettingsView(),
      binding: DokterSettingsBinding(),
    ),
    GetPage(
      name: _Paths.dokterKelolaDataDiri,
      page: () => const dokter_kelola_data.KelolaDataDiriView(),
      binding: DokterSettingsBinding(),
    ),
    GetPage(
      name: _Paths.dokterKelolaKataSandi,
      page: () => const dokter_kelola_sandi.KelolaKataSandiView(),
      binding: DokterSettingsBinding(),
    ),
    GetPage(
      name: _Paths.dokterRiwayatPemeriksaan,
      page: () => const dokter_riwayat_view.DokterRiwayatPemeriksaanView(),
      binding: dokter_riwayat_binding.DokterRiwayatPemeriksaanBinding(),
    ),
    GetPage(
      name: _Paths.dokterLaporanKinerja,
      page: () => const dokter_laporan_view.DokterLaporanKinerjaView(),
      binding: dokter_laporan_binding.DokterLaporanKinerjaBinding(),
    ),
    GetPage(
      name: _Paths.dokterDataPasien,
      page: () => const dokter_data_pasien_view.DataPasienView(),
      binding: dokter_data_pasien_binding.DataPasienBinding(),
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
      name: _Paths.perawatReferensiSelesai,
      page: () => const ReferensiSelesaiView(),
      binding: ReferensiSelesaiBinding(),
    ),

    GetPage(
      name: _Paths.perawatLaporanKinerja,
      page: () => const LaporanKinerjaView(),
      binding: LaporanKinerjaBinding(),
    ),
    GetPage(
      name: _Paths.perawatSettings,
      page: () => const PerawatSettingsView(),
      binding: PerawatSettingsBinding(),
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
      page: () => const apoteker_settings.ApotekerSettingsView(),
      binding: ApotekerSettingsBinding(),
    ),
    GetPage(
      name: _Paths.apotekerKelolaDataDiri,
      page: () => const apoteker_kelola_data.KelolaDataDiriView(),
      binding: ApotekerSettingsBinding(),
    ),
    GetPage(
      name: _Paths.apotekerKelolaKataSandi,
      page: () => const apoteker_kelola_sandi.KelolaKataSandiView(),
      binding: ApotekerSettingsBinding(),
    ),
    GetPage(
      name: _Paths.apotekerStokObat,
      page: () => const StokObatView(),
      binding: StokObatBinding(),
    ),
    GetPage(
      name: _Paths.apotekerTambahObat,
      page: () => const TambahObatView(),
      binding: StokObatBinding(),
    ),
    GetPage(
      name: _Paths.apotekerRiwayatPenyiapan,
      page: () => const RiwayatPenyiapanView(),
      binding: RiwayatPenyiapanBinding(),
    ),
    GetPage(
      name: _Paths.apotekerDataPasien,
      page: () => const apoteker_data_pasien_view.DataPasienView(),
      binding: apoteker_data_pasien_binding.DataPasienBinding(),
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
      name: _Paths.pasienStatusAntrean,
      page: () => const StatusAntreanView(),
      binding: StatusAntreanBinding(),
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