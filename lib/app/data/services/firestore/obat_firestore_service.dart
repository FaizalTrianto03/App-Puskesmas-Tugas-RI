import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/obat_model.dart';

class ObatFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'obat';

  // Get all obat
  Future<List<ObatModel>> getAllObat() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('namaObat')
          .get();

      return snapshot.docs
          .map((doc) => ObatModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data obat: $e');
    }
  }

  // Get obat by ID
  Future<ObatModel?> getObatById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return ObatModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data obat: $e');
    }
  }

  // Get obat by status stok
  Future<List<ObatModel>> getObatByStatusStok(String status) async {
    try {
      final allObat = await getAllObat();

      switch (status.toLowerCase()) {
        case 'habis':
          return allObat.where((obat) => obat.stok == 0).toList();
        case 'kritis':
          return allObat.where((obat) => obat.isStokKritis && obat.stok > 0).toList();
        case 'hampir habis':
          return allObat.where((obat) => obat.isStokHampirHabis).toList();
        case 'aman':
          return allObat.where((obat) => obat.isStokAman).toList();
        default:
          return allObat;
      }
    } catch (e) {
      throw Exception('Gagal memfilter obat: $e');
    }
  }

  // Search obat by name
  Future<List<ObatModel>> searchObat(String query) async {
    try {
      final allObat = await getAllObat();
      
      if (query.isEmpty) return allObat;

      return allObat.where((obat) {
        return obat.namaObat.toLowerCase().contains(query.toLowerCase()) ||
               obat.kategori.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Gagal mencari obat: $e');
    }
  }

  // Add obat
  Future<String> addObat(ObatModel obat) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
        obat.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toFirestore(),
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah obat: $e');
    }
  }

  // Update obat
  Future<void> updateObat(String id, ObatModel obat) async {
    try {
      await _firestore.collection(_collection).doc(id).update(
        obat.copyWith(updatedAt: DateTime.now()).toFirestore(),
      );
    } catch (e) {
      throw Exception('Gagal mengupdate obat: $e');
    }
  }

  // Delete obat
  Future<void> deleteObat(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus obat: $e');
    }
  }

  // Update stok (untuk mengurangi/menambah stok)
  Future<void> updateStok(String id, int jumlahPerubahan) async {
    try {
      final obat = await getObatById(id);
      
      if (obat == null) {
        throw Exception('Obat tidak ditemukan');
      }

      final stokBaru = obat.stok + jumlahPerubahan;

      if (stokBaru < 0) {
        throw Exception('Stok tidak mencukupi');
      }

      await _firestore.collection(_collection).doc(id).update({
        'stok': stokBaru,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Gagal mengupdate stok: $e');
    }
  }

  // Kurangi stok (untuk resep)
  Future<void> kurangiStok(String id, int jumlah) async {
    await updateStok(id, -jumlah);
  }

  // Tambah stok (untuk restock)
  Future<void> tambahStok(String id, int jumlah) async {
    await updateStok(id, jumlah);
  }

  // Get statistik stok
  Future<Map<String, int>> getStatistikStok() async {
    try {
      final allObat = await getAllObat();
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      return {
        'total': allObat.length,
        'aman': allObat.where((obat) => obat.isStokAman).length,
        'hampirHabis': allObat.where((obat) => obat.isStokHampirHabis).length,
        'kritis': allObat.where((obat) => obat.isStokKritis && obat.stok > 0).length,
        'habis': allObat.where((obat) => obat.stok == 0).length,
        'kadaluarsa': allObat.where((obat) {
          if (obat.tanggalKadaluarsa == null) return false;
          return obat.tanggalKadaluarsa!.isBefore(thirtyDaysFromNow) ||
                 obat.tanggalKadaluarsa!.isAtSameMomentAs(thirtyDaysFromNow);
        }).length,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik: $e');
    }
  }

  // Stream untuk real-time updates
  Stream<List<ObatModel>> streamAllObat() {
    return _firestore
        .collection(_collection)
        .orderBy('namaObat')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ObatModel.fromFirestore(doc))
            .toList());
  }

  // Stream statistik
  Stream<Map<String, int>> streamStatistikStok() {
    return streamAllObat().map((obatList) {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      
      return {
        'total': obatList.length,
        'aman': obatList.where((obat) => obat.isStokAman).length,
        'hampirHabis': obatList.where((obat) => obat.isStokHampirHabis).length,
        'kritis': obatList.where((obat) => obat.isStokKritis && obat.stok > 0).length,
        'habis': obatList.where((obat) => obat.stok == 0).length,
        'kadaluarsa': obatList.where((obat) {
          if (obat.tanggalKadaluarsa == null) return false;
          return obat.tanggalKadaluarsa!.isBefore(thirtyDaysFromNow) ||
                 obat.tanggalKadaluarsa!.isAtSameMomentAs(thirtyDaysFromNow);
        }).length,
      };
    });
  }
}
