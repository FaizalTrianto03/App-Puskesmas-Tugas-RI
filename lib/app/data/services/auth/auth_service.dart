import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

import '../user/user_service.dart';
import 'session_service.dart';

/// Centralized Authentication Service
/// Handles login, logout, remember me, and OTP functionality
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();
  final GetStorage _credentialsBox = GetStorage('credentials_box');

  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex (min 8 chars, at least 1 letter and 1 number)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // Constants for validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxEmailLength = 100;

  // ========== VALIDATION METHODS ==========

  /// Validate email format
  String? validateEmailFormat(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email harus diisi';
    }
    
    if (email.length > maxEmailLength) {
      return 'Email maksimal $maxEmailLength karakter';
    }
    
    if (!_emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  /// Validate password format
  String? validatePasswordFormat(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password harus diisi';
    }
    
    if (password.length < minPasswordLength) {
      return 'Password minimal $minPasswordLength karakter';
    }
    
    if (password.length > maxPasswordLength) {
      return 'Password maksimal $maxPasswordLength karakter';
    }
    
    if (!_passwordRegex.hasMatch(password)) {
      return 'Password harus mengandung minimal 1 huruf dan 1 angka';
    }
    
    return null;
  }

  /// Check if email already exists in Firestore
  Future<bool> isEmailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email exists: $e');
      return false;
    }
  }

  // ========== AUTHENTICATION METHODS ==========

  /// Login with email and password
  /// Returns user data if successful, null otherwise
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
    bool rememberMe = false,
  }) async {
    try {
      // Validate email format
      final emailError = validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      // Find user in Firestore
      final userData = await _userService.findUserByEmail(email);
      
      if (userData == null) {
        throw Exception('Email tidak terdaftar');
      }

      // Check if role matches
      if (userData['role'] != role) {
        throw Exception('Role tidak sesuai. Anda terdaftar sebagai ${userData['role']}');
      }

      // Sign in with Firebase Auth
      print('AuthService: Attempting Firebase Auth signIn for email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login gagal');
      }

      print('AuthService: Firebase Auth successful');
      print('AuthService: Firebase UID: ${userCredential.user!.uid}');
      print('AuthService: Firestore document ID: ${userData['id']}');
      
      // IMPORTANT: Check if Firebase UID matches Firestore document ID
      if (userCredential.user!.uid != userData['id']) {
        print('WARNING: Firebase UID does not match Firestore document ID!');
        print('  Firebase UID: ${userCredential.user!.uid}');
        print('  Firestore ID: ${userData['id']}');
        // This will cause getUserProfile() to fail!
      }

      // Save session
      await _sessionService.saveUserSession(
        userId: userData['id'],
        namaLengkap: userData['namaLengkap'],
        email: userData['email'],
        role: userData['role'],
      );
      
      print('AuthService: Session saved successfully');

      // Save credentials if remember me is enabled
      if (rememberMe) {
        await _saveCredentials(email, password, role);
      } else {
        await _clearCredentials();
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        case 'wrong-password':
          throw Exception('Password salah');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan login. Silakan coba lagi nanti');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _sessionService.clearSession();
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout gagal');
    }
  }

  /// Send password reset email (OTP)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Validate email
      final emailError = validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      // Check if email exists
      final exists = await isEmailExists(email);
      if (!exists) {
        throw Exception('Email tidak terdaftar');
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Firebase error: ${e.code}');
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        default:
          throw Exception('Gagal mengirim email: ${e.message}');
      }
    } catch (e) {
      print('Send password reset error: $e');
      rethrow;
    }
  }

  /// Change password for current user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User tidak ditemukan');
      }

      // Validate new password
      final passwordError = validatePasswordFormat(newPassword);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Update credentials if remember me is active
      final savedCredentials = await getSavedCredentials();
      if (savedCredentials != null) {
        await _saveCredentials(
          user.email!,
          newPassword,
          savedCredentials['role']!,
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Change password error: ${e.code}');
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Password lama salah');
        case 'weak-password':
          throw Exception('Password terlalu lemah');
        case 'requires-recent-login':
          throw Exception('Silakan login ulang untuk mengganti password');
        default:
          throw Exception('Gagal mengubah password: ${e.message}');
      }
    } catch (e) {
      print('Change password error: $e');
      rethrow;
    }
  }

  // ========== REMEMBER ME METHODS ==========

  /// Save credentials for auto-login
  Future<void> _saveCredentials(String email, String password, String role) async {
    try {
      await _credentialsBox.write('savedEmail', email);
      await _credentialsBox.write('savedPassword', password);
      await _credentialsBox.write('savedRole', role);
      await _credentialsBox.write('rememberMe', true);
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  /// Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final rememberMe = _credentialsBox.read('rememberMe') ?? false;
      if (!rememberMe) return null;

      final email = _credentialsBox.read('savedEmail');
      final password = _credentialsBox.read('savedPassword');
      final role = _credentialsBox.read('savedRole');

      if (email == null || password == null || role == null) {
        return null;
      }

      return {
        'email': email,
        'password': password,
        'role': role,
      };
    } catch (e) {
      print('Error getting saved credentials: $e');
      return null;
    }
  }

  /// Clear saved credentials
  Future<void> _clearCredentials() async {
    try {
      await _credentialsBox.remove('savedEmail');
      await _credentialsBox.remove('savedPassword');
      await _credentialsBox.remove('savedRole');
      await _credentialsBox.remove('rememberMe');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  /// Check if has saved credentials
  bool hasSavedCredentials() {
    return _credentialsBox.read('rememberMe') ?? false;
  }

  /// Auto login with saved credentials
  Future<Map<String, dynamic>?> autoLogin() async {
    try {
      final credentials = await getSavedCredentials();
      if (credentials == null) return null;

      return await login(
        email: credentials['email']!,
        password: credentials['password']!,
        role: credentials['role']!,
        rememberMe: true,
      );
    } catch (e) {
      print('Auto login error: $e');
      // Clear invalid credentials
      await _clearCredentials();
      return null;
    }
  }

  // ========== ADMIN-ONLY USER REGISTRATION ==========

  /// Register new user (Admin only)
  /// Creates both Firebase Auth user and Firestore user document
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String namaLengkap,
    required String role,
    required String nik,
    required String noHp,
    required String jenisKelamin,
    required String tanggalLahir,
    required String alamat,
    Map<String, dynamic>? additionalData,
  }) async {
    // Store current admin session
    final currentSession = _sessionService.getCurrentSession();
    User? currentFirebaseUser = _auth.currentUser;
    
    try {
      // Validate email
      final emailError = validateEmailFormat(email);
      if (emailError != null) {
        throw Exception(emailError);
      }

      // Validate password
      final passwordError = validatePasswordFormat(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Check if email already exists
      final emailExists = await isEmailExists(email);
      if (emailExists) {
        throw Exception('Email sudah terdaftar');
      }

      // Check if NIK already exists
      final nikExists = await _userService.isNIKExists(nik);
      if (nikExists) {
        throw Exception('NIK sudah terdaftar');
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Gagal membuat akun');
      }

      // Prepare user data
      final Map<String, dynamic> userData = {
        'email': email,
        'namaLengkap': namaLengkap,
        'role': role,
        'nik': nik,
        'noHp': noHp,
        'jenisKelamin': jenisKelamin,
        'tanggalLahir': tanggalLahir,
        'alamat': alamat,
        'firebaseUid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add additional data if provided
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          userData[key] = value;
        });
      }

      // Save to Firestore using Firebase UID as document ID
      final userId = userCredential.user!.uid;
      await _firestore.collection('users').doc(userId).set(userData);
      userData['id'] = userId;
      
      print('AuthService: User registered successfully');
      print('  Firebase UID: $userId');
      print('  Firestore Document ID: $userId');
      print('  Email: $email');
      print('  Role: $role');

      // Sign out the newly created user
      await _auth.signOut();
      
      // Re-authenticate admin if there was a session
      if (currentSession != null && currentFirebaseUser != null) {
        // Admin session is preserved in GetStorage, just need to re-sign in to Firebase
        // The session service will keep the admin logged in
        print('Admin session preserved after user creation');
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      print('Firebase registration error: ${e.code}');
      
      // Try to restore admin session if it exists
      if (currentSession != null && currentFirebaseUser != null) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
      
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'weak-password':
          throw Exception('Password terlalu lemah');
        default:
          throw Exception('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      print('Registration error: $e');
      
      // Try to restore admin session if it exists
      if (currentSession != null && currentFirebaseUser != null) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
      
      rethrow;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Get current Firebase user
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated in Firebase
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
