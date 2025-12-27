import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/antrian_model.dart';
import '../../models/riwayat_kunjungan_model.dart';

class RiwayatFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _antrianCollection => _firestore.collection('antrian');

  // Get all riwayat kunjungan pasien dari collection antrian berdasarkan email
  Future<List<RiwayatKunjunganModel>> getRiwayatKunjungan() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('[RiwayatFirestoreService] User not logged in');
        return [];
      }

      print('[RiwayatFirestoreService] Getting riwayat for user: ${user.email ?? user.uid}');

      List<RiwayatKunjunganModel> allRiwayat = [];

      // First, try to get antrian by email (for new antrian)
      if (user.email != null) {
        try {
          final emailQuery = await _antrianCollection
              .where('email', isEqualTo: user.email)
              .orderBy('createdAt', descending: true)
              .get();

          print('[RiwayatFirestoreService] Found ${emailQuery.docs.length} documents by email');

          final emailRiwayat = emailQuery.docs
              .map((doc) => _mapAntrianToRiwayat(AntrianModel.fromFirestore(doc)))
              .toList();

          allRiwayat.addAll(emailRiwayat);
        } catch (e) {
          print('[RiwayatFirestoreService] Error querying by email: $e');
        }
      }

      // Also get antrian by userId (for old antrian that don't have email field)
      try {
        final userIdQuery = await _antrianCollection
            .where('pasienId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        print('[RiwayatFirestoreService] Found ${userIdQuery.docs.length} documents by userId');

        final userIdRiwayat = userIdQuery.docs
            .map((doc) => _mapAntrianToRiwayat(AntrianModel.fromFirestore(doc)))
            .toList();

        // Filter out duplicates (antrian that were found by both queries)
        final existingIds = allRiwayat.map((r) => r.id).toSet();
        final uniqueUserIdRiwayat = userIdRiwayat.where((r) => !existingIds.contains(r.id)).toList();

        allRiwayat.addAll(uniqueUserIdRiwayat);
        print('[RiwayatFirestoreService] Added ${uniqueUserIdRiwayat.length} unique antrian from userId query');
      } catch (e) {
        print('[RiwayatFirestoreService] Error querying by userId: $e');
      }

      // Sort all riwayat by date (newest first)
      allRiwayat.sort((a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan));

      print('[RiwayatFirestoreService] Returning ${allRiwayat.length} total riwayat items');

      return allRiwayat;
    } catch (e) {
      print('[RiwayatFirestoreService] Error getting riwayat kunjungan: $e');
      return [];
    }
  }

  // Get riwayat dengan filter bulan
  Future<List<RiwayatKunjunganModel>> getRiwayatByMonth(int month, int year) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return [];

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final querySnapshot = await _antrianCollection
          .where('email', isEqualTo: user.email)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _mapAntrianToRiwayat(AntrianModel.fromFirestore(doc)))
          .toList();
    } catch (e) {
      print('Error getting riwayat by month: $e');
      return [];
    }
  }

  // Get riwayat dengan filter poli
  Future<List<RiwayatKunjunganModel>> getRiwayatByPoli(String poli) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return [];

      final querySnapshot = await _antrianCollection
          .where('email', isEqualTo: user.email)
          .where('jenisLayanan', isEqualTo: poli)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _mapAntrianToRiwayat(AntrianModel.fromFirestore(doc)))
          .toList();
    } catch (e) {
      print('Error getting riwayat by poli: $e');
      return [];
    }
  }

  // Get riwayat dengan filter bulan DAN poli
  Future<List<RiwayatKunjunganModel>> getRiwayatFiltered({
    int? month,
    int? year,
    String? poli,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return [];

      Query query = _antrianCollection
          .where('email', isEqualTo: user.email);

      if (month != null && year != null) {
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: startDate)
            .where('createdAt', isLessThanOrEqualTo: endDate);
      }

      if (poli != null && poli != 'Semua') {
        query = query.where('jenisLayanan', isEqualTo: poli);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _mapAntrianToRiwayat(AntrianModel.fromFirestore(doc)))
          .toList();
    } catch (e) {
      print('Error getting filtered riwayat: $e');
      return [];
    }
  }

  // Get detail riwayat by ID
  Future<RiwayatKunjunganModel?> getRiwayatById(String riwayatId) async {
    try {
      final doc = await _antrianCollection.doc(riwayatId).get();
      if (!doc.exists) return null;
      final antrian = AntrianModel.fromFirestore(doc);
      if (antrian.status != 'selesai') return null; // Pastikan hanya yang selesai
      return _mapAntrianToRiwayat(antrian);
    } catch (e) {
      print('Error getting riwayat by ID: $e');
      return null;
    }
  }

  // Get statistik riwayat (total kunjungan, per poli, dll)
  Future<Map<String, dynamic>> getStatistik() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {
          'totalKunjungan': 0,
          'poliTerbanyak': '-',
          'kunjunganTerakhir': null,
        };
      }

      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .where('status', isEqualTo: 'selesai')
          .orderBy('createdAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'totalKunjungan': 0,
          'poliTerbanyak': '-',
          'kunjunganTerakhir': null,
        };
      }

      // Hitung poli terbanyak
      Map<String, int> poliCount = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final poli = data['jenisLayanan'] as String;
        poliCount[poli] = (poliCount[poli] ?? 0) + 1;
      }

      String poliTerbanyak = '-';
      int maxCount = 0;
      poliCount.forEach((poli, count) {
        if (count > maxCount) {
          maxCount = count;
          poliTerbanyak = poli;
        }
      });

      final lastVisit = _mapAntrianToRiwayat(AntrianModel.fromFirestore(querySnapshot.docs.first));

      return {
        'totalKunjungan': querySnapshot.docs.length,
        'poliTerbanyak': poliTerbanyak,
        'kunjunganTerakhir': lastVisit.tanggalKunjungan,
      };
    } catch (e) {
      print('Error getting statistik: $e');
      return {
        'totalKunjungan': 0,
        'poliTerbanyak': '-',
        'kunjunganTerakhir': null,
      };
    }
  }

  // Helper method to map AntrianModel to RiwayatKunjunganModel
  RiwayatKunjunganModel _mapAntrianToRiwayat(AntrianModel antrian) {
    return RiwayatKunjunganModel(
      id: antrian.id,
      pasienId: antrian.pasienId,
      email: antrian.email,
      namaLengkap: antrian.namaLengkap,
      noRekamMedis: antrian.noRekamMedis,
      poli: antrian.jenisLayanan,
      dokter: antrian.dokterNama ?? 'Dokter Tidak Diketahui',
      keluhan: antrian.keluhan,
      diagnosis: antrian.diagnosis ?? 'Diagnosis belum tersedia',
      tindakan: antrian.tindakan ?? 'Tindakan belum tersedia',
      resep: [], // Kosongkan atau ambil dari tempat lain jika ada
      tanggalKunjungan: antrian.createdAt,
      noAntrean: antrian.queueNumber,
      status: antrian.status,
      kontrolDate: null, // Kosongkan jika tidak ada
      vitalSign: null, // Kosongkan jika tidak ada
    );
  }
}
