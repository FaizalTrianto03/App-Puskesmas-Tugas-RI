import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/antrian_model.dart';
import 'obat_firestore_service.dart';

class AntrianFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _antrianCollection => _firestore.collection('antrian');

  Future<String> _generateQueueNumber(String poli) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    
    try {
      // Get prefix from poli collection
      final poliSnapshot = await _firestore
          .collection('poli')
          .where('namaPoli', isEqualTo: poli)
          .limit(1)
          .get();
      
      String prefix = 'A'; // Default fallback
      if (poliSnapshot.docs.isNotEmpty) {
        final poliData = poliSnapshot.docs.first.data();
        prefix = poliData['kodePoli'] ?? 'A';
      }
      
      // Count existing queue numbers for this poli today
      final snapshot = await _antrianCollection
          .where('tanggal', isEqualTo: dateStr)
          .where('jenisLayanan', isEqualTo: poli)
          .get();
      
      final count = snapshot.docs.length + 1;
      final queueNumber = '$prefix-${count.toString().padLeft(3, '0')}';
      return queueNumber;
    } catch (e) {
      // Fallback: use timestamp with 'A' prefix
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'A-${timestamp.toString().substring(8, 11)}';
    }
  }

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

  Future<AntrianModel> createAntrian({
    required String namaLengkap,
    required String noRekamMedis,
    required String jenisLayanan,
    required String keluhan,
    String? nomorBPJS,
    String? tanggalLahir,
    required String email,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      final queueNumber = await _generateQueueNumber(jenisLayanan);

      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

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
        tanggalLahir: tanggalLahir,
        email: email,
        perawatData: {
          'perawatId': null,
          'perawatName': null,
          'verifiedAt': null,
          'tekananDarahSistolik': null,
          'tekananDarahDiastolik': null,
          'nadi': null,
          'suhu': null,
          'pernapasan': null,
          'beratBadan': null,
          'tinggiBadan': null,
          'imt': null,
          'keluhanUtama': null,
          'riwayatPenyakit': null,
          'alergi': null,
        },
        dokterData: {
          'dokterId': null,
          'dokterNama': null,
          'anamnesis': null,
          'diagnosis': null,
          'tindakan': null,
          'catatanDokter': null,
        },
        resepObat: const [],
        apotekerData: {
          'apotekerId': null,
          'apotekerNama': null,
          'statusObat': null,
          'disiapkanAt': null,
          'siapDiambilAt': null,
        },
        pembayaranData: {
          'statusPembayaran': 'pending',
          'metodePembayaran': null,
          'totalObat': 0,
          'totalLayanan': 0,
          'totalBayar': 0,
        },
        ruanganId: null,
        ruanganNama: '-',
      );

      final docRef = await _antrianCollection.add(antrian.toMap());
      
      return antrian.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<AntrianModel> createAntrianWithQueueNumber({
    required String queueNumber,
    required String namaLengkap,
    required String noRekamMedis,
    required String jenisLayanan,
    required String keluhan,
    String? nomorBPJS,
    String? tanggalLahir,
    required String email,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

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
        tanggalLahir: tanggalLahir,
        email: email,
        perawatData: {
          'perawatId': null,
          'perawatName': null,
          'verifiedAt': null,
          'tekananDarahSistolik': null,
          'tekananDarahDiastolik': null,
          'nadi': null,
          'suhu': null,
          'pernapasan': null,
          'beratBadan': null,
          'tinggiBadan': null,
          'imt': null,
          'keluhanUtama': null,
          'riwayatPenyakit': null,
          'alergi': null,
        },
        dokterData: {
          'dokterId': null,
          'dokterNama': null,
          'anamnesis': null,
          'diagnosis': null,
          'tindakan': null,
          'catatanDokter': null,
        },
        resepObat: const [],
        apotekerData: {
          'apotekerId': null,
          'apotekerNama': null,
          'statusObat': null,
          'disiapkanAt': null,
          'siapDiambilAt': null,
        },
        pembayaranData: {
          'statusPembayaran': 'pending',
          'metodePembayaran': null,
          'totalObat': 0,
          'totalLayanan': 0,
          'totalBayar': 0,
        },
        ruanganId: null,
        ruanganNama: '-',
      );

      final docRef = await _antrianCollection.add(antrian.toMap());
      
      return antrian.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<AntrianModel?> getActiveAntrian() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null;
      }

      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .where('tanggal', isEqualTo: dateStr)
          .get();

      // Status yang dianggap sebagai antrian aktif:
      // SEMUA status dianggap aktif KECUALI: selesai, done, dibatalkan, cancelled
      final finalStatuses = ['selesai', 'done', 'dibatalkan', 'cancelled'];

      final activeDocs = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        // Aktif jika status BUKAN status final
        return status != null && !finalStatuses.contains(status);
      }).toList();

      if (activeDocs.isEmpty) {
        return null;
      }

      activeDocs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      final antrian = AntrianModel.fromFirestore(activeDocs.first);
      return antrian;
    } catch (e) {
      return null;
    }
  }

  Stream<AntrianModel?> watchActiveAntrian() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    // Status FINAL - antrian sudah tidak aktif
    // SEMUA status lain dianggap aktif
    final finalStatuses = ['selesai', 'done', 'dibatalkan', 'cancelled'];

    return _antrianCollection
        .where('pasienId', isEqualTo: userId)
        .where('tanggal', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) {
          final activeDocs = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String?;
            // Aktif jika status BUKAN status final
            return status != null && !finalStatuses.contains(status);
          }).toList();
          
          if (activeDocs.isEmpty) {
            return null;
          }
          
          activeDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });
          
          final antrian = AntrianModel.fromFirestore(activeDocs.first);
          return antrian;
        });
  }

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

  Future<void> cancelAntrianWithReason(String antrianId, String alasan) async {
    try {
      final user = _auth.currentUser;
      await _antrianCollection.doc(antrianId).update({
        'status': 'dibatalkan',
        'alasanPembatalan': alasan,
        'dibatalkanOleh': 'pasien',
        'dibatalkanOlehId': user?.uid,
        'dibatalkanOlehNama': user?.displayName ?? 'Pasien',
        'waktuPembatalan': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AntrianModel>> getAntrianHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .get();

      final result = querySnapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory (descending by createdAt)
      result.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      
      // Limit to 50
      return result.take(50).toList();
    } catch (e) {
      return [];
    }
  }

  Future<AntrianModel?> getAntrianById(String antrianId) async {
    try {
      final doc = await _antrianCollection.doc(antrianId).get();
      if (!doc.exists) return null;
      return AntrianModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Get antrian as Map by document ID
  Future<Map<String, dynamic>?> getAntrianMapById(String antrianId) async {
    try {
      final doc = await _antrianCollection.doc(antrianId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<List<AntrianModel>> getAllAntrianByUser() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];
      
      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: userId)
          .get();
      
      final antrianList = querySnapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .toList();

      antrianList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return antrianList;
    } catch (e) {
      return [];
    }
  }

  Future<int> getQueuePosition(String queueNumber, String jenisLayanan) async {
    try {
      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

      final querySnapshot = await _antrianCollection
          .where('jenisLayanan', isEqualTo: jenisLayanan)
          .where('tanggal', isEqualTo: tanggal)
          .where('status', isEqualTo: 'menunggu')
          .get();

      // Sort by createdAt in memory
      final docs = querySnapshot.docs.toList();
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTime = aData['createdAt'] is Timestamp ? (aData['createdAt'] as Timestamp).toDate() : DateTime(1970);
        final bTime = bData['createdAt'] is Timestamp ? (bData['createdAt'] as Timestamp).toDate() : DateTime(1970);
        return aTime.compareTo(bTime);
      });

      int position = 0;
      for (var doc in docs) {
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

  /// Update data dokter dan resep obat untuk pasien
  /// Dipanggil saat dokter menyelesaikan pemeriksaan
  Future<void> updateDokterDataForPasien({
    required String pasienId,
    String? dokterId,
    required String dokterNama,
    required String diagnosa,
    required String keluhan,
    String? tindakan,
    String? catatan,
    Map<String, dynamic>? tandaVital,
    required List<Map<String, dynamic>> resepObat,
    bool perluRawatInap = false,
    String? ruanganId,
    String? ruanganNama,
  }) async {
    try {
      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

      final querySnapshot = await _antrianCollection
          .where('pasienId', isEqualTo: pasienId)
          .where('tanggal', isEqualTo: tanggal)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }
      
      // Sort by createdAt descending in memory to get the latest
      final docs = querySnapshot.docs.toList();
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTime = aData['createdAt'] is Timestamp ? (aData['createdAt'] as Timestamp).toDate() : DateTime(1970);
        final bTime = bData['createdAt'] is Timestamp ? (bData['createdAt'] as Timestamp).toDate() : DateTime(1970);
        return bTime.compareTo(aTime); // descending
      });

      final docRef = docs.first.reference;

      // Hitung total biaya obat
      int totalBiayaObat = 0;
      for (var obat in resepObat) {
        totalBiayaObat += (obat['totalHarga'] as int?) ?? 0;
      }

      // Update data dengan status 'selesai_diperiksa' agar bisa diproses apoteker
      final updateData = <String, dynamic>{
        'status': 'selesai_diperiksa',
        'dokterNama': dokterNama,
        'diagnosis': diagnosa,
        'tindakan': tindakan,
        'updatedAt': FieldValue.serverTimestamp(),
        // Data dokter lengkap
        'dokterData.dokterId': dokterId,
        'dokterData.dokterNama': dokterNama,
        'dokterData.diagnosis': diagnosa,
        'dokterData.tindakan': tindakan,
        'dokterData.catatanDokter': catatan,
        'dokterData.anamnesis': keluhan,
        'dokterData.updatedAt': FieldValue.serverTimestamp(),
        // Resep obat dengan struktur lengkap
        'resepObat': resepObat,
        // Data pembayaran (update biaya obat)
        'pembayaranData.biayaObat': totalBiayaObat,
        // Data rawat inap jika diperlukan
        'perluRawatInap': perluRawatInap,
      };

      if (tandaVital != null) {
        updateData['dokterData.tandaVital'] = tandaVital;
      }

      if (perluRawatInap && ruanganId != null) {
        updateData['ruanganId'] = ruanganId;
        updateData['ruanganNama'] = ruanganNama;
      }

      await docRef.update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  /// Update dokter data langsung menggunakan document ID antrian
  /// Ini adalah method utama untuk menyimpan hasil pemeriksaan dokter
  Future<bool> simpanHasilPemeriksaanDokter({
    required String antrianId,
    required String dokterId,
    required String dokterNama,
    required String diagnosa,
    String? tindakan,
    String? catatan,
    required List<Map<String, dynamic>> resepObat,
    bool perluRawatInap = false,
    String? ruanganId,
    String? ruanganNama,
  }) async {
    try {
      // Hitung total biaya obat dan jumlah item
      int totalBiayaObat = 0;
      int totalItemObat = 0;
      for (var obat in resepObat) {
        totalBiayaObat += (obat['totalHarga'] as int?) ?? 0;
        totalItemObat += (obat['jumlah'] as int?) ?? 1;
      }

      // Tentukan status selanjutnya
      // Jika ada resep obat -> selesai_diperiksa (tunggu apoteker)
      // Jika tidak ada obat dan rawat inap -> rawat_inap
      // Jika tidak ada obat -> selesai
      String nextStatus;
      if (resepObat.isNotEmpty) {
        nextStatus = 'selesai_diperiksa'; // Akan diproses apoteker
      } else if (perluRawatInap) {
        nextStatus = 'rawat_inap';
      } else {
        nextStatus = 'selesai';
      }

      final updateData = <String, dynamic>{
        'status': nextStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        // Data dokter di root level (untuk kompatibilitas)
        'dokterNama': dokterNama,
        'dokterId': dokterId,
        'diagnosis': diagnosa,
        'tindakan': tindakan,
        // Data dokter lengkap nested
        'dokterData.dokterId': dokterId,
        'dokterData.dokterNama': dokterNama,
        'dokterData.diagnosis': diagnosa,
        'dokterData.tindakan': tindakan,
        'dokterData.catatanDokter': catatan,
        'dokterData.completedAt': FieldValue.serverTimestamp(),
        // Resep obat dengan struktur lengkap
        'resepObat': resepObat,
        'totalItemObat': totalItemObat,
        // Update pembayaran
        'pembayaranData.totalObat': totalBiayaObat,
      };

      // Rawat inap
      if (perluRawatInap && ruanganId != null) {
        updateData['ruanganId'] = ruanganId;
        updateData['ruanganNama'] = ruanganNama ?? '-';
        updateData['perluRawatInap'] = true;
      }

      await _antrianCollection.doc(antrianId).update(updateData);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getResepUntukApotekerHariIni() async {
    try {
      final today = DateTime.now();
      final tanggal = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

      final snapshot = await _antrianCollection
          .where('tanggal', isEqualTo: tanggal)
          .where('status', whereIn: ['menunggu_apoteker', 'dilayani_apoteker'])
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'noAntrean': data['queueNumber'] ?? '-',
          'namaPasien': data['namaLengkap'] ?? '-',
          'poli': data['jenisLayanan'] ?? '-',
          'dokter': data['dokterNama'] ?? '-',
          'tanggal': data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : null,
          'status': data['status'] == 'dilayani_apoteker' ? 'Selesai' : 'Menunggu',
          'statusColor': data['status'] == 'dilayani_apoteker'
              ? 0xFF4CAF50
              : 0xFFFF9800,
          'jumlahObat': (data['resepObat'] as List?)?.length ?? 0,
          'daftarObat': (data['resepObat'] as List?) ?? [],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> konfirmasiPenyerahanObat({
    required String antrianId,
    required String apotekerId,
    required String apotekerName,
    String? catatan,
  }) async {
    try {
      await _antrianCollection.doc(antrianId).update({
        'status': 'dilayani_apoteker',
        'updatedAt': FieldValue.serverTimestamp(),
        'apotekerData.apotekerId': apotekerId,
        'apotekerData.apotekerNama': apotekerName,
        'apotekerData.statusObat': 'diserahkan',
        'apotekerData.siapDiambilAt': FieldValue.serverTimestamp(),
        if (catatan != null && catatan.isNotEmpty)
          'apotekerData.catatanApoteker': catatan,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update pembayaran tanpa mengubah status antrian
  Future<bool> updatePembayaran({
    required String antrianId,
    String? metodePembayaran,
    int? totalObat,
    int? totalLayanan,
    int? totalBayar,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'pembayaranData.statusPembayaran': 'lunas',
        'pembayaranData.waktuPembayaran': FieldValue.serverTimestamp(),
        if (metodePembayaran != null)
          'pembayaranData.metodePembayaran': metodePembayaran,
        if (totalObat != null) 'pembayaranData.totalObat': totalObat,
        if (totalLayanan != null)
          'pembayaranData.totalLayanan': totalLayanan,
        if (totalBayar != null) 'pembayaranData.totalBayar': totalBayar,
      };

      await _antrianCollection.doc(antrianId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> selesaikanKunjungan({
    required String antrianId,
    String? metodePembayaran,
    int? totalObat,
    int? totalLayanan,
    int? totalBayar,
    String? catatan,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': 'selesai',
        'updatedAt': FieldValue.serverTimestamp(),
        'pembayaranData.statusPembayaran': 'lunas',
        if (metodePembayaran != null)
          'pembayaranData.metodePembayaran': metodePembayaran,
        if (totalObat != null) 'pembayaranData.totalObat': totalObat,
        if (totalLayanan != null)
          'pembayaranData.totalLayanan': totalLayanan,
        if (totalBayar != null) 'pembayaranData.totalBayar': totalBayar,
        if (catatan != null && catatan.isNotEmpty)
          'pembayaranData.catatanPembayaran': catatan,
      };

      await _antrianCollection.doc(antrianId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAntrian() async {
    try {
      final querySnapshot = await _antrianCollection
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final result = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Return full data dengan id
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
      
      // Sort by createdAt descending in memory
      result.sort((a, b) {
        final aTime = a['createdAt'] is Timestamp ? (a['createdAt'] as Timestamp).toDate() : DateTime(1970);
        final bTime = b['createdAt'] is Timestamp ? (b['createdAt'] as Timestamp).toDate() : DateTime(1970);
        return bTime.compareTo(aTime);
      });
      
      // Limit to 200
      return result.take(200).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAntrianToday() async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      final querySnapshot = await _antrianCollection
          .where('tanggal', isEqualTo: dateStr)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final result = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Return semua data mentah
        final result = <String, dynamic>{'id': doc.id};
        result.addAll(data);
        return result;
      }).toList();

      // Sort manual di client side (terbaru dulu)
      result.sort((a, b) {
        final aTime = a['createdAt'] is Timestamp 
            ? (a['createdAt'] as Timestamp).toDate()
            : DateTime.now();
        final bTime = b['createdAt'] is Timestamp 
            ? (b['createdAt'] as Timestamp).toDate()
            : DateTime.now();
        return bTime.compareTo(aTime);
      });

      return result;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchAllAntrianToday() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    return _antrianCollection
        .where('tanggal', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) {
          final antrianList = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Return semua data mentah dari Firestore
            final result = <String, dynamic>{'id': doc.id};
            result.addAll(data);
            return result;
          }).toList();
          
          antrianList.sort((a, b) {
            final aTime = a['createdAt'] is Timestamp 
                ? (a['createdAt'] as Timestamp).toDate()
                : DateTime.now();
            final bTime = b['createdAt'] is Timestamp 
                ? (b['createdAt'] as Timestamp).toDate()
                : DateTime.now();
            return bTime.compareTo(aTime);
          });
          
          return antrianList;
        });
  }

  Future<bool> verifikasiAntrian({
    required String antrianId,
    required String perawatId,
    required String perawatName,
    String? catatan,
  }) async {
    try {
      final antrianDoc = await _antrianCollection.doc(antrianId).get();
      if (!antrianDoc.exists) {
        return false;
      }
      
      // pasienId validation only - notification handled by Cloud Function
      final antrianData = antrianDoc.data() as Map<String, dynamic>;
      if (antrianData['pasienId'] == null) {
        return false;
      }
      
      await _antrianCollection.doc(antrianId).update({
        'status': 'menunggu_dokter',
        'verifiedBy': perawatId,
        'verifiedByName': perawatName,
        'verifiedAt': FieldValue.serverTimestamp(),
        'catatanPerawat': catatan,
        'updatedAt': FieldValue.serverTimestamp(),
        'perawatData.perawatId': perawatId,
        'perawatData.perawatName': perawatName,
        'perawatData.verifiedAt': FieldValue.serverTimestamp(),
        'perawatData.catatanPerawat': catatan,
      });
      
      // Notification is now handled by Cloud Function (onAntrianUpdated)
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> batalkanAntrian({
    required String antrianId,
    required String alasan,
    String? dibatalkanOleh, // 'pasien' atau 'perawat'
    String? dibatalkanOlehNama,
    String? dibatalkanOlehId,
  }) async {
    try {
      final antrianDoc = await _antrianCollection.doc(antrianId).get();
      if (!antrianDoc.exists) {
        return false;
      }
      
      // pasienId validation only - notification handled by Cloud Function
      final antrianData = antrianDoc.data() as Map<String, dynamic>;
      if (antrianData['pasienId'] == null) {
        return false;
      }
      
      await _antrianCollection.doc(antrianId).update({
        'status': 'dibatalkan',
        'alasanPembatalan': alasan,
        'waktuPembatalan': FieldValue.serverTimestamp(),
        'dibatalkanOleh': dibatalkanOleh ?? 'pasien',
        'dibatalkanOlehNama': dibatalkanOlehNama,
        'dibatalkanOlehId': dibatalkanOlehId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Notification is now handled by Cloud Function (onAntrianUpdated)
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateAntrianStatus({
    required String antrianId,
    required String newStatus,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final antrianDoc = await _antrianCollection.doc(antrianId).get();
      if (!antrianDoc.exists) return;

      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _antrianCollection.doc(antrianId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== APOTEKER METHODS ====================
  
  /// Get antrian dengan status 'selesai_diperiksa' (ada resep dari dokter)
  Future<List<AntrianModel>> getAntrianUntukApoteker() async {
    try {
      final snapshot = await _antrianCollection
          .where('status', isEqualTo: 'selesai_diperiksa')
          .get();

      final result = snapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .where((antrian) => antrian.adaResepObat)
          .toList();
      
      // Sort by updatedAt ascending in memory
      result.sort((a, b) => (a.updatedAt ?? DateTime(1970)).compareTo(b.updatedAt ?? DateTime(1970)));
      
      return result;
    } catch (e) {
      throw Exception('Gagal mengambil antrian untuk apoteker: $e');
    }
  }

  /// Apoteker konfirmasi siapkan obat dan auto-reduce stok
  Future<bool> konfirmasiSiapkanObat({
    required String antrianId,
    required String apotekerId,
    required String apotekerNama,
    String? catatan,
  }) async {
    try {
      // Get antrian data
      final antrianDoc = await _antrianCollection.doc(antrianId).get();
      if (!antrianDoc.exists) {
        throw Exception('Antrian tidak ditemukan');
      }

      final antrian = AntrianModel.fromFirestore(antrianDoc);

      // Validate ada resep
      if (!antrian.adaResepObat) {
        throw Exception('Tidak ada resep obat untuk antrian ini');
      }

      // Auto-reduce stok untuk setiap obat di resep
      final obatService = ObatFirestoreService();
      for (var resep in antrian.resepObat!) {
        final idObat = resep['idObat'] as String;
        final jumlah = resep['jumlah'] as int;

        // Kurangi stok obat
        await obatService.kurangiStok(idObat, jumlah);
      }

      // Update antrian status dan apoteker data
      await _antrianCollection.doc(antrianId).update({
        'status': 'siap_ambil_obat',
        'updatedAt': FieldValue.serverTimestamp(),
        'apotekerData': {
          'apotekerId': apotekerId,
          'apotekerNama': apotekerNama,
          'waktuSiap': FieldValue.serverTimestamp(),
          'catatan': catatan ?? '',
        },
      });

      // Notification is now handled by Cloud Function (onAntrianUpdated)

      return true;
    } catch (e) {
      throw Exception('Gagal konfirmasi siapkan obat: $e');
    }
  }

  /// Get statistik resep untuk dashboard apoteker
  /// [apotekerId] - ID apoteker untuk filter "siapDiambil" dan "selesai" (opsional, jika null tidak difilter)
  Future<Map<String, int>> getStatistikResepApoteker({String? apotekerId}) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final snapshot = await _antrianCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final antrianList = snapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .where((antrian) => antrian.adaResepObat)
          .toList();
      
      // Hitung siapDiambil dan selesai: filter berdasarkan apoteker jika ada
      int siapDiambilCount = 0;
      int selesaiCount = 0;
      
      if (apotekerId != null && apotekerId.isNotEmpty) {
        // Filter berdasarkan apotekerId yang sudah menyiapkan
        siapDiambilCount = antrianList.where((a) => 
          a.status == 'siap_ambil_obat' && 
          a.sudahDisiapkanApoteker &&
          a.apotekerData?['apotekerId'] == apotekerId
        ).length;
        
        selesaiCount = antrianList.where((a) => 
          a.status == 'selesai' && 
          a.sudahDisiapkanApoteker &&
          a.apotekerData?['apotekerId'] == apotekerId
        ).length;
      } else {
        siapDiambilCount = antrianList.where((a) => a.status == 'siap_ambil_obat').length;
        selesaiCount = antrianList.where((a) => a.status == 'selesai').length;
      }

      return {
        'totalResep': antrianList.length,
        'menunggu': antrianList.where((a) => a.status == 'selesai_diperiksa').length,
        'siapDiambil': siapDiambilCount,
        'selesai': selesaiCount,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik: $e');
    }
  }

  // Stream untuk real-time updates apoteker
  Stream<List<AntrianModel>> streamAntrianUntukApoteker() {
    return _antrianCollection
        .where('status', isEqualTo: 'selesai_diperiksa')
        .snapshots()
        .map((snapshot) {
          final result = snapshot.docs
              .map((doc) => AntrianModel.fromFirestore(doc))
              .where((antrian) => antrian.adaResepObat)
              .toList();
          // Sort by updatedAt ascending in memory
          result.sort((a, b) => (a.updatedAt ?? DateTime(1970)).compareTo(b.updatedAt ?? DateTime(1970)));
          return result;
        });
  }

  /// Get riwayat penyiapan obat oleh apoteker tertentu
  /// [apotekerId] - ID apoteker yang menyiapkan obat
  /// [tanggalMulai] - Tanggal awal filter (opsional, default: 30 hari lalu)
  /// [tanggalAkhir] - Tanggal akhir filter (opsional, default: hari ini)
  Future<List<AntrianModel>> getRiwayatPenyiapanObat({
    required String apotekerId,
    DateTime? tanggalMulai,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = tanggalMulai ?? now.subtract(const Duration(days: 30));
      final endDate = tanggalAkhir ?? now;

      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      // Query antrian yang sudah disiapkan apoteker
      final snapshot = await _antrianCollection
          .where('apotekerData.apotekerId', isEqualTo: apotekerId)
          .where('status', whereIn: ['siap_ambil_obat', 'selesai'])
          .get();

      // Filter berdasarkan tanggal
      final antrianList = snapshot.docs
          .map((doc) => AntrianModel.fromFirestore(doc))
          .where((antrian) {
            if (antrian.updatedAt == null) return false;
            return antrian.updatedAt!.isAfter(startOfDay) &&
                antrian.updatedAt!.isBefore(endOfDay);
          })
          .toList();
      
      // Sort by updatedAt descending in memory
      antrianList.sort((a, b) => (b.updatedAt ?? DateTime(1970)).compareTo(a.updatedAt ?? DateTime(1970)));

      return antrianList;
    } catch (e) {
      throw Exception('Gagal mengambil riwayat penyiapan obat: $e');
    }
  }

  /// Get statistik penyiapan obat apoteker dalam periode tertentu
  Future<Map<String, dynamic>> getStatistikPenyiapanApoteker({
    required String apotekerId,
    DateTime? tanggalMulai,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final riwayat = await getRiwayatPenyiapanObat(
        apotekerId: apotekerId,
        tanggalMulai: tanggalMulai,
        tanggalAkhir: tanggalAkhir,
      );

      int totalResepDisiapkan = riwayat.length;
      int totalItemObat = 0;
      int totalNilaiObat = 0;

      for (var antrian in riwayat) {
        if (antrian.resepObat != null) {
          for (var obat in antrian.resepObat!) {
            totalItemObat += (obat['jumlah'] as int?) ?? 0;
            totalNilaiObat += (obat['totalHarga'] as int?) ?? 0;
          }
        }
      }

      return {
        'totalResepDisiapkan': totalResepDisiapkan,
        'totalItemObat': totalItemObat,
        'totalNilaiObat': totalNilaiObat,
        'riwayat': riwayat,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik penyiapan: $e');
    }
  }
}
