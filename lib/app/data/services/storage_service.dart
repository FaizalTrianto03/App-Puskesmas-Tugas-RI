import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final GetStorage _box = GetStorage();

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

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

  // User Data Management (untuk CRUD)
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

  // Dummy Users Database (untuk login)
  Future<void> initDummyUsers() async {
    final users = _box.read('users') as List<dynamic>?;
    if (users == null || users.isEmpty) {
      await _box.write('users', [
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
        },
      ]);
    }
  }

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

  Future<void> addUser(Map<String, dynamic> newUser) async {
    final users = getAllUsers();
    users.add(newUser);
    await _box.write('users', users);
  }

  // Antrean Management
  Future<void> saveAntrean(Map<String, dynamic> antreanData) async {
    final antreanList = getAntreanList();
    antreanList.add(antreanData);
    await _box.write('antrean_list', antreanList);
    
    // Save active queue for current user
    await _box.write('active_queue', antreanData);
  }

  List<Map<String, dynamic>> getAntreanList() {
    final list = _box.read('antrean_list') as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? getActiveQueue() {
    final queue = _box.read('active_queue');
    if (queue == null) return null;
    return Map<String, dynamic>.from(queue);
  }

  Future<void> clearActiveQueue() async {
    await _box.remove('active_queue');
  }

  // Riwayat Kunjungan (Dummy Data)
  Future<void> initDummyRiwayat() async {
    final riwayat = _box.read('riwayat_P001') as List<dynamic>?;
    if (riwayat == null || riwayat.isEmpty) {
      await _box.write('riwayat_P001', [
        {
          'id': 'RK001',
          'tanggal': '2024-11-15',
          'poli': 'Poli Umum',
          'dokter': 'dr. Ahmad Hidayat, Sp.PD',
          'keluhan': 'Demam tinggi, batuk',
          'diagnosis': 'ISPA (Infeksi Saluran Pernapasan Akut)',
          'tindakan': 'Pemberian obat penurun demam dan antibiotik',
          'resepObat': [
            {'nama': 'Paracetamol 500mg', 'jumlah': '10 tablet', 'aturan': '3x sehari'},
            {'nama': 'Amoxicillin 500mg', 'jumlah': '15 kapsul', 'aturan': '3x sehari'},
          ],
          'anjuran': 'Istirahat cukup, minum air putih minimal 2 liter/hari',
          'jadwalKontrol': '2024-11-22',
        },
        {
          'id': 'RK002',
          'tanggal': '2024-10-10',
          'poli': 'Poli Gigi',
          'dokter': 'drg. Siti Nurhaliza',
          'keluhan': 'Gigi berlubang',
          'diagnosis': 'Karies dentis',
          'tindakan': 'Penambalan gigi',
          'resepObat': [
            {'nama': 'Asam Mefenamat 500mg', 'jumlah': '6 tablet', 'aturan': '3x sehari sesudah makan'},
          ],
          'anjuran': 'Hindari makanan keras, sikat gigi teratur',
          'jadwalKontrol': null,
        },
      ]);
    }
  }

  List<Map<String, dynamic>> getRiwayatByUserId(String userId) {
    final riwayat = _box.read('riwayat_$userId') as List<dynamic>?;
    if (riwayat == null) return [];
    return riwayat.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
