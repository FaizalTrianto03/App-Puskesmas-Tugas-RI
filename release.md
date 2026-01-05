# Aplikasi Puskesmas Dau - Release Notes

## Version 1.0.0

**Release Date:** January 5, 2026  
**Project Type:** Mobile Application (Cross-platform)  
**Technology:** Flutter & Firebase

---

## Tentang Aplikasi

**Aplikasi Puskesmas Dau** adalah sistem informasi kesehatan berbasis mobile yang dirancang untuk meningkatkan efisiensi pelayanan di Puskesmas. Aplikasi ini mengintegrasikan seluruh proses pelayanan kesehatan mulai dari pendaftaran pasien, antrian, pemeriksaan, hingga manajemen rekam medis dalam satu platform digital yang mudah digunakan.

Aplikasi ini dikembangkan sebagai tugas mata kuliah **Rekayasa Interaksi** dengan fokus pada desain antarmuka yang intuitif dan pengalaman pengguna yang optimal untuk berbagai kalangan pengguna.

---

## Fitur Utama

### Multi-Role Authentication System
Sistem autentikasi berbasis Firebase yang mendukung 5 role berbeda:
- **Pasien** - Akses layanan kesehatan dan kartu kesehatan digital
- **Dokter** - Pemeriksaan pasien dan rekam medis
- **Perawat** - Manajemen antrian dan data pasien
- **Apoteker** - Pengelolaan resep dan stok obat
- **Admin** - Manajemen sistem dan pengguna

### Fitur Pasien
- **Kartu Kesehatan Digital**
  - Kartu identitas kesehatan Puskesmas Dau
  - Menampilkan NIK, No. Rekam Medis, masa berlaku
  - Akses kapan saja tanpa kartu fisik
  
- **Pendaftaran Online**
  - Form pendaftaran dengan pilihan Poli
  - Input keluhan dan gejala
  - Detail pendaftaran dinamis
  - Konfirmasi pendaftaran real-time

- **Status Antrian Real-time**
  - Monitoring nomor antrian saat ini
  - Estimasi waktu tunggu
  - Notifikasi panggilan antrian
  - Status per Poli

- **Riwayat Kunjungan**
  - History pemeriksaan lengkap
  - Detail diagnosis dan tindakan
  - Daftar resep obat
  - Catatan medis dari dokter

- **Layanan Lainnya**
  - Info BPJS dan Jaminan Kesehatan
  - Lokasi Puskesmas dengan Maps
  - Kontak dan informasi layanan
  - Notifikasi kesehatan

### Fitur Dokter
- **Data Pasien**
  - Daftar pasien dalam antrian
  - Detail informasi pasien
  - Riwayat kunjungan sebelumnya
  - Akses rekam medis lengkap

- **Pemeriksaan Pasien**
  - Form pemeriksaan terstruktur
  - Input diagnosis (ICD-10)
  - Tindakan medis
  - Resep obat digital
  - Catatan khusus

- **Rekam Medis**
  - Akses riwayat rekam medis
  - Search dan filter pasien
  - Update status pemeriksaan
  - Integrasi dengan sistem antrian

- **Jadwal Praktek**
  - Kelola jadwal praktek
  - Info Poli dan waktu praktek
  - Kalender interaktif

- **Laporan Kinerja**
  - Statistik pasien yang diperiksa
  - Laporan harian/bulanan
  - Grafik visualisasi data

### Fitur Perawat
- **Monitoring Antrian**
  - Daftar antrian real-time semua Poli
  - Panggil pasien berikutnya
  - Update status antrian
  - Filter per Poli

- **Manajemen Pasien**
  - Pendaftaran pasien baru
  - Update data pasien
  - Verifikasi kartu kesehatan
  - Input data awal pemeriksaan

- **Riwayat Pemeriksaan**
  - Akses history pemeriksaan
  - Detail kunjungan pasien
  - Export data pemeriksaan

### Fitur Apoteker
- **Manajemen Resep**
  - Daftar resep dari dokter
  - Verifikasi resep
  - Status penyiapan obat
  - Catatan pengambilan obat

- **Manajemen Stok Obat**
  - Database obat lengkap
  - Monitoring stok real-time
  - Alert stok menipis
  - Update stok masuk/keluar

- **Laporan Farmasi**
  - Laporan pemakaian obat
  - Statistik resep
  - Grafik obat populer

### Fitur Admin
- **Manajemen Pengguna**
  - CRUD user untuk semua role
  - Aktivasi/deaktivasi akun
  - Reset password
  - Monitoring aktivitas user

- **Kelola Data Master**
  - Manajemen Poli
  - Manajemen Ruangan
  - Kelola Informasi Puskesmas
  - Setting sistem

- **Laporan & Statistik**
  - Dashboard statistik lengkap
  - Laporan kunjungan pasien
  - Laporan keuangan
  - Grafik visualisasi data
  - Export data (PDF/Excel)

