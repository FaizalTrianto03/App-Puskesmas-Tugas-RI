part of 'app_pages.dart';

// NOTE: Semua route menggunakan lowerCamelCase sesuai Dart convention
abstract class Routes {
  Routes._();

  // Splash & Onboarding
  static const splash = _Paths.splash;
  static const onboarding = _Paths.onboarding;

  // Common
  static const lupaKataSandi = _Paths.lupaKataSandi;

  // Admin
  static const adminLogin = _Paths.adminLogin;
  static const adminDashboard = _Paths.adminDashboard;
  static const adminSettings = _Paths.adminSettings;
  static const adminKelolaDataDiri = _Paths.adminKelolaDataDiri;
  static const adminKelolaKataSandi = _Paths.adminKelolaKataSandi;
  static const adminTambahPengguna = _Paths.adminTambahPengguna;
  static const adminKelolaPoli = _Paths.adminKelolaPoli;
  static const adminTambahPoli = _Paths.adminTambahPoli;
  static const adminKelolaRuangan = _Paths.adminKelolaRuangan;
  static const adminTambahRuangan = _Paths.adminTambahRuangan;
  static const adminKelolaInformasi = _Paths.adminKelolaInformasi;

  // Dokter
  static const dokterLogin = _Paths.dokterLogin;
  static const dokterDashboard = _Paths.dokterDashboard;
  static const dokterSettings = _Paths.dokterSettings;
  static const dokterKelolaDataDiri = _Paths.dokterKelolaDataDiri;
  static const dokterKelolaKataSandi = _Paths.dokterKelolaKataSandi;
  static const dokterRiwayatPemeriksaan = _Paths.dokterRiwayatPemeriksaan;
  static const dokterLaporanKinerja = _Paths.dokterLaporanKinerja;
  static const dokterDataPasien = _Paths.dokterDataPasien;

  // Perawat
  static const perawatLogin = _Paths.perawatLogin;
  static const perawatDashboard = _Paths.perawatDashboard;
  static const perawatRiwayatPemeriksaan =
      _Paths.perawatRiwayatPemeriksaan;
  static const perawatRiwayatPemeriksaanDetail =
      _Paths.perawatRiwayatPemeriksaanDetail;
  static const perawatLaporanKinerja = _Paths.perawatLaporanKinerja;
  static const perawatSettings = _Paths.perawatSettings;

  // Apoteker
  static const apotekerLogin = _Paths.apotekerLogin;
  static const apotekerDashboard = _Paths.apotekerDashboard;
  static const apotekerSettings = _Paths.apotekerSettings;
  static const apotekerKelolaDataDiri = _Paths.apotekerKelolaDataDiri;
  static const apotekerKelolaKataSandi = _Paths.apotekerKelolaKataSandi;
  static const apotekerStokObat = _Paths.apotekerStokObat;
  static const apotekerTambahObat = _Paths.apotekerTambahObat;
  static const apotekerRiwayatPenyiapan = _Paths.apotekerRiwayatPenyiapan;
  static const apotekerDataPasien = _Paths.apotekerDataPasien;

  // Pasien (JANGAN DISENTUH)
  static const pasienLogin = _Paths.pasienLogin;
  static const pasienRegister = _Paths.pasienRegister;
  static const pasienDashboard = _Paths.pasienDashboard;
  static const pasienPendaftaran = _Paths.pasienPendaftaran;
  static const pasienStatusAntrean = _Paths.pasienStatusAntrean;
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

  // Common
  static const lupaKataSandi = '/lupa-kata-sandi';

  // Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminSettings = '/admin/settings';
  static const adminKelolaDataDiri = '/admin/kelola-data-diri';
  static const adminKelolaKataSandi = '/admin/kelola-kata-sandi';
  static const adminTambahPengguna = '/admin/tambah-pengguna';
  static const adminKelolaPoli = '/admin/kelola-poli';
  static const adminTambahPoli = '/admin/tambah-poli';
  static const adminKelolaRuangan = '/admin/kelola-ruangan';
  static const adminTambahRuangan = '/admin/tambah-ruangan';
  static const adminKelolaInformasi = '/admin/kelola-informasi';

  // Dokter
  static const dokterLogin = '/dokter/login';
  static const dokterDashboard = '/dokter/dashboard';
  static const dokterSettings = '/dokter/settings';
  static const dokterKelolaDataDiri = '/dokter/kelola-data-diri';
  static const dokterKelolaKataSandi = '/dokter/kelola-kata-sandi';
  static const dokterRiwayatPemeriksaan = '/dokter/riwayat-pemeriksaan';
  static const dokterLaporanKinerja = '/dokter/laporan-kinerja';
  static const dokterDataPasien = '/dokter/data-pasien';

  // Perawat
  static const perawatLogin = '/perawat/login';
  static const perawatDashboard = '/perawat/dashboard';
  static const perawatRiwayatPemeriksaan =
      '/perawat/riwayat-pemeriksaan';
  static const perawatRiwayatPemeriksaanDetail =
      '/perawat/riwayat-pemeriksaan/detail';
  static const perawatReferensiSelesai = '/perawat/referensi-selesai';
  static const perawatLaporanKinerja = '/perawat/laporan-kinerja';
  static const perawatSettings = '/perawat/settings';

  // Apoteker
  static const apotekerLogin = '/apoteker/login';
  static const apotekerDashboard = '/apoteker/dashboard';
  static const apotekerSettings = '/apoteker/settings';
  static const apotekerKelolaDataDiri = '/apoteker/kelola-data-diri';
  static const apotekerKelolaKataSandi = '/apoteker/kelola-kata-sandi';
  static const apotekerStokObat = '/apoteker/stok-obat';
  static const apotekerTambahObat = '/apoteker/stok-obat/tambah';
  static const apotekerRiwayatPenyiapan = '/apoteker/riwayat-penyiapan';
  static const apotekerDataPasien = '/apoteker/data-pasien';

  // Pasien 
  static const pasienLogin = '/pasien-login';
  static const pasienRegister = '/pasien-register';
  static const pasienDashboard = '/pasien-dashboard';
  static const pasienPendaftaran = '/pasien-pendaftaran';
  static const pasienStatusAntrean = '/pasien-status-antrean';
  static const pasienProfile = '/pasien-profile';
  static const pasienSettings = '/pasien-settings';
  static const pasienKelolaDataDiri = '/pasien-kelola-data-diri';
  static const pasienKelolaKataSandi = '/pasien-kelola-kata-sandi';
  static const pasienRiwayat = '/pasien-riwayat';
}