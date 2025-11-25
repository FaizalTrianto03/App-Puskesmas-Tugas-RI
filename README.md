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

| Kelas | NIM | Nama Lengkap |
|-------|-----|--------------|
| RI-A | 202210370311009 | Anisa Ayu Nabila Nur Rahmah |
| RI-A | 202210370311015 | Faizal Qadri Trianto |
| RI-B | 202210370311021 | Dias Aditama |
| RI-B | 202210370311023 | Mukarram Luthfi Al Manfaluti |

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

### 🔄 Week 2 - Implementasi Layout UI (24-30 Nov 2025) - In Progress

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
- ✅ Dokter Module:
  - ✅ Login page
  - ✅ Dashboard dengan rekam medis hari ini
  - ✅ Settings page (Kelola Data Diri, Kelola Kata Sandi)
  - ✅ Form Pemeriksaan Pasien (Tanda Vital, Diagnosa, Resep Obat)
  - ✅ Rekam Medis Detail dengan riwayat pemeriksaan
  - ✅ Detail Pemeriksaan lengkap (Tanda Vital, Hasil Lab, Resep)
- ✅ Global UI improvements:
  - ✅ ScrolledUnderElevation di semua AppBar
  - ✅ Consistent color scheme (#02B1BA primary, #FF4242 accent)
  - ✅ Responsive forms dengan validasi
  - ✅ Dynamic button berdasarkan status pasien

**In Progress:**
- 🔄 Perawat Module (UI only)
- 🔄 Apoteker Module (UI only)

---

## 📱 Development Branch

- `main` - Production ready code
- `Minggu-1-SetupProject` - Week 1 setup ✅
- `Minggu-2-ImplementasiLayoutUI` - Week 2 UI implementation 🔄 (current)

---

📌 *Project ini dikembangkan untuk memenuhi tugas mata kuliah Rekayasa Interaksi dan sebagai studi penerapan Flutter dalam digitalisasi layanan puskesmas melalui aplikasi mobile.*

**Last Updated:** November 24, 2025  
**Status:** Week 2 - Layout UI Implementation In Progress 🔄