- **Kelola Informasi**
  - Update info layanan
  - Pengumuman
  - Jam operasional
  - Kontak Puskesmas

---

## Tech Stack

### Frontend
- **Flutter 3.7.0** - Cross-platform UI Framework
- **Dart SDK ^3.7.0** - Programming Language
- **GetX 4.7.3** - State Management, Routing, & Dependency Injection
- **Google Fonts** (Poppins) - Typography

### Backend & Database
- **Firebase Core 3.0.0** - Firebase Integration
- **Firebase Auth 5.0.0** - Authentication System
- **Cloud Firestore 5.0.0** - Real-time NoSQL Database

### Libraries & Packages
- **UI & Animation**
  - animate_do 3.3.4 - Animations
  - lottie 3.1.2 - Lottie Animations
  - flutter_svg 2.0.10+1 - SVG Support
  
- **Maps & Location**
  - flutter_map 7.0.2 - Map Integration
  - latlong2 0.9.1 - Coordinate System
  - geolocator 13.0.2 - Location Services
  - permission_handler 11.3.1 - Permissions
  - url_launcher 6.3.0 - External Links

- **Storage**
  - shared_preferences 2.2.3 - Local Preferences
  - get_storage 2.1.1 - Key-Value Storage
  - flutter_dotenv 5.1.0 - Environment Variables

- **Other**
  - intl 0.19.0 - Internationalization
  - audioplayers 6.1.0 - Audio Support
  - cupertino_icons 1.0.8 - iOS Icons

---

## Platform Support

- **Android** (SDK 21+)
- **iOS** (iOS 12+)
- **Web** (Progressive Web App)
- **Windows** (Desktop)
- **Linux** (Desktop)
- **macOS** (Desktop)

---

## Instalasi & Setup

### Prerequisites
```bash
- Flutter SDK 3.7.0 atau lebih tinggi
- Dart SDK 3.7.0 atau lebih tinggi
- Android Studio / Xcode (untuk mobile development)
- Firebase Project dengan Authentication & Firestore enabled
```

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI.git
   cd App-Puskesmas-Tugas-RI
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Environment Variables**
   - Copy file `env.example` menjadi `.env`
   - Isi konfigurasi Firebase sesuai project Anda

4. **Configure Firebase**
   - Tambahkan `google-services.json` di folder `android/app/`
   - Tambahkan `GoogleService-Info.plist` di folder `ios/Runner/`
   - File `firebase_options.dart` sudah dikonfigurasi

5. **Run Application**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   ```

---

## Struktur Project

```
lib/
├── app/
│   ├── data/
│   │   ├── models/          # Data models (User, Pasien, Antrian, dll)
│   │   ├── services/        # Business logic (Auth, Antrian, Storage)
│   │   └── repositories/    # Data repositories
│   │
│   ├── modules/
│   │   ├── common/          # Shared modules (Login, Register, Splash)
│   │   ├── pasien/          # Patient features
│   │   ├── dokter/          # Doctor features
│   │   ├── perawat/         # Nurse features
│   │   ├── apoteker/        # Pharmacist features
│   │   ├── admin/           # Admin features
│   │   └── splash/          # Splash screen
│   │
│   ├── routes/
│   │   ├── app_pages.dart   # Route definitions
│   │   └── app_routes.dart  # Route names
│   │
│   ├── utils/
│   │   ├── colors.dart      # Color constants
│   │   ├── text_styles.dart # Text style definitions
│   │   └── helpers.dart     # Helper functions
│   │
│   └── widgets/             # Reusable custom widgets
│
├── firebase_options.dart    # Firebase configuration
└── main.dart               # App entry point

