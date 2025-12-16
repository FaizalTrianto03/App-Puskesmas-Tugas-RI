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
}
