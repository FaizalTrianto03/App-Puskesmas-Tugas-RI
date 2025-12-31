import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notifikasi_model.dart';

class NotifikasiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _notifikasiCollection => _firestore.collection('notifikasi');

  // Get all notifikasi pasien
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
      print('Error getting notifikasi: $e');
      return [];
    }
  }

  // Stream untuk real-time notifikasi
  Stream<List<NotifikasiModel>> watchNotifikasi() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    // Query sederhana (tanpa orderBy untuk avoid composite index)
    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          // Sort di client-side
          final notifikasi = snapshot.docs
              .map((doc) => NotifikasiModel.fromFirestore(doc))
              .toList();
          
          // Sort by createdAt descending
          notifikasi.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return notifikasi;
        });
  }

  // Get notifikasi by type
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
      print('Error getting notifikasi by type: $e');
      return [];
    }
  }

  // Mark notifikasi as read
  Future<void> markAsRead(String notifikasiId) async {
    try {
      await _notifikasiCollection.doc(notifikasiId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notifikasi as read: $e');
      rethrow;
    }
  }

  // Mark all as read
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
      print('Error marking all as read: $e');
      rethrow;
    }
  }

  // Get unread count
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
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Stream unread count
  Stream<int> watchUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _notifikasiCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete notifikasi
  Future<void> deleteNotifikasi(String notifikasiId) async {
    try {
      await _notifikasiCollection.doc(notifikasiId).delete();
    } catch (e) {
      print('Error deleting notifikasi: $e');
      rethrow;
    }
  }

  // Create notifikasi (biasanya dari sistem/admin)
  Future<void> createNotifikasi({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('[NotifikasiService] 📝 Creating notification...');
      print('[NotifikasiService] userId: $userId');
      print('[NotifikasiService] type: $type');
      print('[NotifikasiService] title: $title');
      print('[NotifikasiService] message: $message');
      
      final notifikasi = NotifikasiModel(
        userId: userId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      final docRef = await _notifikasiCollection.add(notifikasi.toMap());
      print('[NotifikasiService] ✅ Notification created with ID: ${docRef.id}');
    } catch (e) {
      print('[NotifikasiService] ❌ Error creating notifikasi: $e');
      rethrow;
    }
  }
}
