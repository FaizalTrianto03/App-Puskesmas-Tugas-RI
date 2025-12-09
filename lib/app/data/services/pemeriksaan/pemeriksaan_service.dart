import 'package:get_storage/get_storage.dart';

class PemeriksaanService {
  final GetStorage _box = GetStorage();
  static const String _keyPemeriksaan = 'pemeriksaan_list';
  static const String _keyPasien = 'pasien_list';

  // ==================== DATA DUMMY PASIEN ====================
  static final List<Map<String, dynamic>> dummyPasienList = [
    // Pasien sedang diperiksa (hanya 1 yang bisa sedang diperiksa)
    {
      'id': 'P005',
      'nama': 'Eko Prasetyo',
      'umur': '42 Tahun',
      'antrian': 'A005',
      'keluhan': 'Nyeri sendi lutut',
      'alergi': 'Tidak ada',
      'jenisLayanan': 'Poli Umum',
      'golDarah': 'AB+',
      'tinggiBerat': '168 cm / 75 kg',
      'sedangDiperiksa': true, // Flag untuk pasien saat ini
    },
    // Pasien menunggu antrian
    {
      'id': 'P006',
      'nama': 'Fitri Handayani',
      'umur': '30 Tahun',
      'antrian': 'A006',
      'keluhan': 'Batuk kering sejak 1 minggu',
      'alergi': 'Seafood',
      'jenisLayanan': 'Umum',
      'golDarah': 'O+',
      'tinggiBerat': '162 cm / 58 kg',
    },
    {
      'id': 'P007',
      'nama': 'Gatot Subroto',
      'umur': '55 Tahun',
      'antrian': 'A007',
      'keluhan': 'Diabetes kontrol rutin',
      'alergi': 'Tidak ada',
      'jenisLayanan': 'Poli Umum',
      'golDarah': 'B-',
      'tinggiBerat': '165 cm / 72 kg',
    },
    {
      'id': 'P008',
      'nama': 'Hana Pertiwi',
      'umur': '22 Tahun',
      'antrian': 'A008',
      'keluhan': 'Sakit perut dan diare',
      'alergi': 'Tidak ada',
      'jenisLayanan': 'Umum',
      'golDarah': 'A+',
      'tinggiBerat': '155 cm / 48 kg',
    },
    {
      'id': 'P009',
      'nama': 'Indra Gunawan',
      'umur': '38 Tahun',
      'antrian': 'A009',
      'keluhan': 'Hipertensi',
      'alergi': 'Penisilin',
      'jenisLayanan': 'Poli Umum',
      'golDarah': 'AB-',
      'tinggiBerat': '172 cm / 80 kg',
    },
    // Pasien sudah selesai (ada riwayat pemeriksaan)
    {
      'id': 'P001',
      'nama': 'Anisa Ayu',
      'umur': '25 Tahun',
      'antrian': 'A001',
      'keluhan': 'Demam dan batuk',
      'alergi': 'Tidak ada',
      'jenisLayanan': 'Umum',
      'golDarah': 'A+',
      'tinggiBerat': '160 cm / 55 kg',
    },
    {
      'id': 'P002',
      'nama': 'Budi Santoso',
      'umur': '35 Tahun',
      'antrian': 'A002',
      'keluhan': 'Sakit kepala berkepanjangan',
      'alergi': 'Penisilin',
      'jenisLayanan': 'Poli Umum',
      'golDarah': 'B+',
      'tinggiBerat': '170 cm / 70 kg',
    },
    {
      'id': 'P003',
      'nama': 'Citra Dewi',
      'umur': '28 Tahun',
      'antrian': 'A003',
      'keluhan': 'Nyeri perut',
      'alergi': 'Tidak ada',
      'jenisLayanan': 'Umum',
      'golDarah': 'O+',
      'tinggiBerat': '158 cm / 52 kg',
    },
    {
      'id': 'P004',
      'nama': 'Doni Pratama',
      'umur': '45 Tahun',
      'antrian': 'A004',
      'keluhan': 'Asma kambuh',
      'alergi': 'Debu',
      'jenisLayanan': 'Poli Umum',
      'golDarah': 'B-',
      'tinggiBerat': '175 cm / 85 kg',
    },
  ];

