import 'package:get/get.dart';

import '../../../../data/models/riwayat_kunjungan_model.dart';
import '../../../../data/services/firestore/riwayat_firestore_service.dart';

class DetailRiwayatController extends GetxController {
  final RiwayatFirestoreService _riwayatService = RiwayatFirestoreService();
  
  final riwayat = Rxn<RiwayatKunjunganModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get data from arguments - could be RiwayatKunjunganModel or riwayatId string
    final args = Get.arguments;
    
    if (args is RiwayatKunjunganModel) {
      riwayat.value = args;
    } else if (args is String) {
      // Load by ID
      loadRiwayatById(args);
    }
  }

  Future<void> loadRiwayatById(String riwayatId) async {
    try {
      isLoading.value = true;
      final data = await _riwayatService.getRiwayatById(riwayatId);
      riwayat.value = data;
    } catch (e) {
      print('Error loading riwayat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Getter untuk backward compatibility dengan view yang menggunakan data['field']
  Map<String, dynamic> get data {
    if (riwayat.value == null) return {};
    
    final r = riwayat.value!;
    return {
      'poli': r.poli,
      'tanggal': _formatTanggal(r.tanggalKunjungan),
      'noAntrean': r.noAntrean,
      'dokter': r.dokter,
      'keluhan': r.keluhan,
      'diagnosis': r.diagnosis,
      'tindakan': r.tindakan,
      'resep': r.resep?.map((e) => '${e.nama} - ${e.dosis} - ${e.aturan}').toList() ?? [],
      'kontrolDate': r.kontrolDate != null ? _formatTanggal(r.kontrolDate!) : null,
    };
  }

  String _formatTanggal(DateTime date) {
    final months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
