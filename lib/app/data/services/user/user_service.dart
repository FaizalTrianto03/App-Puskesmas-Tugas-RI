import 'package:get_storage/get_storage.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final GetStorage _box = GetStorage();

  // Initialize Dummy Users
  Future<void> initDummyUsers() async {
    final users = _box.read('users') as List<dynamic>?;
    if (users == null || users.isEmpty) {
      await _box.write('users', [
        // Admin
        {
          'id': 'ADM001',
          'namaLengkap': 'Faizal Qadri Trianto',
          'email': 'admin@puskesmasdau.com',
          'password': 'admin123',
          'role': 'admin',
          'nik': '3507011234567890',
          'noHp': '081234567800',
          'jenisKelamin': 'Laki-laki',
          'tanggalLahir': '1990-03-15',
          'alamat': 'Jl. Admin Puskesmas No. 1',
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Dokter
        {
          'id': 'DOK001',
          'namaLengkap': 'dr. Ahmad Hidayat, Sp.PD',
          'email': 'dokter@puskesmasdau.com',
          'password': 'dokter123',
          'role': 'dokter',
          'nik': '3507011234567891',
          'noHp': '081234567801',
          'jenisKelamin': 'Laki-laki',
          'tanggalLahir': '1985-07-20',
          'alamat': 'Jl. Dokter Sejahtera No. 2',
          'spesialisasi': 'Penyakit Dalam',
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Perawat
        {
          'id': 'PER001',
          'namaLengkap': 'Mukarram Luthfi Al Manfaluti',
          'email': 'perawat@puskesmasdau.com',
          'password': 'perawat123',
          'role': 'perawat',
          'nik': '3507011234567892',
          'noHp': '081234567802',
          'jenisKelamin': 'Laki-laki',
          'tanggalLahir': '1993-05-10',
          'alamat': 'Jl. Perawat Peduli No. 3',
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Apoteker
        {
          'id': 'APO001',
          'namaLengkap': 'Dias Aditama',
          'email': 'apoteker@puskesmasdau.com',
          'password': 'apoteker123',
          'role': 'apoteker',
          'nik': '3507011234567893',
          'noHp': '081234567803',
          'jenisKelamin': 'Laki-laki',
          'tanggalLahir': '1992-09-25',
          'alamat': 'Jl. Apoteker Sehat No. 4',
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Pasien
        {
          'id': 'P001',
          'namaLengkap': 'Anisa Ayu Nabila',
          'email': 'anisa@gmail.com',
          'password': 'password123',
          'role': 'pasien',
          'nik': '3507012345678901',
          'noHp': '081234567890',
          'jenisKelamin': 'Perempuan',
          'tanggalLahir': '2001-01-15',
          'alamat': 'Jl. Raya Malang No. 123',
          'noRekamMedis': 'RM001',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'P002',
          'namaLengkap': 'Budi Santoso',
          'email': 'budi@gmail.com',
          'password': 'password123',
          'role': 'pasien',
          'nik': '3507012345678902',
          'noHp': '081234567891',
          'jenisKelamin': 'Laki-laki',
          'tanggalLahir': '1995-05-20',
          'alamat': 'Jl. Raya Surabaya No. 456',
          'noRekamMedis': 'RM002',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]);
    }
  }

  // READ Operations
  List<Map<String, dynamic>> getAllUsers() {
    final users = _box.read('users') as List<dynamic>?;
    if (users == null) return [];
    return users.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? findUserByEmail(String email) {
    final users = getAllUsers();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? findUserById(String id) {
    final users = getAllUsers();
    try {
      return users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getUsersByRole(String role) {
    final users = getAllUsers();
    return users.where((user) => user['role'] == role).toList();
  }

  // Validation
  bool isEmailExists(String email, {String? excludeId}) {
    final users = getAllUsers();
    return users.any((user) => 
      user['email'] == email && (excludeId == null || user['id'] != excludeId)
    );
  }

  bool isNIKExists(String nik, {String? excludeId}) {
    final users = getAllUsers();
    return users.any((user) => 
      user['nik'] == nik && (excludeId == null || user['id'] != excludeId)
    );
  }

  // CREATE
  Future<void> addUser(Map<String, dynamic> newUser) async {
    final users = getAllUsers();
    users.add(newUser);
    await _box.write('users', users);
  }

  // UPDATE
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    final users = getAllUsers();
    final index = users.indexWhere((user) => user['id'] == userId);
    
    if (index == -1) return false;
    
    users[index] = {...users[index], ...updates};
    await _box.write('users', users);
    
    // Update session if logged in user is being edited
    final sessionUserId = _box.read('userId');
    if (sessionUserId == userId) {
      // Update semua field yang berubah di session
      if (updates.containsKey('namaLengkap')) {
        await _box.write('namaLengkap', updates['namaLengkap']);
      }
      if (updates.containsKey('email')) {
        await _box.write('email', updates['email']);
      }
      if (updates.containsKey('role')) {
        await _box.write('role', updates['role']);
      }
    }
    
    return true;
  }

  // DELETE
  Future<bool> deleteUser(String userId) async {
    final users = getAllUsers();
    final initialLength = users.length;
    users.removeWhere((user) => user['id'] == userId);
    
    if (users.length < initialLength) {
      await _box.write('users', users);
      return true;
    }
    return false;
  }

  // Helper
  String generateUserId(String role) {
    final users = getAllUsers();
    final roleUsers = users.where((user) => user['role'] == role).toList();
    
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
    
    final nextNumber = roleUsers.length + 1;
    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }

  // Get Current Logged In User Data
  Map<String, dynamic>? getCurrentUserData() {
    // Ambil userId dari session_box (bukan dari default box)
    final sessionBox = GetStorage('session_box');
    final userId = sessionBox.read('userId');
    if (userId == null) return null;
    return findUserById(userId);
  }

  // Sync session with latest user data
  Future<void> syncSessionWithUserData() async {
    // Ambil userId dari session_box (bukan dari default box)
    final sessionBox = GetStorage('session_box');
    final userId = sessionBox.read('userId');
    if (userId == null) return;
    
    final user = findUserById(userId);
    if (user != null) {
      await sessionBox.write('namaLengkap', user['namaLengkap']);
      await sessionBox.write('email', user['email']);
      await sessionBox.write('role', user['role']);
    }
  }
}
