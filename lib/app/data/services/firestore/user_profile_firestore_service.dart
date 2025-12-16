import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile_model.dart';

class UserProfileFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get user profile
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      print('UserProfileFirestoreService: getUserProfile() - userId: $userId');
      
      if (userId == null) {
        print('UserProfileFirestoreService: User not logged in');
        return null;
      }

      print('UserProfileFirestoreService: Fetching document for user: $userId');
      final doc = await _usersCollection.doc(userId).get();
      
      if (!doc.exists) {
        print('UserProfileFirestoreService: Document does not exist for user: $userId');
        return null;
      }

      print('UserProfileFirestoreService: Document found, parsing data...');
      final profile = UserProfileModel.fromFirestore(doc);
      print('UserProfileFirestoreService: Profile loaded - ${profile.namaLengkap}');
      return profile;
    } catch (e) {
      print('UserProfileFirestoreService: Error getting user profile: $e');
      return null;
    }
  }

  // Stream user profile untuk real-time updates
  Stream<UserProfileModel?> watchUserProfile() {
    final userId = _auth.currentUser?.uid;
    print('UserProfileFirestoreService: watchUserProfile() - userId: $userId');
    
    if (userId == null) {
      print('UserProfileFirestoreService: User not logged in, returning empty stream');
      return Stream.value(null);
    }

    print('UserProfileFirestoreService: Setting up snapshot listener for user: $userId');
    return _usersCollection.doc(userId).snapshots().map((doc) {
      print('UserProfileFirestoreService: Snapshot received - exists: ${doc.exists}');
      if (!doc.exists) {
        print('UserProfileFirestoreService: Document does not exist in snapshot');
        return null;
      }
      final profile = UserProfileModel.fromFirestore(doc);
      print('UserProfileFirestoreService: Profile from snapshot - ${profile.namaLengkap}');
      return profile;
    });
  }

  // Create or update user profile
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      await _usersCollection.doc(userId).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Update specific fields
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update data diri
  Future<void> updateDataDiri({
    required String namaLengkap,
    required String nik,
    required String noHp,
    required String alamat,
    required String jenisKelamin,
    required String tanggalLahir,
  }) async {
    try {
      await updateUserProfile({
        'namaLengkap': namaLengkap,
        'nik': nik,
        'noHp': noHp,
        'alamat': alamat,
        'jenisKelamin': jenisKelamin,
        'tanggalLahir': tanggalLahir,
      });
    } catch (e) {
      print('Error updating data diri: $e');
      rethrow;
    }
  }

  // Update photo profile URL
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await updateUserProfile({'photoUrl': photoUrl});
    } catch (e) {
      print('Error updating photo URL: $e');
      rethrow;
    }
  }

  // Check if user profile exists
  Future<bool> profileExists() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  // Create initial profile after registration
  Future<void> createInitialProfile({
    required String namaLengkap,
    required String email,
    String? noRekamMedis,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      final profile = UserProfileModel(
        id: userId,
        namaLengkap: namaLengkap,
        email: email,
        role: 'pasien',
        noRekamMedis: noRekamMedis,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(userId).set(profile.toMap());
    } catch (e) {
      print('Error creating initial profile: $e');
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }
}
