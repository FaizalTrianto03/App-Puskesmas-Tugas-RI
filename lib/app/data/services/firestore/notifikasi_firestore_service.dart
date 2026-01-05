import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notifikasi_model.dart';

class NotifikasiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _notifikasiCollection => _firestore.collection('notifikasi');

  Future<List<NotifikasiModel>> getNotifikasi() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotifikasiModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<NotifikasiModel>> watchNotifikasi() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final notifikasi = snapshot.docs
              .map((doc) => NotifikasiModel.fromFirestore(doc))
              .toList();
          
          notifikasi.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return notifikasi;
        });
  }

  Future<List<NotifikasiModel>> getNotifikasiByType(String type) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotifikasiModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String notifikasiId) async {
    try {
      await _notifikasiCollection.doc(notifikasiId).update({
        'isRead': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final querySnapshot = await _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Stream<int> watchUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> deleteNotifikasi(String notifikasiId) async {
    try {
      await _notifikasiCollection.doc(notifikasiId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createNotifikasi({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notifikasi = NotifikasiModel(
        userId: userId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _notifikasiCollection.add(notifikasi.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Watch notifications for a specific user (for non-current user)
  Stream<List<NotifikasiModel>> watchNotifikasiForUser(String userId) {
    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final notifikasi = snapshot.docs
              .map((doc) => NotifikasiModel.fromFirestore(doc))
              .toList();
          
          notifikasi.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return notifikasi;
        });
  }

  /// Get unread count for a specific user
  Stream<int> watchUnreadCountForUser(String userId) {
    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Create notification for multiple users (batch)
  Future<void> createNotifikasiForUsers({
    required List<String> userIds,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final notifikasi = NotifikasiModel(
          userId: userId,
          type: type,
          title: title,
          message: message,
          createdAt: DateTime.now(),
          metadata: metadata,
        );
        
        final docRef = _notifikasiCollection.doc();
        batch.set(docRef, notifikasi.toMap());
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifikasi() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Get notifications with pagination
  Future<List<NotifikasiModel>> getNotifikasiPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      Query query = _notifikasiCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => NotifikasiModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