assets/
├── audio/                  # Audio files
├── data/                   # JSON data files
├── fonts/                  # Custom fonts
├── icons/                  # SVG icons
└── images/                 # Image assets
```

---

## Tim Pengembangan

| Nama | NIM | Kelas | Role Development | GitHub |
|------|-----|-------|------------------|--------|
| Faizal Qadri Trianto | 202210370311015 | RI-A | Admin & Dokter | [@FaizalTrianto03](https://github.com/FaizalTrianto03) |
| Anisa Ayu Nabila Nur Rahmah | 202210370311009 | RI-A | Pasien | [@anisaayu05](https://github.com/anisaayu05) |
| Mukarram Luthfi Al Manfaluti | 202210370311023 | RI-B | Perawat | [@MukarramLuthfiAlManfaluti](https://github.com/MukarramLuthfiAlManfaluti) |
| Dias Aditama | 202210370311021 | RI-B | Apoteker | [@DiasAditama](https://github.com/DiasAditama) |

**Mata Kuliah:** Rekayasa Interaksi  
**Institusi:** Universitas Muhammadiyah Malang  
**Tahun Akademik:** 2025

---

## Design Resources

- **Figma Design:** [Kelompok RI 2025](https://www.figma.com/design/kdsNWqjifLP8TWPkgRJcAG/Kelompok-RI-2025)
- **Low Fidelity Prototype:** [Google Drive](https://drive.google.com/file/d/1O8NTeDy47PVV7leIOyzP6TmgozzTHsXq/view)
- **Worksheet & Documentation:** [Google Drive Folder](https://drive.google.com/drive/folders/1PZvS_4ZE1ak_icvMJBJx_kjj01GUnqye)

---

## Security Features

- Firebase Authentication dengan Email/Password
- Role-based Access Control (RBAC)
- Session Management dengan GetStorage
- Secure data transmission (HTTPS)
- Environment variable untuk sensitive data
- Input validation & sanitization
- Firestore Security Rules

---

## Key Metrics

- **Total Modules:** 7 (Admin, Dokter, Perawat, Apoteker, Pasien, Common, Splash)
- **Total Features:** 40+ fitur terintegrasi
- **Code Quality:** Flutter Lints enabled
- **Platform Support:** 6 platforms (Android, iOS, Web, Windows, Linux, macOS)
- **UI Components:** Custom reusable widgets dengan GetX
- **Database:** Cloud Firestore (NoSQL, Real-time)
- **Authentication:** Firebase Auth (Multi-role)

---

## Known Issues & Limitations

### Current Version (1.0.0)
- Aplikasi memerlukan koneksi internet untuk berfungsi penuh (Firebase dependency)
- Beberapa fitur masih dalam tahap pengembangan
- Belum ada fitur offline mode
- Export laporan masih terbatas format

### Future Improvements
- [ ] Offline mode dengan local database sync
- [ ] Push notification untuk panggilan antrian
- [ ] Export laporan dalam format PDF & Excel
- [ ] Integrasi dengan sistem pembayaran
- [ ] Chat/konsultasi online dengan dokter
- [ ] Appointment scheduling system
- [ ] Multi-language support (English, etc)
- [ ] Dark mode theme

---

## Changelog

### Version 1.0.0 (January 5, 2026)
#### Initial Release
- Multi-role authentication system (5 roles)
- Kartu kesehatan digital untuk pasien
- Sistem pendaftaran online
- Antrian real-time dengan Firebase
- Rekam medis terintegrasi
- Dashboard untuk semua role
- Manajemen pengguna oleh admin
- Laporan dan statistik dengan visualisasi
- Maps integration untuk lokasi Puskesmas
- Responsive UI untuk semua ukuran layar
- Animasi dan transisi smooth (Animate Do & Lottie)
- Google Fonts integration (Poppins)
- Cross-platform support (6 platforms)

---

## Contributing

Project ini merupakan tugas akademik. Untuk kontribusi atau saran:

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## License

Project ini dibuat untuk keperluan akademik mata kuliah Rekayasa Interaksi.  
© 2026 Kelompok RI - Universitas Muhammadiyah Malang

---

## Contact & Support

Untuk pertanyaan atau dukungan:
- **Repository:** [GitHub](https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI)
- **Issues:** [GitHub Issues](https://github.com/FaizalTrianto03/App-Puskesmas-Tugas-RI/issues)
- **Email:** Contact via GitHub profile

---

## Acknowledgments

Terima kasih kepada:
- **Dosen Pengampu** mata kuliah Rekayasa Interaksi
- **Firebase** untuk platform backend yang powerful
- **Flutter Team** untuk framework yang luar biasa
- **Komunitas Open Source** untuk packages dan libraries
- **Tim Pengembang** yang telah bekerja keras dalam project ini

---

## Screenshots

> *Note: Tambahkan screenshots aplikasi di sini untuk showcase*

### Pasien
- Dashboard & Kartu Kesehatan
- Pendaftaran Online
- Status Antrian
- Riwayat Kunjungan

### Dokter
- Dashboard Dokter
- Pemeriksaan Pasien
- Rekam Medis
- Laporan Kinerja

### Admin
- Dashboard Admin
- Manajemen Pengguna
- Laporan Statistik
- Kelola Data Master

---

## Project Goals Achieved

- **User Experience:** Interface intuitif dan mudah digunakan untuk semua kalangan  
- **Accessibility:** Desain responsif untuk berbagai ukuran layar  
- **Performance:** Aplikasi ringan dan cepat  
- **Scalability:** Arsitektur modular yang mudah dikembangkan  
- **Security:** Implementasi authentication dan authorization yang aman  
- **Integration:** Firebase real-time untuk sinkronisasi data  
- **Cross-platform:** Support untuk 6 platform berbeda  

---

**Made with love by Tim Rekayasa Interaksi 2025**

*Puskesmas Dau - Meningkatkan Pelayanan Kesehatan Melalui Teknologi Digital*
