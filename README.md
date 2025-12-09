# 🏥 Tugas Rekayasa Interaksi — Aplikasi Puskesmas Dau

Project ini merupakan tugas mata kuliah **Rekayasa Interaksi** dengan tema **Aplikasi Puskesmas**.  
Aplikasi dikembangkan menggunakan **Flutter** dan **Firebase** dengan sistem multi-role authentication untuk berbagai pengguna (Pasien, Dokter, Perawat, Apoteker, Admin).

Repository: https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI

---

## 💡 Deskripsi Project

Aplikasi Puskesmas ini dirancang untuk mempermudah akses layanan kesehatan bagi masyarakat dan staff medis.  

### Fitur Utama:
- **Multi-role System** - 5 role berbeda (Pasien, Dokter, Perawat, Apoteker, Admin)
- **Kartu Kesehatan Digital** - Kartu identitas kesehatan pasien Puskesmas Dau yang dapat diakses kapan saja dengan informasi lengkap (NIK, No. Rekam Medis, masa berlaku)
- **Pendaftaran Online Pasien** - Form pendaftaran dengan pilihan Poli dan Keluhan, detail pendaftaran dinamis
- **Sistem Antrian Digital** - Real-time status antrean dengan informasi lengkap
- **Riwayat Kunjungan Pasien** - History pemeriksaan lengkap dengan diagnosis, tindakan, dan resep obat
- **Monitoring Pasien** - Daftar pasien dalam antrian untuk staff medis
- **Rekam Medis Terintegrasi** - Akses dan kelola riwayat rekam medis pasien
- **Manajemen Pengguna** - CRUD user untuk berbagai role
- **Laporan & Statistik** - Laporan kunjungan, stok obat, dan keuangan dengan visualisasi chart
- **Manajemen Obat** - Pengelolaan resep dan stok obat
- **Firebase Integration** - Real-time database dan authentication

Project ini berfokus pada penerapan antarmuka yang intuitif, kemudahan interaksi, serta pengalaman pengguna yang efisien dan ramah.

---

## 👥 Anggota Kelompok

| Kelas | NIM | Nama Lengkap | Username GitHub |
|-------|-----|--------------|-----------------|
| RI-A | 202210370311009 | Anisa Ayu Nabila Nur Rahmah | anisaayu05 |
| RI-A | 202210370311015 | Faizal Qadri Trianto | FaizalTrianto03 |
| RI-B | 202210370311021 | Dias Aditama | DiasAditama |
| RI-B | 202210370311023 | Mukarram Luthfi Al Manfaluti | MukarramLuthfiAlManfaluti |

---

## 🔗 Link Penting

