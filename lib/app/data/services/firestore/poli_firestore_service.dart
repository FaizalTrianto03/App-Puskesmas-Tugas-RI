import 'package:cloud_firestore/cloud_firestore.dart';

class PoliFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'poli';

  Stream<List<Map<String, dynamic>>> watchAllPoli() {
    return _firestore
        .collection(_collection)
        .orderBy('namaPoli')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getAllPoli() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('namaPoli')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPoliById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isKodePoliExists(String kodePoli, {String? excludeId}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('kodePoli', isEqualTo: kodePoli)
          .get();

      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> addPoli(Map<String, dynamic> poliData) async {
    try {
      poliData.remove('id');
      poliData['createdAt'] = DateTime.now().toIso8601String();
      poliData['updatedAt'] = DateTime.now().toIso8601String();

      final docRef = await _firestore.collection(_collection).add(poliData);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePoli(String id, Map<String, dynamic> updates) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return false;
      }

      updates.remove('id');
      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(id).set(updates, SetOptions(merge: true));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePoli(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getActivePoli() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'aktif')
          .orderBy('namaPoli')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
