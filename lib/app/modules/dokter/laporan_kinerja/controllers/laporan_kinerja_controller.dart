import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';

class DokterLaporanKinerjaController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  final isLoading = false.obs;
  final selectedPeriod = 'hari_ini'.obs; // semua, hari_ini, minggu_ini, bulan_ini, tahun_ini

  // Statistik
  final totalPasien = 0.obs;
  final totalDiperiksa = 0.obs;
  final pasienSelesai = 0.obs;
  final pasienMenunggu = 0.obs;
  final totalDiagnosa = 0.obs;
  final totalResep = 0.obs;
  final totalDibatalkan = 0.obs;
  final totalRujukan = 0.obs;

  // Detail per poli
  final pasienPerPoli = <Map<String, dynamic>>[].obs;
  
  // Diagnosa statistik
  final diagnosaTerbanyak = <Map<String, dynamic>>[].obs;

  // Statistik waktu
  final waktuTercepat = ''.obs;
  final waktuTerlama = ''.obs;
  final rataRataWaktu = ''.obs;

  // Getter untuk nama user
  String get userName => _sessionService.getNamaLengkap() ?? 'Dokter';

  // Getter untuk breakdown poli (Map<String, int>)
  Map<String, int> get poliBreakdown {
    final Map<String, int> result = {};
    for (var item in pasienPerPoli) {
      result[item['poli'] as String] = item['jumlah'] as int;
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    loadLaporanKinerja();
  }

  Future<void> loadLaporanKinerja() async {
    isLoading.value = true;

    try {
      // Gunakan firebaseUid, fallback ke userId untuk backward compatibility
      final dokterId = _sessionService.getFirebaseUid() ?? _sessionService.getUserId();
      final dokterName = _sessionService.getNamaLengkap() ?? 'Dokter';

      if (dokterId == null) {
        SnackbarHelper.showError('Session tidak ditemukan, silakan login ulang');
        return;
      }

      // Hitung range tanggal berdasarkan periode
      final now = DateTime.now();
      DateTime startDate;

      switch (selectedPeriod.value) {
        case 'hari_ini':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'minggu_ini':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'bulan_ini':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'tahun_ini':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      // Query antrian yang dihandle oleh dokter ini dalam periode tersebut
      QuerySnapshot antrianSnapshot;

      if (selectedPeriod.value == 'semua') {
        // Untuk periode 'semua', ambil semua data tanpa filter tanggal
        antrianSnapshot = await FirebaseFirestore.instance
            .collection('antrian')
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        antrianSnapshot = await FirebaseFirestore.instance
            .collection('antrian')
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .orderBy('createdAt', descending: true)
            .get();
      }

      // Filter data yang dihandle oleh dokter ini
      final antrianList = antrianSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Cek dari dokterData (untuk data yang sudah diperiksa)
        final dokterData = data['dokterData'];
        if (dokterData != null && dokterData is Map<String, dynamic>) {
          if (dokterData['dokterId'] == dokterId) {
            return true;
          }
        }

        // Cek dari dibatalkanOleh (untuk data yang dibatalkan oleh dokter)
        if (data['status'] == 'dibatalkan' && data['dibatalkanOleh'] == 'dokter') {
          final dibatalkanOlehId = data['dibatalkanOlehId'];
          final dibatalkanOlehNama = data['dibatalkanOlehNama'];

          // Match by ID atau nama (karena ID bisa kosong string di data lama)
          if (dibatalkanOlehId == dokterId ||
              (dibatalkanOlehId == '' && dibatalkanOlehNama == dokterName)) {
            return true;
          }
        }

        return false;
      }).toList();

      // Hitung statistik
      totalPasien.value = antrianList.length;

      totalDiperiksa.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final dokterData = data['dokterData'];
        return dokterData != null && dokterData is Map<String, dynamic>;
      }).length;

      pasienSelesai.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'];
        // Dari perspektif dokter, pasien dianggap selesai jika sudah diperiksa
        return status == 'selesai' ||
            status == 'selesai_diperiksa' ||
            status == 'siap_ambil_obat';
      }).length;

      pasienMenunggu.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'];
        // Pasien yang masih menunggu di tahap lain (bukan selesai dari dokter)
        return status == 'menunggu_apoteker' ||
            status == 'dilayani_apoteker';
      }).length;

      // Hitung diagnosa
      int diagnosaCount = 0;
      int resepCount = 0;
      int rujukanCount = 0;
      final Map<String, int> diagnosaMap = {};
      
      for (var doc in antrianList) {
        final data = doc.data() as Map<String, dynamic>;
        final dokterData = data['dokterData'];
        
        // Count diagnosa - dari dokterData atau root level
        final diagnosa = (dokterData is Map ? dokterData['diagnosis'] : null) ?? data['diagnosis'];
        if (diagnosa != null && diagnosa.toString().isNotEmpty && diagnosa != '-') {
          diagnosaCount++;
          // Track diagnosa frequency
          diagnosaMap[diagnosa.toString()] = (diagnosaMap[diagnosa.toString()] ?? 0) + 1;
        }
        
        // Count resep - dari root level (sumber kebenaran)
        final resepObat = data['resepObat'];
        if (resepObat != null && resepObat is List && resepObat.isNotEmpty) {
          resepCount++;
        }
        
        // Count rujukan
        final rujukan = dokterData is Map ? dokterData['rujukan'] : null;
        if (rujukan != null && rujukan.toString().isNotEmpty && rujukan != '-' && rujukan != 'Tidak Ada') {
          rujukanCount++;
        }
      }
      
      totalDiagnosa.value = diagnosaCount;
      totalResep.value = resepCount;
      totalRujukan.value = rujukanCount;

      // Top diagnosa
      final sortedDiagnosa = diagnosaMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      diagnosaTerbanyak.value = sortedDiagnosa.take(5).map((e) => {
        'diagnosa': e.key,
        'jumlah': e.value,
      }).toList();

      totalDibatalkan.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'dibatalkan';
      }).length;

      // Hitung pasien per poli
      final Map<String, int> poliCount = {};
      for (var doc in antrianList) {
        final data = doc.data() as Map<String, dynamic>;
        final poli = data['jenisLayanan'] ?? 'Tidak Diketahui';
        poliCount[poli] = (poliCount[poli] ?? 0) + 1;
      }

      pasienPerPoli.value = poliCount.entries
          .map((entry) => {
                'poli': entry.key,
                'jumlah': entry.value,
              })
          .toList();

      // Sort by jumlah descending
      pasienPerPoli.sort((a, b) => b['jumlah'].compareTo(a['jumlah']));

      // Hitung waktu pemeriksaan (dari menunggu_dokter ke selesai_diperiksa)
      final List<Duration> durations = [];
      for (var doc in antrianList) {
        final data = doc.data() as Map<String, dynamic>;
        final dokterData = data['dokterData'];
        if (dokterData != null && dokterData is Map<String, dynamic>) {
          final startedAt = dokterData['startedAt'];
          final examinedAt = dokterData['examinedAt'];
          if (startedAt != null && examinedAt != null) {
            final start = (startedAt as Timestamp).toDate();
            final end = (examinedAt as Timestamp).toDate();
            durations.add(end.difference(start));
          }
        }
      }

      if (durations.isNotEmpty) {
        durations.sort();
        waktuTercepat.value = _formatDuration(durations.first);
        waktuTerlama.value = _formatDuration(durations.last);

        final totalMinutes =
            durations.fold<int>(0, (sum, duration) => sum + duration.inMinutes);
        final avgMinutes = totalMinutes / durations.length;
        rataRataWaktu.value = '${avgMinutes.toStringAsFixed(0)} menit';
      } else {
        waktuTercepat.value = '-';
        waktuTerlama.value = '-';
        rataRataWaktu.value = '-';
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat laporan kinerja: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadLaporanKinerja();
  }

  Future<void> refreshData() async {
    await loadLaporanKinerja();
  }

  String get periodLabel {
    switch (selectedPeriod.value) {
      case 'semua':
        return 'Semua Waktu';
      case 'hari_ini':
        return 'Hari Ini';
      case 'minggu_ini':
        return 'Minggu Ini';
      case 'bulan_ini':
        return 'Bulan Ini';
      case 'tahun_ini':
        return 'Tahun Ini';
      default:
        return 'Hari Ini';
    }
  }

  // Hitung persentase pemeriksaan
  double get persentaseDiperiksa {
    if (totalPasien.value == 0) return 0;
    return (totalDiperiksa.value / totalPasien.value) * 100;
  }

  double get persentaseSelesai {
    if (totalPasien.value == 0) return 0;
    return (pasienSelesai.value / totalPasien.value) * 100;
  }

  // Hitung persentase dibatalkan
  double get persentaseDibatalkan {
    if (totalPasien.value == 0) return 0;
    return (totalDibatalkan.value / totalPasien.value) * 100;
  }
  
  // Hitung persentase resep
  double get persentaseResep {
    if (totalDiperiksa.value == 0) return 0;
    return (totalResep.value / totalDiperiksa.value) * 100;
  }
}
