import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResepObatController extends GetxController {
  // Observable list untuk resep yang belum diserahkan
  final resepBelumSelesai =
      <Map<String, dynamic>>[
        {
          'id': 'RSP001',
          'noAntrean': 'A-012',
          'namaPasien': 'Anisa Ayu',
          'poli': 'Poli Umum',
          'dokter': 'dr. Faizal Qadri',
          'tanggal': '15 Desember 2025, 09:15 WIB',
          'status': 'Menunggu',
          'statusColor': Color(0xFFFF9800),
          'jumlahObat': 3,
          'daftarObat': [
            {
              'nama': 'Paracetamol 500mg',
              'jumlah': '10 tablet',
              'aturan': '3x sehari setelah makan',
              'stok': 245,
            },
            {
              'nama': 'Amoxicillin 500mg',
              'jumlah': '15 kapsul',
              'aturan': '3x sehari sebelum makan',
              'stok': 98,
            },
            {
              'nama': 'Vitamin C 100mg',
              'jumlah': '20 tablet',
              'aturan': '1x sehari',
              'stok': 105,
            },
          ],
        },
        {
          'id': 'RSP002',
          'noAntrean': 'G-015',
          'namaPasien': 'Budi Santoso',
          'poli': 'Poli Gigi',
          'dokter': 'drg. Nisa Ayu',
          'tanggal': '15 Desember 2025, 10:30 WIB',
          'status': 'Menunggu',
          'statusColor': Color(0xFFFF9800),
          'jumlahObat': 2,
          'daftarObat': [
            {
              'nama': 'Asam Mefenamat 500mg',
              'jumlah': '12 tablet',
              'aturan': '3x sehari saat nyeri',
              'stok': 89,
            },
            {
              'nama': 'Chlorhexidine Mouthwash',
              'jumlah': '1 botol (200ml)',
              'aturan': 'Kumur 2x sehari',
              'stok': 34,
            },
          ],
        },
        {
          'id': 'RSP003',
          'noAntrean': 'K-008',
          'namaPasien': 'Siti Rahayu',
          'poli': 'Poli KIA',
          'dokter': 'dr. Siti Nurhaliza',
          'tanggal': '15 Desember 2025, 11:00 WIB',
          'status': 'Menunggu',
          'statusColor': Color(0xFFFF9800),
          'jumlahObat': 2,
          'daftarObat': [
            {
              'nama': 'Tablet Besi (Fe Sulfat)',
              'jumlah': '30 tablet',
              'aturan': '1x sehari setelah makan',
              'stok': 156,
            },
            {
              'nama': 'Asam Folat 1mg',
              'jumlah': '30 tablet',
              'aturan': '1x sehari',
              'stok': 178,
            },
          ],
        },
      ].obs;

  // Observable list untuk resep yang sudah diserahkan
  final resepSelesai =
      <Map<String, dynamic>>[
        {
          'id': 'RSP004',
          'noAntrean': 'A-008',
          'namaPasien': 'Dewi Lestari',
          'poli': 'Poli Umum',
          'dokter': 'dr. Faizal Qadri',
          'tanggal': '14 Desember 2025, 14:20 WIB',
          'tanggalSerah': '14 Desember 2025, 15:00 WIB',
          'status': 'Selesai',
          'statusColor': Color(0xFF4CAF50),
          'jumlahObat': 4,
          'daftarObat': [
            {
              'nama': 'Amoxicillin 500mg',
              'jumlah': '15 kapsul',
              'aturan': '3x sehari sebelum makan',
              'stok': 98,
            },
            {
              'nama': 'Paracetamol 500mg',
              'jumlah': '10 tablet',
              'aturan': '3x sehari saat demam',
              'stok': 245,
            },
            {
              'nama': 'OBH Sirup',
              'jumlah': '1 botol (60ml)',
              'aturan': '3x sehari 1 sendok makan',
              'stok': 67,
            },
            {
              'nama': 'Vitamin C 100mg',
              'jumlah': '20 tablet',
              'aturan': '1x sehari',
              'stok': 105,
            },
          ],
        },
        {
          'id': 'RSP005',
          'noAntrean': 'A-005',
          'namaPasien': 'Ahmad Ridwan',
          'poli': 'Poli Umum',
          'dokter': 'dr. Faizal Qadri',
          'tanggal': '14 Desember 2025, 13:15 WIB',
          'tanggalSerah': '14 Desember 2025, 13:45 WIB',
          'status': 'Selesai',
          'statusColor': Color(0xFF4CAF50),
          'jumlahObat': 2,
          'daftarObat': [
            {
              'nama': 'Metformin 500mg',
              'jumlah': '60 tablet',
              'aturan': '2x sehari setelah makan',
              'stok': 234,
            },
            {
              'nama': 'Glimepiride 1mg',
              'jumlah': '30 tablet',
              'aturan': '1x sehari pagi',
              'stok': 123,
            },
          ],
        },
      ].obs;

  // Filter status
  final RxString selectedFilter = 'Menunggu'.obs;
  final List<String> filterOptions = ['Semua', 'Menunggu', 'Selesai'];

  // Get filtered resep
  List<Map<String, dynamic>> get filteredResep {
    if (selectedFilter.value == 'Menunggu') {
      return resepBelumSelesai;
    } else if (selectedFilter.value == 'Selesai') {
      return resepSelesai;
    } else {
      return [...resepBelumSelesai, ...resepSelesai];
    }
  }

  // Count resep menunggu
  int get countMenunggu => resepBelumSelesai.length;

  // Count resep selesai hari ini
  int get countSelesaiHariIni => resepSelesai.length;

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Konfirmasi penyerahan obat
  void konfirmasiPenyerahan(String resepId) {
    final index = resepBelumSelesai.indexWhere((r) => r['id'] == resepId);
    if (index != -1) {
      final resep = Map<String, dynamic>.from(resepBelumSelesai[index]);

      // Update status
      resep['status'] = 'Selesai';
      resep['statusColor'] = Color(0xFF4CAF50);
      resep['tanggalSerah'] =
          '15 Desember 2025, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} WIB';

      // Pindahkan ke list selesai
      resepSelesai.insert(0, resep);

      // Hapus dari list belum selesai
      resepBelumSelesai.removeAt(index);

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Resep ${resep['id']} telah diserahkan kepada ${resep['namaPasien']}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Batalkan resep (jika pasien tidak jadi ambil)
  void batalkanResep(String resepId) {
    final index = resepBelumSelesai.indexWhere((r) => r['id'] == resepId);
    if (index != -1) {
      final resep = resepBelumSelesai[index];

      Get.back();
      Get.snackbar(
        'Dibatalkan',
        'Resep ${resep['id']} untuk ${resep['namaPasien']} telah dibatalkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      resepBelumSelesai.removeAt(index);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize data jika diperlukan
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
