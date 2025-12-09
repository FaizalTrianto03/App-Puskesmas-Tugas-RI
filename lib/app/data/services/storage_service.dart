import 'package:get_storage/get_storage.dart';

import 'auth/session_service.dart';
import 'pasien/antrean_service.dart';
import 'pasien/riwayat_service.dart';
import 'user/user_service.dart';

/// Main Storage Service - Facade pattern untuk mengakses semua services
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Services
  final SessionService session = SessionService();
  final UserService user = UserService();
  final AntreanService antrean = AntreanService();
  final RiwayatService riwayat = RiwayatService();

  // Initialize GetStorage
  static Future<void> init() async {
    await GetStorage.init();
    await GetStorage.init('session_box'); // Container khusus untuk session
    await GetStorage.init('user_box'); // Container khusus untuk user data
  }

  // Initialize dummy data
  Future<void> initDummyData() async {
    await user.initDummyUsers();
    await riwayat.initDummyRiwayat();
  }

  // Legacy methods untuk backward compatibility
  // Session
  Future<void> saveUserSession({
    required String userId,
    required String namaLengkap,
    required String email,
    required String role,
  }) => session.saveUserSession(
    userId: userId,
    namaLengkap: namaLengkap,
    email: email,
    role: role,
  );

  bool isLoggedIn() => session.isLoggedIn();
  String? getUserId() => session.getUserId();
  String? getNamaLengkap() => session.getNamaLengkap();
  String? getEmail() => session.getEmail();
  String? getRole() => session.getRole();
  Future<void> clearSession() => session.clearSession();

  // User
  Future<void> initDummyUsers() => user.initDummyUsers();
  List<Map<String, dynamic>> getAllUsers() => user.getAllUsers();
  Map<String, dynamic>? findUserByEmail(String email) => user.findUserByEmail(email);
  Map<String, dynamic>? findUserById(String id) => user.findUserById(id);
  List<Map<String, dynamic>> getUsersByRole(String role) => user.getUsersByRole(role);
  bool isEmailExists(String email, {String? excludeId}) => user.isEmailExists(email, excludeId: excludeId);
  bool isNIKExists(String nik, {String? excludeId}) => user.isNIKExists(nik, excludeId: excludeId);
  Future<void> addUser(Map<String, dynamic> newUser) => user.addUser(newUser);
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) => user.updateUser(userId, updates);
  Future<bool> deleteUser(String userId) => user.deleteUser(userId);
  String generateUserId(String role) => user.generateUserId(role);

  // Antrean
  Future<void> saveAntrean(Map<String, dynamic> antreanData) => antrean.saveAntrean(antreanData);
  List<Map<String, dynamic>> getAntreanList() => antrean.getAntreanList();
  Map<String, dynamic>? getActiveQueue() => antrean.getActiveQueue();
  Future<void> clearActiveQueue() => antrean.clearActiveQueue();

  // Riwayat
  Future<void> initDummyRiwayat() => riwayat.initDummyRiwayat();
  List<Map<String, dynamic>> getRiwayatByUserId(String userId) => riwayat.getRiwayatByUserId(userId);
  
  // User Data Management (legacy - untuk compatibility)
  Future<void> saveUserData(String userId, Map<String, dynamic> userData) => 
    session.saveUserData(userId, userData);
  Map<String, dynamic>? getUserData(String userId) => 
    session.getUserData(userId);
}
