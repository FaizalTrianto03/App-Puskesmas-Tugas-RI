import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/antrian_model.dart';

class AntrianFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _antrianCollection => _firestore.collection('antrian');

  // Generate nomor antrian
  Future<String> _generateQueueNumber(String poli) async {
    final today = DateTime.now();
    final dateStr = '${today.day}${today.month}${today.year}';
    
    // Get count antrian hari ini untuk poli tertentu
    final querySnapshot = await _antrianCollection
        .where('jenisLayanan', isEqualTo: poli)
        .where('createdAt', isGreaterThanOrEqualTo: DateTime(today.year, today.month, today.day))
        .get();
    
    final count = querySnapshot.docs.length + 1;
    
    // Format: A-001, B-001, etc (A untuk Poli Umum, B untuk Poli Gigi, C untuk Poli KIA)
    String prefix = 'A';
    if (poli == 'Poli Gigi') prefix = 'B';
    if (poli == 'Poli KIA') prefix = 'C';
    
    return '$prefix-${count.toString().padLeft(3, '0')}';
  }

  // Create antrian baru
  Future<AntrianModel> createAntrian({
    required String namaLengkap,
    required String noRekamMedis,
    required String jenisLayanan,
    required String keluhan,
    String? nomorBPJS,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      // Generate nomor antrian
      final queueNumber = await _generateQueueNumber(jenisLayanan);

      final antrian = AntrianModel(
        pasienId: userId,
        namaLengkap: namaLengkap,
        noRekamMedis: noRekamMedis,
        jenisLayanan: jenisLayanan,
        keluhan: keluhan,
        nomorBPJS: nomorBPJS,
        queueNumber: queueNumber,
        status: 'menunggu',
        createdAt: DateTime.now(),
      );

      final docRef = await _antrianCollection.add(antrian.toMap());
      
      return antrian.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating antrian: $e');
      rethrow;
    }
  }

  // Get antrian aktif pasien
  Future<AntrianModel?> getActiveAntrian() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('status', whereIn: ['menunggu', 'dipanggil'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return AntrianModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting active antrian: $e');
      return null;
    }
  }

  // Stream untuk real-time update antrian aktif
  Stream<AntrianModel?> watchActiveAntrian() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _antrianCollection
        .where('pasienId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return AntrianModel.fromFirestore(snapshot.docs.first);
        });
  }

  // Cancel antrian
  Future<void> cancelAntrian(String antrianId) async {
    try {
      await _antrianCollection.doc(antrianId).update({
        'status': 'dibatalkan',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error canceling antrian: $e');
      rethrow;
    }
  }

  // Get history antrian pasien
  Future<List<AntrianModel>> getAntrianHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting antrian history: $e');
      return [];
    }
  }

  // Get antrian by ID
  Future<AntrianModel?> getAntrianById(String antrianId) async {
    try {
      final doc = await _antrianCollection.doc(antrianId).get();
      if (!doc.exists) return null;
      return AntrianModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting antrian by ID: $e');
      return null;
    }
  }

  // Get jumlah antrian di depan
  Future<int> getQueuePosition(String queueNumber, String jenisLayanan) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final querySnapshot = await _antrianCollection
          .where('jenisLayanan', isEqualTo: jenisLayanan)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('status', isEqualTo: 'menunggu')
          .orderBy('createdAt')
          .get();

      int position = 0;
      for (var doc in querySnapshot.docs) {
        position++;
        final data = doc.data() as Map<String, dynamic>;
        if (data['queueNumber'] == queueNumber) {
          return position;
        }
      }
      return 0;
    } catch (e) {
      print('Error getting queue position: $e');
      return 0;
    }
  }

  // ========== METHODS FOR PERAWAT ==========

  // Get all antrian hari ini (untuk dashboard perawat)
  Future<List<Map<String, dynamic>>> getAllAntrianToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final querySnapshot = await _antrianCollection
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'pasienId': data['pasienId'] ?? '',
          'namaLengkap': data['namaLengkap'] ?? '',
          'noRekamMedis': data['noRekamMedis'] ?? '',
          'jenisLayanan': data['jenisLayanan'] ?? '',
          'keluhan': data['keluhan'] ?? '',
          'nomorBPJS': data['nomorBPJS'],
          'queueNumber': data['queueNumber'] ?? '',
          'status': data['status'] ?? 'menunggu',
          'tanggalDaftar': data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          'verifiedBy': data['verifiedBy'],
          'verifiedByName': data['verifiedByName'],
          'verifiedAt': data['verifiedAt'] is Timestamp
              ? (data['verifiedAt'] as Timestamp).toDate().toIso8601String()
              : null,
          'catatanPerawat': data['catatanPerawat'],
          'dokterNama': data['dokterNama'],
          'diagnosis': data['diagnosis'],
          'tindakan': data['tindakan'],
        };
      }).toList();
    } catch (e) {
      print('Error getting all antrian today: $e');
      return [];
    }
  }

  // Stream untuk real-time update semua antrian (untuk perawat dashboard)
  Stream<List<Map<String, dynamic>>> watchAllAntrianToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _antrianCollection
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'pasienId': data['pasienId'] ?? '',
              'namaLengkap': data['namaLengkap'] ?? '',
              'noRekamMedis': data['noRekamMedis'] ?? '',
              'jenisLayanan': data['jenisLayanan'] ?? '',
              'keluhan': data['keluhan'] ?? '',
              'nomorBPJS': data['nomorBPJS'],
              'queueNumber': data['queueNumber'] ?? '',
              'status': data['status'] ?? 'menunggu',
              'tanggalDaftar': data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
                  : DateTime.now().toIso8601String(),
              'verifiedBy': data['verifiedBy'],
              'verifiedByName': data['verifiedByName'],
              'verifiedAt': data['verifiedAt'] is Timestamp
                  ? (data['verifiedAt'] as Timestamp).toDate().toIso8601String()
                  : null,
              'catatanPerawat': data['catatanPerawat'],
              'dokterNama': data['dokterNama'],
              'diagnosis': data['diagnosis'],
              'tindakan': data['tindakan'],
            };
          }).toList();
        });
  }

  // Verifikasi antrian (untuk perawat)
  Future<bool> verifikasiAntrian({
    required String antrianId,
    required String perawatId,
    required String perawatName,
    String? catatan,
  }) async {
    try {
      await _antrianCollection.doc(antrianId).update({
        'status': 'menunggu_dokter',
        'verifiedBy': perawatId,
        'verifiedByName': perawatName,
        'verifiedAt': FieldValue.serverTimestamp(),
        'catatanPerawat': catatan,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error verifikasi antrian: $e');
      return false;
    }
  }

  // Batalkan antrian (untuk perawat)
  Future<bool> batalkanAntrian(String antrianId, String alasan) async {
    try {
      await _antrianCollection.doc(antrianId).update({
        'status': 'dibatalkan',
        'alasanBatal': alasan,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error batalkan antrian: $e');
      return false;
    }
  }
}
