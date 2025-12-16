import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/riwayat_kunjungan_model.dart';

class RiwayatFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _riwayatCollection => _firestore.collection('riwayat_kunjungan');

  // Get all riwayat kunjungan pasien
  Future<List<RiwayatKunjunganModel>> getRiwayatKunjungan() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _riwayatCollection
          .where('pasienId', isEqualTo: userId)
          .orderBy('tanggalKunjungan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RiwayatKunjunganModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting riwayat kunjungan: $e');
      return [];
    }
  }

  // Get riwayat dengan filter bulan
  Future<List<RiwayatKunjunganModel>> getRiwayatByMonth(int month, int year) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final querySnapshot = await _riwayatCollection
          .where('pasienId', isEqualTo: userId)
          .where('tanggalKunjungan', isGreaterThanOrEqualTo: startDate)
          .where('tanggalKunjungan', isLessThanOrEqualTo: endDate)
          .orderBy('tanggalKunjungan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RiwayatKunjunganModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting riwayat by month: $e');
      return [];
    }
  }

  // Get riwayat dengan filter poli
  Future<List<RiwayatKunjunganModel>> getRiwayatByPoli(String poli) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _riwayatCollection
          .where('pasienId', isEqualTo: userId)
          .where('poli', isEqualTo: poli)
          .orderBy('tanggalKunjungan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RiwayatKunjunganModel.fromFirestore(doc))
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
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      Query query = _riwayatCollection.where('pasienId', isEqualTo: userId);

      if (month != null && year != null) {
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        query = query
            .where('tanggalKunjungan', isGreaterThanOrEqualTo: startDate)
            .where('tanggalKunjungan', isLessThanOrEqualTo: endDate);
      }

      if (poli != null && poli != 'Semua') {
        query = query.where('poli', isEqualTo: poli);
      }

      final querySnapshot = await query
          .orderBy('tanggalKunjungan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RiwayatKunjunganModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting filtered riwayat: $e');
      return [];
    }
  }

  // Get detail riwayat by ID
  Future<RiwayatKunjunganModel?> getRiwayatById(String riwayatId) async {
    try {
      final doc = await _riwayatCollection.doc(riwayatId).get();
      if (!doc.exists) return null;
      return RiwayatKunjunganModel.fromFirestore(doc);
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

      final querySnapshot = await _riwayatCollection
          .where('pasienId', isEqualTo: userId)
          .orderBy('tanggalKunjungan', descending: true)
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
        final poli = data['poli'] as String;
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

      final lastVisit = RiwayatKunjunganModel.fromFirestore(querySnapshot.docs.first);

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
}
