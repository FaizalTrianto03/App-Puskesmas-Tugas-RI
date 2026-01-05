import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/jam_operasional_model.dart';

class JamOperasionalFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<JamOperasionalModel>> getJamOperasional(String puskesmasId) async {
    try {
      final snapshot = await _firestore
          .collection('puskesmas')
          .doc(puskesmasId)
          .collection('jamOperasional')
          .get();

      return snapshot.docs
          .map((doc) => JamOperasionalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addJamOperasional(
    String puskesmasId,
    JamOperasionalModel jamOperasional,
  ) async {
    try {
      await _firestore
          .collection('puskesmas')
          .doc(puskesmasId)
          .collection('jamOperasional')
          .add(jamOperasional.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateJamOperasional(
    String puskesmasId,
    String jamOperasionalId,
    JamOperasionalModel jamOperasional,
  ) async {
    try {
      await _firestore
          .collection('puskesmas')
          .doc(puskesmasId)
          .collection('jamOperasional')
          .doc(jamOperasionalId)
          .update(jamOperasional.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJamOperasional(
    String puskesmasId,
    String jamOperasionalId,
  ) async {
    try {
      await _firestore
          .collection('puskesmas')
          .doc(puskesmasId)
          .collection('jamOperasional')
          .doc(jamOperasionalId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllJamOperasional(String puskesmasId) async {
    try {
      final snapshot = await _firestore
          .collection('puskesmas')
          .doc(puskesmasId)
          .collection('jamOperasional')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