  // ==================== DATA DUMMY PEMERIKSAAN ====================
  static final List<Map<String, dynamic>> dummyPemeriksaanList = [
    // P001 - Anisa Ayu (sudah selesai) - dengan riwayat sebelumnya
    {
      'pasienId': 'P001',
      'dokter': 'dr. Faizal Qadri, Sp.PD',
      'diagnosa': 'ISPA (Infeksi Saluran Pernapasan Akut)',
      'keluhan': 'Pasien mengeluh demam sejak 2 hari yang lalu disertai batuk berdahak',
      'tindakan': 'Pemberian obat antipiretik dan ekspektoran, istirahat yang cukup',
      'tandaVital': {
        'tekananDarah': '120/80',
        'suhu': '38.5',
        'nadi': '85',
        'pernapasan': '20',
      },
      'obatList': [
        {'nama': 'Paracetamol', 'dosis': '3x500mg'},
        {'nama': 'OBH Combi', 'dosis': '3x1 sendok'},
      ],
      'catatan': 'Kontrol kembali jika demam tidak turun dalam 3 hari',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      'isPemeriksaanTerbaru': true,
    },
    // P002 - Budi Santoso (sudah selesai)
    {
      'pasienId': 'P002',
      'dokter': 'dr. Sarah Amelia, Sp.S',
      'diagnosa': 'Tension Type Headache',
      'keluhan': 'Sakit kepala tegang, terasa seperti diikat di kepala, tidak berdenyut',
      'tindakan': 'Manajemen stres, istirahat cukup, pemberian analgesik',
      'tandaVital': {
        'tekananDarah': '130/85',
        'suhu': '36.8',
        'nadi': '78',
        'pernapasan': '18',
      },
      'obatList': [
        {'nama': 'Ibuprofen', 'dosis': '3x400mg'},
        {'nama': 'Vitamin B Complex', 'dosis': '1x1 tablet'},
      ],
      'catatan': 'Kurangi screen time, olahraga teratur',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
      'isPemeriksaanTerbaru': true,
    },
    // P003 - Citra Dewi (sudah selesai)
    {
      'pasienId': 'P003',
      'dokter': 'dr. Ahmad Hidayat, Sp.PD',
      'diagnosa': 'Gastritis Akut',
      'keluhan': 'Nyeri ulu hati, mual, perut kembung sejak 1 hari',
      'tindakan': 'Pemberian obat antasida dan pengatur pola makan',
      'tandaVital': {
        'tekananDarah': '110/70',
        'suhu': '36.8',
        'nadi': '78',
        'pernapasan': '18',
      },
      'obatList': [
        {'nama': 'Omeprazole', 'dosis': '2x20mg'},
        {'nama': 'Antasida', 'dosis': '3x1 tablet'},
      ],
      'catatan': 'Hindari makanan pedas dan asam, makan teratur',
      'timestamp': DateTime.now().subtract(Duration(hours: 8)).toIso8601String(),
      'isPemeriksaanTerbaru': true,
    },
    // P004 - Doni Pratama (sudah selesai)
    {
      'pasienId': 'P004',
      'dokter': 'dr. Rina Kusuma, Sp.P',
      'diagnosa': 'Asma Bronkial Eksaserbasi Akut',
      'keluhan': 'Sesak napas, batuk, mengi sejak tadi malam',
      'tindakan': 'Nebulisasi, bronkodilator, edukasi penggunaan inhaler',
      'tandaVital': {
        'tekananDarah': '125/82',
        'suhu': '37.2',
        'nadi': '92',
        'pernapasan': '24',
      },
      'obatList': [
        {'nama': 'Salbutamol Inhaler', 'dosis': '3-4x semprot saat sesak'},
        {'nama': 'Methylprednisolone', 'dosis': '1x8mg'},
        {'nama': 'Ambroxol', 'dosis': '3x30mg'},
      ],
      'catatan': 'Hindari debu, asap rokok, udara dingin. Kontrol 1 minggu lagi',
      'timestamp': DateTime.now().subtract(Duration(hours: 10)).toIso8601String(),
      'isPemeriksaanTerbaru': true,
    },
  ];

  // ==================== INISIALISASI DATA ====================
  void initializeDummyData() {
    // Inisialisasi pasien
    final existingPasien = _box.read<List>(_keyPasien);
    if (existingPasien == null || existingPasien.isEmpty) {
      _box.write(_keyPasien, dummyPasienList);
    }

    // Inisialisasi pemeriksaan
    final existingPemeriksaan = getAllPemeriksaan();
    if (existingPemeriksaan.isEmpty) {
      for (var pemeriksaan in dummyPemeriksaanList) {
        savePemeriksaan(pemeriksaan);
      }
    }
  }

  // ==================== PASIEN METHODS ====================
  List<Map<String, dynamic>> getAllPasien() {
    final data = _box.read<List>(_keyPasien);
    if (data == null) return dummyPasienList;
    return List<Map<String, dynamic>>.from(data.map((item) => Map<String, dynamic>.from(item)));
  }

  Map<String, dynamic>? getPasienById(String pasienId) {
    final allPasien = getAllPasien();
    try {
      return allPasien.firstWhere((p) => p['id'] == pasienId);
    } catch (e) {
      return null;
    }
  }

  // ==================== PEMERIKSAAN METHODS ====================

  // Get all pemeriksaan (session only)
  List<Map<String, dynamic>> getAllPemeriksaan() {
    final data = _box.read<List>(_keyPemeriksaan);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data.map((item) => Map<String, dynamic>.from(item)));
  }

  // Get pemeriksaan by pasien ID
  Map<String, dynamic>? getPemeriksaanByPasienId(String pasienId) {
    final allPemeriksaan = getAllPemeriksaan();
    try {
      return allPemeriksaan.firstWhere((p) => p['pasienId'] == pasienId);
    } catch (e) {
      return null;
    }
  }

  // Save hasil pemeriksaan
  Future<void> savePemeriksaan(Map<String, dynamic> pemeriksaan) async {
    final allPemeriksaan = getAllPemeriksaan();
    
    // Cek apakah sudah ada pemeriksaan untuk pasien ini
    final existingIndex = allPemeriksaan.indexWhere((p) => p['pasienId'] == pemeriksaan['pasienId']);
    
    if (existingIndex != -1) {
      // Update existing
      allPemeriksaan[existingIndex] = pemeriksaan;
    } else {
      // Add new
      allPemeriksaan.add(pemeriksaan);
    }
    
    await _box.write(_keyPemeriksaan, allPemeriksaan);
  }

  // Delete pemeriksaan
  Future<void> deletePemeriksaan(String pasienId) async {
    final allPemeriksaan = getAllPemeriksaan();
    allPemeriksaan.removeWhere((p) => p['pasienId'] == pasienId);
    await _box.write(_keyPemeriksaan, allPemeriksaan);
  }

  // Clear all (untuk demo reset)
  Future<void> clearAll() async {
    await _box.remove(_keyPemeriksaan);
  }
}
