import '../data/services/storage_service.dart';

class AuthHelper {
  static final StorageService _storage = StorageService();

  static bool get isLoggedIn => _storage.session.isLoggedIn();

  static String? get userId => _storage.session.getUserId();

  static String? get namaLengkap => _storage.session.getNamaLengkap();

  static String? get email => _storage.session.getEmail();

  static String? get role => _storage.session.getRole();

  static Map<String, dynamic>? get currentSession =>
      _storage.session.getCurrentSession();

  static Future<Map<String, dynamic>?> get currentUserData =>
      _storage.user.getCurrentUserData();

  static Future<void> syncSession() async {
    await _storage.user.syncSessionWithUserData();
  }

  static Future<void> logout() async {
    await _storage.auth.logout();
  }

  static Future<bool> updateProfile(Map<String, dynamic> updates) async {
    final userId = AuthHelper.userId;
    if (userId == null) return false;

    final success = await _storage.user.updateUser(userId, updates);
    if (success) {
      await syncSession();
    }
    return success;
  }

  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _storage.auth.changePassword(
        currentPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}
