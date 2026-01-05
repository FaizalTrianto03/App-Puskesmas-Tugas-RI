import 'package:cloud_firestore/cloud_firestore.dart';

class RuanganFirestoreService {
  static final RuanganFirestoreService _instance = RuanganFirestoreService._internal();
  factory RuanganFirestoreService() => _instance;
  RuanganFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ruangan';

  Future<String?> addRuangan(Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRuangan() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .get();
      
      final result = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort in memory
      result.sort((a, b) => (a['namaRuangan'] ?? '').toString().compareTo((b['namaRuangan'] ?? '').toString()));
      
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRuanganById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateRuangan(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRuangan(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isKodeRuanganExists(String kodeRuangan, {String? excludeId}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('kodeRuangan', isEqualTo: kodeRuangan)
          .get();
      
      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRuanganByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .get();
      
      final result = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort in memory to avoid needing composite index
      result.sort((a, b) => (a['namaRuangan'] ?? '').toString().compareTo((b['namaRuangan'] ?? '').toString()));
      
      return result;
    } catch (e) {
      return [];
    }
  }
}
