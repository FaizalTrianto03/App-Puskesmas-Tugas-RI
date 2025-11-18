# 🏥 Tugas Rekayasa Interaksi — Aplikasi Puskesmas

Project ini merupakan tugas mata kuliah **Rekayasa Interaksi** dengan tema **Aplikasi Puskesmas**.  
Aplikasi dikembangkan menggunakan **Flutter** dan **Firebase** dengan sistem multi-role authentication untuk berbagai pengguna (Pasien, Dokter, Perawat, Apoteker, Admin).

Repository: https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI

---

## 💡 Deskripsi Project

Aplikasi Puskesmas ini dirancang untuk mempermudah akses layanan kesehatan bagi masyarakat dan staff medis.  

### Fitur Utama:
- **Multi-role System** - 5 role berbeda (Pasien, Dokter, Perawat, Apoteker, Admin)
- **Pendaftaran Online** - Pasien dapat mendaftar secara daring
- **Monitoring Pasien** - Daftar pasien yang mengantri ke dokter
- **Rekam Medis Terintegrasi** - Akses riwayat rekam medis pasien
- **Riwayat Kunjungan** - Tracking riwayat kunjungan pasien ke puskesmas
- **Manajemen Antrian** - Sistem antrian digital
- **Manajemen Obat** - Pengelolaan resep dan stok obat
- **Firebase Integration** - Real-time database dan authentication

Project ini berfokus pada penerapan antarmuka yang intuitif, kemudahan interaksi, serta pengalaman pengguna yang efisien dan ramah.

---

## 👥 Anggota Kelompok

| Nama Lengkap | NIM |
|---------------|--------------------|
| Anisa Ayu Nabila Nur Rahmah | 202210370311009 |
| Faizal Qadri Trianto | 202210370311015 |
| Dias Aditama | 202210370311021 |
| Mukarram Luthfi Al Manfaluti | 202210370311023 |

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
- ✅ Base utilities (AppColors, AppTextStyles)
- ✅ Documentation

---

## 📱 Development Branch

- `main` - Production ready code
- `Minggu-1-SetupProject` - Week 1 setup ✅ (current)

---

📌 *Project ini dikembangkan untuk memenuhi tugas mata kuliah Rekayasa Interaksi dan sebagai studi penerapan teknologi Flutter dalam pengembangan aplikasi layanan kesehatan.*

**Last Updated:** November 18, 2025  
**Status:** Week 1 - Setup Project (current) ✅
