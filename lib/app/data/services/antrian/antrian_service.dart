import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AntreanService extends GetxService {
  final GetStorage _storage = GetStorage();
  
  static const String _antreanKey = 'antrian_list';
  static const String _counterKey = 'antrian_counter';
  
  Future<AntreanService> init() async {
    if (_storage.read(_antreanKey) == null) {
      await _storage.write(_antreanKey, <Map<String, dynamic>>[]);
    }
    if (_storage.read(_counterKey) == null) {
      await _storage.write(_counterKey, 0);
    }
    
    // Initialize dummy data G-009 jika belum ada
    await _initDummyG009();
    
    return this;
  }

  Future<void> _initDummyG009() async {
    final existing = getAllAntrian();
    
    // Cek apakah sudah ada antrian G-009
    final hasG009 = existing.any((a) => a['queueNumber'] == 'G-009');
    if (hasG009) return;
    
    final now = DateTime.now();
    
    final antrian = {
      'id': 'G-009',
      'queueNumber': 'G-009',
      'pasienId': 'P001',
      'namaLengkap': 'Anisa Ayu',
      'noRekamMedis': 'RM001',
      'jenisLayanan': 'Umum',
      'keluhan': 'Demam dan batuk sejak 3 hari',
      'nomorBPJS': null,
      'status': 'menunggu_verifikasi',
      'tanggalDaftar': now.toIso8601String(),
      'estimasiWaktu': now.add(Duration(minutes: 30)).toIso8601String(),
      'verifiedBy': null,
      'verifiedAt': null,
      'dokterName': null,
      'poliklinik': 'Poli Umum',
      'prioritas': 'normal',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    
    existing.add(antrian);
    await _storage.write(_antreanKey, existing);
  }

  String _generateQueueNumber() {
    int counter = _storage.read(_counterKey) ?? 0;
    counter++;
    _storage.write(_counterKey, counter);
    
    final now = DateTime.now();
    final datePrefix = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'A$datePrefix${counter.toString().padLeft(3, '0')}';
  }

  Future<Map<String, dynamic>> createAntrian({
    required String pasienId,
    required String email,
    required String namaLengkap,
    required String noRekamMedis,
    required String jenisLayanan,
    required String keluhan,
    String? nomorBPJS,
  }) async {
    final queueNumber = _generateQueueNumber();
    final now = DateTime.now();
    
    final antrian = {
      'id': queueNumber,
      'queueNumber': queueNumber,
      'pasienId': pasienId,
      'email': email,
      'namaLengkap': namaLengkap,
      'noRekamMedis': noRekamMedis,
      'jenisLayanan': jenisLayanan,
      'keluhan': keluhan,
      'nomorBPJS': nomorBPJS,
      'status': 'menunggu_verifikasi',
      'tanggalDaftar': now.toIso8601String(),
      'estimasiWaktu': now.add(Duration(minutes: 30)).toIso8601String(),
      'verifiedBy': null,
      'verifiedAt': null,
      'dokterName': null,
      'poliklinik': _getPoliklinikFromLayanan(jenisLayanan),
      'prioritas': nomorBPJS != null ? 'normal' : 'normal',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    
    List<Map<String, dynamic>> antrianList = getAllAntrian();
    antrianList.add(antrian);
    await _storage.write(_antreanKey, antrianList);
    
    return antrian;
  }

  String _getPoliklinikFromLayanan(String jenisLayanan) {
    switch (jenisLayanan.toLowerCase()) {
      case 'umum':
        return 'Poli Umum';
      case 'gigi':
        return 'Poli Gigi';
      case 'kb':
        return 'Poli KB';
      case 'lansia':
        return 'Poli Lansia';
      case 'imunisasi':
        return 'Poli Imunisasi';
      default:
        return 'Poli Umum';
    }
  }

  Future<bool> verifikasiAntrian({
    required String antrianId,
    required String perawatId,
    required String perawatName,
    String? catatan,
  }) async {
    List<Map<String, dynamic>> antrianList = getAllAntrian();
    final index = antrianList.indexWhere((a) => a['id'] == antrianId);
    
    if (index == -1) return false;
    
    antrianList[index]['status'] = 'menunggu_dokter';
    antrianList[index]['verifiedBy'] = perawatId;
    antrianList[index]['verifiedByName'] = perawatName;
    antrianList[index]['verifiedAt'] = DateTime.now().toIso8601String();
    antrianList[index]['catatanPerawat'] = catatan;
    antrianList[index]['updatedAt'] = DateTime.now().toIso8601String();
    
    await _storage.write(_antreanKey, antrianList);
    return true;
  }

  Future<bool> assignDokter({
    required String antrianId,
    required String dokterId,
    required String dokterName,
  }) async {
    List<Map<String, dynamic>> antrianList = getAllAntrian();
    final index = antrianList.indexWhere((a) => a['id'] == antrianId);
    
    if (index == -1) return false;
    
    antrianList[index]['status'] = 'sedang_dilayani';
    antrianList[index]['dokterId'] = dokterId;
    antrianList[index]['dokterName'] = dokterName;
    antrianList[index]['mulaiDilayani'] = DateTime.now().toIso8601String();
    antrianList[index]['updatedAt'] = DateTime.now().toIso8601String();
    
    await _storage.write(_antreanKey, antrianList);
    return true;
  }

  Future<bool> selesaiPelayanan({
    required String antrianId,
    String? diagnosis,
    String? tindakan,
    String? resep,
  }) async {
    List<Map<String, dynamic>> antrianList = getAllAntrian();
    final index = antrianList.indexWhere((a) => a['id'] == antrianId);
    
    if (index == -1) return false;
    
    antrianList[index]['status'] = 'selesai';
    antrianList[index]['diagnosis'] = diagnosis;
    antrianList[index]['tindakan'] = tindakan;
    antrianList[index]['resep'] = resep;
    antrianList[index]['selesaiDilayani'] = DateTime.now().toIso8601String();
    antrianList[index]['updatedAt'] = DateTime.now().toIso8601String();
    
    await _storage.write(_antreanKey, antrianList);
    return true;
  }

  Future<bool> batalkanAntrian(String antrianId, String alasan) async {
    List<Map<String, dynamic>> antrianList = getAllAntrian();
    final index = antrianList.indexWhere((a) => a['id'] == antrianId);
    
    if (index == -1) return false;
    
    antrianList[index]['status'] = 'dibatalkan';
    antrianList[index]['alasanBatal'] = alasan;
    antrianList[index]['updatedAt'] = DateTime.now().toIso8601String();
    
    await _storage.write(_antreanKey, antrianList);
    return true;
  }

  List<Map<String, dynamic>> getAllAntrian() {
    final data = _storage.read(_antreanKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  List<Map<String, dynamic>> getAntrianByPasienId(String pasienId) {
    return getAllAntrian()
        .where((a) => a['pasienId'] == pasienId)
        .toList();
  }

  List<Map<String, dynamic>> getAntrianByStatus(String status) {
    return getAllAntrian()
        .where((a) => a['status'] == status)
        .toList();
  }

  List<Map<String, dynamic>> getAntrianByDokterId(String dokterId) {
    return getAllAntrian()
        .where((a) => a['dokterId'] == dokterId && a['status'] == 'menunggu_dokter')
        .toList();
  }

  Map<String, dynamic>? getAntrianById(String antrianId) {
    final list = getAllAntrian();
    try {
      return list.firstWhere((a) => a['id'] == antrianId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getActiveAntrianByPasienId(String pasienId) {
    final list = getAllAntrian();
    try {
      return list.firstWhere(
        (a) => a['pasienId'] == pasienId && 
               (a['status'] == 'menunggu_verifikasi' || 
                a['status'] == 'menunggu_dokter' || 
                a['status'] == 'sedang_dilayani'),
      );
    } catch (e) {
      return null;
    }
  }

  int getQueuePosition(String antrianId) {
    final waiting = getAntrianByStatus('menunggu_dokter');
    final index = waiting.indexWhere((a) => a['id'] == antrianId);
    return index == -1 ? 0 : index + 1;
  }

  Future<void> clearAllAntrian() async {
    await _storage.write(_antreanKey, <Map<String, dynamic>>[]);
    await _storage.write(_counterKey, 0);
  }
}
