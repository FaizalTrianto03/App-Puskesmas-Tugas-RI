import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile_model.dart';

class UserProfileFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<UserProfileModel?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;
      
      final docById = await _usersCollection.doc(userId).get();
      if (docById.exists) {
        return UserProfileModel.fromFirestore(docById);
      }

      final byFirebaseUid = await _usersCollection
          .where('firebaseUid', isEqualTo: userId)
          .limit(1)
          .get();
      if (byFirebaseUid.docs.isNotEmpty) {
        return UserProfileModel.fromFirestore(byFirebaseUid.docs.first);
      }

      final currentUser = _auth.currentUser;
      if (currentUser?.email != null) {
        final byEmail = await _usersCollection
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();
        if (byEmail.docs.isNotEmpty) {
          return UserProfileModel.fromFirestore(byEmail.docs.first);
        }
      }

      final email = currentUser?.email ?? '';
      final displayName = currentUser?.displayName ?? 'Pasien Baru';

      final profile = UserProfileModel(
        id: userId,
        namaLengkap: displayName,
        email: email,
        role: 'pasien',
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(userId).set(profile.toMap());

      return profile;
    } catch (e) {
      return null;
    }
  }

  Stream<UserProfileModel?> watchUserProfile() {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return Stream.value(null);
    }

    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    });
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      await _usersCollection.doc(userId).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User tidak login');

      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).set(updates, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

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
      rethrow;
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await updateUserProfile({'photoUrl': photoUrl});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> profileExists() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

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
      rethrow;
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _usersCollection.doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
