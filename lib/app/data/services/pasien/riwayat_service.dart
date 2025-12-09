import 'package:get_storage/get_storage.dart';

class RiwayatService {
  static final RiwayatService _instance = RiwayatService._internal();
  factory RiwayatService() => _instance;
  RiwayatService._internal();

  final GetStorage _box = GetStorage();

  // Initialize Dummy Riwayat
  Future<void> initDummyRiwayat() async {
    final riwayat = _box.read('riwayat_P001') as List<dynamic>?;
    if (riwayat == null || riwayat.isEmpty) {
      await _box.write('riwayat_P001', [
        {
          'id': 'RK001',
          'tanggal': '2024-11-15',
          'poli': 'Poli Umum',
          'dokter': 'dr. Ahmad Hidayat, Sp.PD',
          'keluhan': 'Demam tinggi, batuk',
          'diagnosis': 'ISPA (Infeksi Saluran Pernapasan Akut)',
          'tindakan': 'Pemberian obat penurun demam dan antibiotik',
          'resepObat': [
            {'nama': 'Paracetamol 500mg', 'jumlah': '10 tablet', 'aturan': '3x sehari'},
            {'nama': 'Amoxicillin 500mg', 'jumlah': '15 kapsul', 'aturan': '3x sehari'},
          ],
          'anjuran': 'Istirahat cukup, minum air putih minimal 2 liter/hari',
          'jadwalKontrol': '2024-11-22',
        },
        {
          'id': 'RK002',
          'tanggal': '2024-10-10',
          'poli': 'Poli Gigi',
          'dokter': 'drg. Siti Nurhaliza',
          'keluhan': 'Gigi berlubang',
          'diagnosis': 'Karies dentis',
          'tindakan': 'Penambalan gigi',
          'resepObat': [
            {'nama': 'Asam Mefenamat 500mg', 'jumlah': '6 tablet', 'aturan': '3x sehari sesudah makan'},
          ],
          'anjuran': 'Hindari makanan keras, sikat gigi teratur',
          'jadwalKontrol': null,
        },
      ]);
    }
  }

  // READ
  List<Map<String, dynamic>> getRiwayatByUserId(String userId) {
    final riwayat = _box.read('riwayat_$userId') as List<dynamic>?;
    if (riwayat == null) return [];
    return riwayat.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? getRiwayatById(String userId, String riwayatId) {
    final riwayatList = getRiwayatByUserId(userId);
    try {
      return riwayatList.firstWhere((r) => r['id'] == riwayatId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getRiwayatByPoli(String userId, String poli) {
    final riwayatList = getRiwayatByUserId(userId);
    return riwayatList.where((r) => r['poli'] == poli).toList();
  }

  List<Map<String, dynamic>> getRiwayatByMonth(String userId, int month, int year) {
    final riwayatList = getRiwayatByUserId(userId);
    return riwayatList.where((r) {
      final tanggal = DateTime.parse(r['tanggal']);
      return tanggal.month == month && tanggal.year == year;
    }).toList();
  }

  // CREATE
  Future<void> addRiwayat(String userId, Map<String, dynamic> riwayatData) async {
    final riwayatList = getRiwayatByUserId(userId);
    riwayatList.add(riwayatData);
    await _box.write('riwayat_$userId', riwayatList);
  }

  // UPDATE
  Future<bool> updateRiwayat(String userId, String riwayatId, Map<String, dynamic> updates) async {
    final riwayatList = getRiwayatByUserId(userId);
    final index = riwayatList.indexWhere((r) => r['id'] == riwayatId);
    
    if (index == -1) return false;
    
    riwayatList[index] = {...riwayatList[index], ...updates};
    await _box.write('riwayat_$userId', riwayatList);
    return true;
  }

  // DELETE
  Future<bool> deleteRiwayat(String userId, String riwayatId) async {
    final riwayatList = getRiwayatByUserId(userId);
    final initialLength = riwayatList.length;
    riwayatList.removeWhere((r) => r['id'] == riwayatId);
    
    if (riwayatList.length < initialLength) {
      await _box.write('riwayat_$userId', riwayatList);
      return true;
    }
    return false;
  }
}
