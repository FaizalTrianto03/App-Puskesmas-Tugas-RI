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
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    
    try {
      // Get count antrian hari ini untuk poli tertentu
      final querySnapshot = await _antrianCollection
          .where('jenisLayanan', isEqualTo: poli)
          .where('tanggal', isEqualTo: dateStr)
          .get();
      
      final count = querySnapshot.docs.length + 1;
      
      // Format: A-001, B-001, etc (A untuk Poli Umum, B untuk Poli Gigi, C untuk Poli KIA)
      String prefix = 'A';
      if (poli == 'Poli Gigi') prefix = 'B';
      if (poli == 'Poli KIA') prefix = 'C';
      
      return '$prefix-${count.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback: generate with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String prefix = 'A';
      if (poli == 'Poli Gigi') prefix = 'B';
      if (poli == 'Poli KIA') prefix = 'C';
      return '$prefix-${timestamp.toString().substring(8, 11)}';
    }
  }

  // Get jumlah antrian aktif hari ini untuk poli tertentu
  Future<int> getTodayQueueCountByPoli(String jenisLayanan) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final querySnapshot = await _antrianCollection
          .where('jenisLayanan', isEqualTo: jenisLayanan)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('status', whereIn: ['menunggu', 'dipanggil'])
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Create antrian baru
  Future<AntrianModel> createAntrian({
    required String namaLengkap,
    required String noRekamMedis,
    required String jenisLayanan,
    required String keluhan,
    String? nomorBPJS,
    String? tanggalLahir,  // ✅ Tambahkan parameter
    required String email,  // ✅ Tambahkan parameter email
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      print('[AntrianFirestoreService] ===== CREATE ANTRIAN START =====');
      print('[AntrianFirestoreService] userId: $userId');
      print('[AntrianFirestoreService] namaLengkap: $namaLengkap');
      print('[AntrianFirestoreService] jenisLayanan: $jenisLayanan');

      // Generate nomor antrian
      final queueNumber = await _generateQueueNumber(jenisLayanan);
      print('[AntrianFirestoreService] Generated queueNumber: $queueNumber');

      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      print('[AntrianFirestoreService] tanggal: $tanggal');

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
        tanggal: tanggal,
        tanggalLahir: tanggalLahir,  // ✅ Simpan tanggalLahir
        email: email,  // ✅ Simpan email
      );

      print('[AntrianFirestoreService] Data to save: ${antrian.toMap()}');

      final docRef = await _antrianCollection.add(antrian.toMap());
      
      print('[AntrianFirestoreService] ✅ Antrian created with ID: ${docRef.id}');
      print('[AntrianFirestoreService] ===== CREATE ANTRIAN END =====');
      
      return antrian.copyWith(id: docRef.id);
    } catch (e) {
      print('[AntrianFirestoreService] ❌ CREATE ANTRIAN ERROR: $e');
      rethrow;
    }
  }

  // Get antrian aktif pasien
  Future<AntrianModel?> getActiveAntrian() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('[AntrianFirestoreService] ❌ getActiveAntrian: no user logged in');
        return null;
      }

      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      print('[AntrianFirestoreService] ===== GET ACTIVE ANTRIAN START =====');
      print('[AntrianFirestoreService] userId: $userId');
      print('[AntrianFirestoreService] tanggal: $dateStr');
      print('[AntrianFirestoreService] looking for status: menunggu or dipanggil');

      // Coba query sederhana dulu - hanya filter by pasienId dan tanggal
      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .where('tanggal', isEqualTo: dateStr)
          .get();

      print('[AntrianFirestoreService] Total docs found: ${querySnapshot.docs.length}');
      
      // Print semua docs untuk debugging
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('[AntrianFirestoreService] Doc ${doc.id}: status=${data['status']}, queueNumber=${data['queueNumber']}');
      }

      // Filter manual by status
      final activeDocs = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        return status == 'menunggu' || status == 'dipanggil';
      }).toList();

      print('[AntrianFirestoreService] Active docs after filter: ${activeDocs.length}');

      if (activeDocs.isEmpty) {
        print('[AntrianFirestoreService] ❌ No active antrian found');
        print('[AntrianFirestoreService] ===== GET ACTIVE ANTRIAN END =====');
        return null;
      }

      // Sort by createdAt (newest first)
      activeDocs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      final antrian = AntrianModel.fromFirestore(activeDocs.first);
      print('[AntrianFirestoreService] ✅ Found active antrian: ${antrian.queueNumber}');
      print('[AntrianFirestoreService] ===== GET ACTIVE ANTRIAN END =====');
      return antrian;
    } catch (e) {
      print('[AntrianFirestoreService] ❌ getActiveAntrian ERROR: $e');
      print('[AntrianFirestoreService] ===== GET ACTIVE ANTRIAN END =====');
      return null;
    }
  }

  // Stream untuk real-time update antrian aktif
  Stream<AntrianModel?> watchActiveAntrian() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('[AntrianFirestoreService] watchActiveAntrian: no user logged in');
      return Stream.value(null);
    }

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    
    print('[AntrianFirestoreService] watchActiveAntrian: userId=$userId, tanggal=$dateStr');

    // GUNAKAN TANGGAL STRING untuk query yang lebih stabil
    return _antrianCollection
        .where('pasienId', isEqualTo: userId)
        .where('tanggal', isEqualTo: dateStr)  // ✅ Equality filter lebih stabil
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          print('[AntrianFirestoreService] watchActiveAntrian snapshot: ${snapshot.docs.length} docs');
          if (snapshot.docs.isEmpty) {
            print('[AntrianFirestoreService] watchActiveAntrian: no active antrian');
            return null;
          }
          final antrian = AntrianModel.fromFirestore(snapshot.docs.first);
          print('[AntrianFirestoreService] watchActiveAntrian: found ${antrian.queueNumber}');
          return antrian;
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
      return 0;
    }
  }

  // ========== METHODS FOR PERAWAT ==========

  // Get ALL antrian (semua tanggal, untuk dashboard perawat)
  Future<List<Map<String, dynamic>>> getAllAntrian() async {
    try {
      print('[AntrianFirestoreService] ========== GET ALL ANTRIAN ==========');

      final querySnapshot = await _antrianCollection
          .orderBy('createdAt', descending: true)  // Terbaru di atas
          .limit(100)  // Limit untuk performa
          .get();

      print('[AntrianFirestoreService] Query executed successfully');
      print('[AntrianFirestoreService] Total documents found: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('[AntrianFirestoreService] ⚠️ WARNING: No documents found in collection "antrian"!');
        print('[AntrianFirestoreService] Please check:');
        print('[AntrianFirestoreService]   1. Collection name is correct: "antrian"');
        print('[AntrianFirestoreService]   2. Data exists in Firestore');
        print('[AntrianFirestoreService]   3. Firestore rules allow read access');
        return [];
      }

      final result = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        print('[AntrianFirestoreService] Document ID: ${doc.id}');
        print('[AntrianFirestoreService]   - namaLengkap: ${data['namaLengkap']}');
        print('[AntrianFirestoreService]   - queueNumber: ${data['queueNumber']}');
        print('[AntrianFirestoreService]   - status: ${data['status']}');
        print('[AntrianFirestoreService]   - tanggal: ${data['tanggal']}');
        
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
          'tanggal': data['tanggal'] ?? '',
          'tanggalLahir': data['tanggalLahir'],
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

      print('[AntrianFirestoreService] ✅ Successfully mapped ${result.length} antrian');
      print('[AntrianFirestoreService] ========================================');
      return result;
    } catch (e) {
      print('[AntrianFirestoreService] ❌ ERROR in getAllAntrian: $e');
      print('[AntrianFirestoreService] Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Get all antrian hari ini (untuk dashboard perawat)
  Future<List<Map<String, dynamic>>> getAllAntrianToday() async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      print('[AntrianFirestoreService] ===== GET ALL ANTRIAN TODAY START =====');
      print('[AntrianFirestoreService] Current date: $today');
      print('[AntrianFirestoreService] Querying with tanggal=$dateStr');

      // GUNAKAN TANGGAL STRING untuk konsistensi
        final querySnapshot = await _antrianCollection
          .where('tanggal', isEqualTo: dateStr)  // ✅ Equality filter
          .orderBy('createdAt', descending: true)
          .get();

      print('[AntrianFirestoreService] Query executed successfully');
      print('[AntrianFirestoreService] Found ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isEmpty) {
        print('[AntrianFirestoreService] ⚠️ No antrian found for today!');
        print('[AntrianFirestoreService] Checking if any data exists in collection...');
        
        // Debug: cek apakah ada data sama sekali
        final allDocs = await _antrianCollection.limit(5).get();
        print('[AntrianFirestoreService] Total documents in collection (sample): ${allDocs.docs.length}');
        
        if (allDocs.docs.isNotEmpty) {
          print('[AntrianFirestoreService] Sample data:');
          for (var doc in allDocs.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            print('  - ID: ${doc.id}');
            print('    tanggal: ${data?['tanggal']}');
            print('    queueNumber: ${data?['queueNumber']}');
            print('    status: ${data?['status']}');
            print('    createdAt: ${data?['createdAt']}');
          }
        }
      }

      final result = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        print('[AntrianFirestoreService] Processing doc ${doc.id}:');
        print('  - queueNumber: ${data['queueNumber']}');
        print('  - namaLengkap: ${data['namaLengkap']}');
        print('  - tanggal: ${data['tanggal']}');
        
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
          'tanggal': data['tanggal'] ?? dateStr,
          'tanggalLahir': data['tanggalLahir'],  // ✅ Tambahkan untuk form rekam medis
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

      print('[AntrianFirestoreService] Returning ${result.length} antrian');
      print('[AntrianFirestoreService] ===== GET ALL ANTRIAN TODAY END =====');
      return result;
    } catch (e) {
      print('[AntrianFirestoreService] ❌ getAllAntrianToday ERROR: $e');
      print('[AntrianFirestoreService] Error stack: ${StackTrace.current}');
      return [];
    }
  }

  // Stream untuk real-time update semua antrian (untuk perawat dashboard)
  Stream<List<Map<String, dynamic>>> watchAllAntrianToday() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    print('[AntrianFirestoreService] watchAllAntrianToday: tanggal=$dateStr');

    // GUNAKAN TANGGAL STRING untuk konsistensi
    return _antrianCollection
      .where('tanggal', isEqualTo: dateStr)  // ✅ Equality filter
      .orderBy('createdAt', descending: true)
      .snapshots()
        .map((snapshot) {
          print('[AntrianFirestoreService] watchAllAntrianToday: received ${snapshot.docs.length} antrian');
          
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
              'tanggal': data['tanggal'] ?? dateStr,
              'tanggalLahir': data['tanggalLahir'],  // ✅ Tambahkan untuk form rekam medis
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
