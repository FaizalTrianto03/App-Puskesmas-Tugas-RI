import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get list semua dokter
  Future<List<Map<String, dynamic>>> getAllDokter() async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: 'dokter')
          .get();

      final result = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'namaLengkap': data['namaLengkap'] ?? '',
          'email': data['email'] ?? '',
          'role': data['role'] ?? '',
        };
      }).toList();
      
      // Sort di client-side (by nama)
      result.sort((a, b) {
        final aName = a['namaLengkap'] as String;
        final bName = b['namaLengkap'] as String;
        return aName.compareTo(bName);
      });
      
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Get dokter by ID
  Future<Map<String, dynamic>?> getDokterById(String dokterId) async {
    try {
      final doc = await _usersCollection.doc(dokterId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'namaLengkap': data['namaLengkap'] ?? '',
        'email': data['email'] ?? '',
        'role': data['role'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // =========================================
  // NOTIFICATION SUBSCRIPTION MANAGEMENT
  // =========================================

  /// Get users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get users by role with active notification subscription
  Future<List<Map<String, dynamic>>> getUsersByRoleWithSubscription(String role) async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .where('notificationSubscription', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update notification subscription status for current user
  Future<void> updateNotificationSubscription(bool enabled) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).update({
        'notificationSubscription': enabled,
        'notificationUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get notification subscription status for current user
  Future<bool> getNotificationSubscription() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return true; // Default enabled

      final data = doc.data() as Map<String, dynamic>;
      return data['notificationSubscription'] != false;
    } catch (e) {
      return true; // Default enabled
    }
  }

  /// Watch notification subscription status
  Stream<bool> watchNotificationSubscription() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(true);

    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return true;
      final data = doc.data() as Map<String, dynamic>;
      return data['notificationSubscription'] != false;
    });
  }

  /// Add FCM token to user document
  Future<void> addFcmToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If document doesn't have the field, try set with merge
      try {
        final userId = _auth.currentUser?.uid;
        if (userId == null) return;

        await _usersCollection.doc(userId).set({
          'fcmTokens': [token],
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'notificationSubscription': true,
        }, SetOptions(merge: true));
      } catch (e2) {
      }
    }
  }

  /// Remove FCM token from user document
  Future<void> removeFcmToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
    }
  }

  /// Get FCM tokens for a user
  Future<List<String>> getFcmTokens(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final tokens = data['fcmTokens'];
      
      if (tokens == null) return [];
      if (tokens is String) return [tokens];
      if (tokens is List) return List<String>.from(tokens);
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update subscribed topics for user
  Future<void> updateSubscribedTopics(List<String> topics) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).update({
        'subscribedTopics': topics,
      });
    } catch (e) {
    }
  }

  /// Initialize notification fields for new user (call on register)
  Future<void> initializeNotificationFields(String userId, String role) async {
    try {
      await _usersCollection.doc(userId).set({
        'notificationSubscription': true,
        'subscribedTopics': [role, 'general'],
        'fcmTokens': [],
        'notificationCreatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
    }
  }
}

