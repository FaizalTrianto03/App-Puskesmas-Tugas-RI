import 'package:get_storage/get_storage.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final GetStorage _box = GetStorage('session_box'); // Named container untuk persistence

  // Session Management
  Future<void> saveUserSession({
    required String userId,
    required String namaLengkap,
    required String email,
    required String role,
  }) async {
    await _box.write('isLoggedIn', true);
    await _box.write('userId', userId);
    await _box.write('namaLengkap', namaLengkap);
    await _box.write('email', email);
    await _box.write('role', role);
  }

  bool isLoggedIn() {
    return _box.read('isLoggedIn') ?? false;
  }

  String? getUserId() {
    return _box.read('userId');
  }

  String? getNamaLengkap() {
    return _box.read('namaLengkap');
  }

  String? getEmail() {
    return _box.read('email');
  }

  String? getRole() {
    return _box.read('role');
  }

  Future<void> clearSession() async {
    await _box.remove('isLoggedIn');
    await _box.remove('userId');
    await _box.remove('namaLengkap');
    await _box.remove('email');
    await _box.remove('role');
  }

  // Get All Session Data
  Map<String, dynamic>? getCurrentSession() {
    if (!isLoggedIn()) return null;
    
    return {
      'userId': getUserId(),
      'namaLengkap': getNamaLengkap(),
      'email': getEmail(),
      'role': getRole(),
    };
  }

  // Update specific session field
  Future<void> updateSessionField(String field, dynamic value) async {
    await _box.write(field, value);
  }

  // User Data Management (untuk profile)
  Future<void> saveUserData(String userId, Map<String, dynamic> userData) async {
    await _box.write('user_$userId', userData);
  }

  Map<String, dynamic>? getUserData(String userId) {
    return _box.read('user_$userId');
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> updates) async {
    final currentData = getUserData(userId) ?? {};
    currentData.addAll(updates);
    await saveUserData(userId, currentData);
  }
}
