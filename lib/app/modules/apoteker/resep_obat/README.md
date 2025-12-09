# Modul Resep Obat - Apoteker

## Deskripsi
Modul ini mengelola resep obat yang masuk dari dokter untuk disiapkan dan diserahkan oleh apoteker. Fitur ini mengikuti alur kerja puskesmas yang realistis.

## Struktur Folder
```
resep_obat/
├── controllers/
│   └── resep_obat_controller.dart    # GetX controller untuk state management
├── bindings/
│   └── resep_obat_binding.dart       # Dependency injection
└── views/
    ├── resep_obat_view.dart          # Halaman daftar resep
    └── detail_resep_view.dart        # Halaman detail resep
```

## Fitur Utama

### 1. Daftar Resep (resep_obat_view.dart)
- **Statistik Header**: Menampilkan jumlah resep menunggu dan selesai hari ini
- **Filter**: 3 kategori (Semua, Menunggu, Selesai)
- **List Resep**: Card untuk setiap resep dengan informasi:
  - ID Resep
  - Nama Pasien
  - No. Antrean
  - Poli & Dokter
  - Tanggal
  - Jumlah obat
  - Status (Menunggu/Selesai)

**Interaktivitas:**
- Hover effect pada filter chips
- Hover & press effect pada resep cards
- Smooth transitions

### 2. Detail Resep (detail_resep_view.dart)
- **Info Pasien**: Card gradient dengan data lengkap pasien
- **Daftar Obat**: 
  - Nama obat
  - Jumlah
  - Aturan pakai
  - Stok tersedia
- **Actions** (untuk resep menunggu):
  - Konfirmasi Penyerahan (hijau)
  - Batalkan Resep (merah outline)
- **Info Penyerahan** (untuk resep selesai): Tanggal penyerahan

**Interaktivitas:**
- Hover & scale effect pada tombol konfirmasi
- Hover effect pada tombol batal
- Confirmation dialog sebelum action

## Controller (resep_obat_controller.dart)

### Observable State
```dart
resepBelumSelesai: List resep dengan status "Menunggu"
resepSelesai: List resep dengan status "Selesai"
selectedFilter: Filter yang sedang aktif
```

### Computed Properties
```dart
filteredResep: Resep yang di-filter sesuai selectedFilter
countMenunggu: Jumlah resep menunggu
countSelesaiHariIni: Jumlah resep selesai hari ini
```

### Methods
```dart
changeFilter(String filter): Mengubah filter aktif
konfirmasiPenyerahan(String resepId): Konfirmasi penyerahan obat
batalkanResep(String resepId): Membatalkan resep
```

## Data Structure

### Resep Object
```dart
{
  'id': String,              // ID unik resep (RSP001, RSP002, ...)
  'noAntrean': String,       // No antrean pasien (A-012, G-015, ...)
  'namaPasien': String,      // Nama lengkap pasien
  'poli': String,            // Poli asal (Poli Umum, Poli Gigi, Poli KIA)
  'dokter': String,          // Nama dokter penulis resep
  'tanggal': String,         // Tanggal & waktu resep dibuat
  'tanggalSerah': String?,   // Tanggal & waktu penyerahan (jika selesai)
  'status': String,          // 'Menunggu' atau 'Selesai'
  'statusColor': Color,      // Warna status (Orange/Green)
  'jumlahObat': int,         // Jumlah jenis obat
  'daftarObat': List<Map>    // List obat dalam resep
}
```

### Obat Object (dalam daftarObat)
```dart
{
  'nama': String,       // Nama obat + dosis (Paracetamol 500mg)
  'jumlah': String,     // Jumlah & satuan (10 tablet, 1 botol)
  'aturan': String,     // Aturan pakai (3x sehari setelah makan)
  'stok': int          // Stok tersedia di apotek
}
```

## Navigasi

### Dari Dashboard Apoteker
```dart
// Tombol "Resep Obat" di Menu Utama
ResepObatBinding().dependencies();
Get.to(
  () => const ResepObatView(),
  transition: Transition.rightToLeft,
);
```

### Ke Detail Resep
```dart
// Tap pada resep card
Get.to(
  () => DetailResepView(resep: widget.resep),
  transition: Transition.rightToLeft,
);
```

## Workflow Apoteker

1. **Melihat Daftar Resep**
   - Apoteker membuka menu "Resep Obat"
   - Melihat statistik resep menunggu dan selesai
   - Filter resep sesuai kebutuhan

2. **Memproses Resep**
   - Tap pada resep untuk melihat detail
   - Cek daftar obat yang harus disiapkan
   - Cek stok tersedia untuk setiap obat
   - Siapkan obat sesuai jumlah dan aturan pakai

3. **Menyerahkan Obat**
   - Tap tombol "Konfirmasi Penyerahan"
   - Konfirmasi dialog muncul
   - Sistem memindahkan resep ke list "Selesai"
   - Snackbar success muncul

4. **Membatalkan Resep** (jika pasien tidak jadi ambil)
   - Tap tombol "Batalkan Resep"
   - Konfirmasi dialog muncul
   - Resep dihapus dari sistem
   - Snackbar info muncul

## Dependencies
- **GetX** ^4.7.2: State management & navigation
- **Flutter Material**: UI components
- **Custom Widgets**:
  - QuarterCircleBackground
  - ConfirmationDialog (utils/confirmation_dialog.dart)

## Color Scheme
- Primary: #02B1BA (Teal)
- Success: #4CAF50 (Green)
- Warning: #FF9800 (Orange)
- Danger: #FF4242 (Red)
- Background: #F5F5F5 (Light Gray)

## Animasi & Interaktivitas
- **AnimatedScale**: Tombol konfirmasi (1.02x hover, 0.95x press)
- **AnimatedContainer**: Filter chips, cards
- **Matrix4.translationValues**: Resep cards slide 4px on hover
- **Duration**: 150-200ms untuk responsiveness
- **Hover states**: Semua interactive elements
- **Press states**: Buttons & cards

## Future Enhancements
- [ ] Integrasi dengan Firebase Firestore
- [ ] Real-time updates resep baru
- [ ] Print label obat
- [ ] Scan barcode obat
- [ ] Riwayat penyerahan obat
- [ ] Notifikasi resep baru
- [ ] Filter by date range
- [ ] Search resep by nama/ID
- [ ] Export laporan resep
