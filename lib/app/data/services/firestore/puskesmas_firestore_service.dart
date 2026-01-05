import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/puskesmas_model.dart';

class PuskesmasFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'puskesmas';

  Future<PuskesmasModel?> getPuskesmasInfo() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 3));

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return PuskesmasModel.fromFirestore(querySnapshot.docs.first);
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> createPuskesmas(PuskesmasModel puskesmas) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
        puskesmas.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePuskesmas(String id, PuskesmasModel puskesmas) async {
    try {
      await _firestore.collection(_collection).doc(id).update(
        puskesmas.copyWith(updatedAt: DateTime.now()).toFirestore(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePuskesmas(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PuskesmasModel>> getAllPuskesmas() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PuskesmasModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
