import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // READ Operations
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id;
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> findUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
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

  // Validation
  Future<bool> isEmailExists(String email, {String? excludeId}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isNIKExists(String nik, {String? excludeId}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('nik', isEqualTo: nik)
          .get();
      
      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // CREATE
  Future<String?> addUser(Map<String, dynamic> newUser) async {
    try {
      // Remove id if exists (Firestore will generate)
      newUser.remove('id');
      
      // Add timestamp as ISO string
      newUser['createdAt'] = DateTime.now().toIso8601String();
      
      final docRef = await _firestore.collection('users').add(newUser);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // UPDATE
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Check if document exists first
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        return false;
      }
      
      // Remove id from updates if exists
      updates.remove('id');
      
      // Add update timestamp as ISO string (not FieldValue to avoid type issues)
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      // Update Firestore using set with merge
      await _firestore.collection('users').doc(userId).set(updates, SetOptions(merge: true));
      
      // Update session if logged in user is being edited
      final sessionBox = GetStorage('session_box');
      final sessionUserId = sessionBox.read('userId');
      if (sessionUserId == userId) {
        // Update relevant session fields using the original updates (without FieldValue)
        if (updates.containsKey('namaLengkap')) {
          await sessionBox.write('namaLengkap', updates['namaLengkap']);
        }
        if (updates.containsKey('email')) {
          await sessionBox.write('email', updates['email']);
        }
        if (updates.containsKey('role')) {
          await sessionBox.write('role', updates['role']);
        }
      }
      
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper
  Future<String> generateUserId(String role) async {
    try {
      final users = await getUsersByRole(role);
      
      String prefix;
      switch (role) {
        case 'admin':
          prefix = 'ADM';
          break;
        case 'dokter':
          prefix = 'DOK';
          break;
        case 'perawat':
          prefix = 'PER';
          break;
        case 'apoteker':
          prefix = 'APO';
          break;
        case 'pasien':
          prefix = 'P';
          break;
        default:
          prefix = 'USR';
      }
      
      final nextNumber = users.length + 1;
      return '$prefix${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      return 'USR001';
    }
  }

  // Get Current Logged In User Data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final sessionBox = GetStorage('session_box');
      final userId = sessionBox.read('userId');
      if (userId == null) return null;
      return await findUserById(userId);
    } catch (e) {
      return null;
    }
  }

  // Sync session with latest user data
  Future<void> syncSessionWithUserData() async {
    try {
      final sessionBox = GetStorage('session_box');
      final userId = sessionBox.read('userId');
      if (userId == null) return;
      
      final user = await findUserById(userId);
      if (user != null) {
        await sessionBox.write('namaLengkap', user['namaLengkap']);
        await sessionBox.write('email', user['email']);
        await sessionBox.write('role', user['role']);
      }
    } catch (e) {
    }
  }
}