- **Figma Design:** [Kelompok RI 2025](https://www.figma.com/design/kdsNWqjifLP8TWPkgRJcAG/Kelompok-RI-2025---2022-009--A---2022-015--A---2022-021--B---2022-023--B---?node-id=562-1822&t=JO9fICjs9lTce2wK-1)
- **Worksheet:** [Google Drive Folder](https://drive.google.com/drive/folders/1PZvS_4ZE1ak_icvMJBJx_kjj01GUnqye?usp=sharing)
- **Low Fidelity Prototype:** [Low Fidelity](https://drive.google.com/file/d/1O8NTeDy47PVV7leIOyzP6TmgozzTHsXq/view?usp=drive_link)

---

## 📋 Tabel Pembagian Tugas (Backlog)

### Aplikasi Puskesmas

| Agile Organization | Admin | Dokter | Perawat | Apoteker | Pasien |
|--------------------|-------|--------|---------|----------|--------|
| **Product Owner** | Faizal | Faizal | Luthfi | Dias | Anisa |
| **Scrum Master** | Anisa | Anisa | Faizal | Luthfi | Dias |
| **Tim Pengembangan** | Dias<br>Luthfi | Dias<br>Luthfi | Anisa<br>Dias | Anisa<br>Faizal | Faizal<br>Luthfi |

### Pembagian Role Development
- **Admin:** Faizal Qadri Trianto
- **Dokter:** Faizal Qadri Trianto
- **Perawat:** Mukarram Luthfi Al Manfaluti
- **Apoteker:** Dias Aditama
- **Pasien:** Anisa Ayu Nabila Nur Rahmah

---

## ⚙️ Tech Stack

- **Flutter** 3.7.0 - UI Framework
- **GetX** 4.7.2 - State Management & Routing
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Real-time Database
- **Google Fonts** - Typography (Poppins)
- **Animate Do** & **Lottie** - Animations
- **Flutter SVG** - Vector graphics
- **Shared Preferences** - Local storage

---

## 📁 Struktur Project

```
lib/
├── app/
│   ├── data/           # Models, services, repositories
│   ├── modules/        # Feature modules (auth, dashboard, dll)
│   ├── routes/         # App navigation (GetX routing)
│   ├── utils/          # Colors, text styles, helpers
│   └── widgets/        # Reusable custom widgets
├── firebase_options.dart
└── main.dart

assets/
├── data/               # JSON, data files
├── fonts/              # Custom fonts
├── icons/              # SVG icons
└── images/             # Image assets
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.0+
- Dart SDK 3.7.0+
- Firebase project
- Android Studio / VS Code

### Installation

1. Clone repository
	```bash
	git clone https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI.git
	cd App-Puskesmas-Tugas-RI
	```

2. Install dependencies
	```bash
	flutter pub get
	```

3. Setup Firebase
	- Copy `.env.example` ke `.env`
	- Isi kredensial Firebase
	- Konfigurasi `firebase_options.dart`

4. Run app
	```bash
	flutter run
	```

---

## 📱 Development Branch

- `main` - Production ready code
- `Minggu-1-SetupProject` - Week 1 setup ✅
- `Minggu-2-ImplementasiLayoutUI` - Week 2 UI implementation ✅
- `Minggu-3-InteraktivitasNavigasi` - Week 3 Interactivity & Navigation ✅
- `Minggu-4-IntegrasiLogika` - Week 4 Logic Integration ✅ (in progress)

---

📌 *Project ini dikembangkan untuk memenuhi tugas mata kuliah Rekayasa Interaksi dan sebagai studi penerapan Flutter dalam digitalisasi layanan puskesmas melalui aplikasi mobile.*

**Last Updated:** December 8, 2025  
**Status:** Week 4 - Integrasi Logika In Progress 🚧

---

## 📅 Progress Development

### ✅ Week 1 - Setup Awal & Review Figma (17-23 Nov 2025)

**Completed:**
- ✅ Flutter project initialization
- ✅ Firebase configuration with dotenv
- ✅ Folder structure setup (GetX MVC)
- ✅ Theme setup (colors, typography)
- ✅ Assets folder structure
- ✅ Base utilities (AppColors, AppTextStyles, ConfirmationDialog, SnackbarHelper)
- ✅ Custom widgets (CustomButton, CustomTextField)
- ✅ Splash screen with animations
- ✅ Multi-role routing (Admin, Dokter, Perawat, Apoteker, Pasien)
- ✅ Android build configuration (minSdk 23, Kotlin 2.1.0, NDK 27.0.12077973)
- ✅ Documentation

### ✅ Week 2 - Implementasi Layout UI (24-30 Nov 2025) - Completed

**Completed:**
- ✅ Base layout dengan QuarterCircleBackground widget
- ✅ Pasien Module:
  - ✅ Login & Register page dengan validasi form
  - ✅ Dashboard dengan quick access menu dan informasi akun
  - ✅ Profile page dengan Kartu Kesehatan Digital Puskesmas
  - ✅ Pendaftaran Online dengan form Poli dan Keluhan
  - ✅ Detail Pendaftaran dinamis berdasarkan Poli yang dipilih
  - ✅ Status Antrean dengan informasi lengkap pasien
  - ✅ Riwayat Kunjungan dengan filter (Bulan & Poli) dan list pemeriksaan
  - ✅ Detail Riwayat Kunjungan lengkap (Keluhan, Hasil Pemeriksaan, Diagnosis, Tindakan, Resep Obat, Anjuran & Saran, Jadwal Kontrol)
  - ✅ Layanan Lainnya (Notifikasi & Pengingat, Lokasi Puskesmas, Info BPJS)
  - ✅ Notifikasi & Pengingat dengan list dan detail notifikasi
  - ✅ Lokasi Puskesmas Dau dengan informasi kontak lengkap
  - ✅ Info BPJS & Cara Klaim BPJS
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
- ✅ Admin Module:
  - ✅ Login page dengan Staff Selector
  - ✅ Dashboard dengan statistik dan quick access menu
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
  - ✅ Kelola Pengguna (List, Add, Edit user)
  - ✅ Laporan (Kunjungan Pasien, Stok Obat, Keuangan)
  - ✅ Laporan Statistik dengan chart
  - ✅ Notification System dengan 6 kategori (Laporan, Pengguna, Stok Obat)
- ✅ Dokter Module:
  - ✅ Login page
  - ✅ Dashboard dengan rekam medis hari ini
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
  - ✅ Form Pemeriksaan Pasien (Tanda Vital, Diagnosa, Resep Obat)
  - ✅ Rekam Medis Detail dengan riwayat pemeriksaan
  - ✅ Detail Pemeriksaan lengkap (Tanda Vital, Hasil Lab, Resep)
  - ✅ Notification System dengan 6 kategori (Antrian, Rekam Medis, Resep)
- ✅ Perawat Module:
  - ✅ Login page dengan StatefulWidget implementation
  - ✅ Dashboard dengan patient list dan statistik (Total, Sisa, Selesai)
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
  - ✅ Kelola Data Diri dengan form lengkap (Nama, NIK, Alamat, No HP, Email, Jenis Kelamin, Tanggal Lahir)
  - ✅ Kelola Kata Sandi dengan validasi dan visibility toggle
  - ✅ Form Rekam Medis dengan section (Identitas Pasien, Tanda Vital, Antropometri, Keluhan & Anamnesis)
  - ✅ Auto-calculate IMT di Antropometri section
  - ✅ Form validation dengan warning alert
- ✅ Apoteker Module:
  - ✅ Login page dengan validasi NIK dan kata sandi
  - ✅ Dashboard dengan monitoring stok obat real-time
  - ✅ Profile card dengan gradient turquoise
  - ✅ Alert Section (Stok Kritis & Peringatan Kedaluwarsa)
  - ✅ Status Stok Obat Real-Time (4 kategori: Aman, Hampir Habis, Kritis, Segera Expired)
  - ✅ Obat Sering Diresepkan dengan jumlah resep per bulan
  - ✅ Peringatan Obat page dengan detail:
    - ✅ Info box peringatan stok
    - ✅ List Stok Obat Kritis dengan jumlah tersisa
    - ✅ List Obat Mendekati Tanggal Kedaluwarsa
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
  - ✅ Integration dengan Staff Selector
- ✅ Global UI improvements:
  - ✅ ScrolledUnderElevation di semua AppBar
  - ✅ Consistent color scheme (#02B1BA primary, #FF4242 accent)
  - ✅ Responsive forms dengan validasi
  - ✅ Dynamic button berdasarkan status pasien

### ✅ Week 3 - Interaktivitas & Navigasi (1-7 Des 2025) - Completed

**Completed:**
- ✅ GetX Navigation System - Full migration dari Navigator ke GetX routing (Get.to, Get.back, Get.offAll, Get.toNamed, Get.offAllNamed) across all modules
- ✅ Form Validation & Input Handling - Real-time validation dengan error messages, focus management, input formatters untuk email, NIK, password, dan OTP
- ✅ Interactive Feedback - Loading states, button states (disabled, loading), SnackbarHelper untuk success/error messaging
- ✅ Password Recovery Flow - 3-step forgot password dengan email validation, OTP timer (60s), dan password reset confirmation
- ✅ UI Consistency & Polish - AppBar standardization (scrolledUnderElevation: 0), typography emphasis, form label alignment, responsive spacing

### 🚧 Week 4 - Integrasi Logika (8-14 Des 2025) - In Progress

**Progress:**
- ✅ GetX Architecture & State Management - GetView pattern implementation dengan controller lifecycle management, hybrid pattern (GetView + StatefulWidget) untuk animasi
- ✅ Local Storage Integration - StorageService dengan GetStorage untuk dummy data (no Firebase/Backend API), user authentication, session management dengan auto-login
- ✅ Business Logic Implementation:
  - ✅ Pasien Module - Login/Register/Dashboard controller logic, multi-field validation dengan error handling, auto-generate User ID & No Rekam Medis
  - ✅ Admin Module - Staff login validation dengan NIK/Password check, Kelola Pengguna (CRUD user dengan validation), multi-role user management (dokter, perawat, apoteker only), dashboard statistics integration
  - ✅ Dokter Module - Dashboard dengan 2-tab system (Saat Ini/Selesai), rekam medis detail dengan dynamic doctor assignment, form pemeriksaan pasien dengan compact UI, status-specific button logic (Sedang Diperiksa/Menunggu/Selesai)
  - ✅ Perawat & Apoteker Module - Staff login validation consistency across all roles
- ✅ Form Validation & Error Handling - Field-level error messages, general validation notification, email/NIK uniqueness check, password confirmation, staff NIK validation
- ✅ Data Management - Centralized PemeriksaanService untuk patient & examination data, dynamic doctor names dari logged-in user, auto-populate doctor field on form submit
- ✅ UI/UX Refinements - Loading states, success/error notifications dengan icon, smooth navigation flow (auto-login after registration), clean architecture pattern (MVC), compact form sections dengan QuarterCircleBackground consistency, status-based UI rendering
