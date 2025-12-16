import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ResepObatService {
  static final ResepObatService _instance = ResepObatService._internal();
  factory ResepObatService() => _instance;
  ResepObatService._internal();

  final GetStorage _box = GetStorage('resep_obat_box');

  // Initialize dummy data
  Future<void> initDummyData() async {
    if (_box.read('resep_list') == null) {
      await _box.write('resep_list', _getDummyResepData());
    }
  }

  // Get all resep obat
  List<Map<String, dynamic>> getAllResep() {
    final data = _box.read('resep_list');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  // Get resep by status
  List<Map<String, dynamic>> getResepByStatus(String status) {
    final allResep = getAllResep();
    return allResep.where((resep) => resep['status'] == status).toList();
  }

  // Get resep belum selesai (Menunggu + Diproses)
  List<Map<String, dynamic>> getResepBelumSelesai() {
    final allResep = getAllResep();
    return allResep
        .where(
          (resep) =>
              resep['status'] == 'Menunggu' || resep['status'] == 'Diproses',
        )
        .toList();
  }

  // Get resep selesai
  List<Map<String, dynamic>> getResepSelesai() {
    return getResepByStatus('Selesai');
  }

  // Get resep by ID
  Map<String, dynamic>? getResepById(String resepId) {
    final allResep = getAllResep();
    try {
      return allResep.firstWhere((resep) => resep['id'] == resepId);
    } catch (e) {
      return null;
    }
  }

  // Update resep status
  Future<bool> updateResepStatus(String resepId, String newStatus) async {
    try {
      final allResep = getAllResep();
      final index = allResep.indexWhere((resep) => resep['id'] == resepId);

      if (index == -1) return false;

      allResep[index]['status'] = newStatus;

      // Update statusColor based on status
      if (newStatus == 'Menunggu') {
        allResep[index]['statusColor'] = const Color(0xFFFF9800).value;
      } else if (newStatus == 'Diproses') {
        allResep[index]['statusColor'] = const Color(0xFF2196F3).value;
      } else if (newStatus == 'Selesai') {
        allResep[index]['statusColor'] = const Color(0xFF4CAF50).value;
        allResep[index]['tanggalSerah'] = DateTime.now().toString();
      }

      await _box.write('resep_list', allResep);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Konfirmasi resep (ubah status ke Diproses)
  Future<bool> konfirmasiResep(String resepId) async {
    return await updateResepStatus(resepId, 'Diproses');
  }

  // Selesaikan resep (ubah status ke Selesai)
  Future<bool> selesaikanResep(String resepId) async {
    return await updateResepStatus(resepId, 'Selesai');
  }

  // Batalkan resep (ubah status ke Batal)
  Future<bool> batalkanResep(String resepId) async {
    return await updateResepStatus(resepId, 'Batal');
  }

  // Add new resep
  Future<bool> addResep(Map<String, dynamic> resepData) async {
    try {
      final allResep = getAllResep();
      resepData['id'] =
          'RSP${(allResep.length + 1).toString().padLeft(3, '0')}';
      resepData['status'] = 'Menunggu';
      resepData['statusColor'] = const Color(0xFFFF9800).value;
      allResep.add(resepData);
      await _box.write('resep_list', allResep);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get statistik
  Map<String, int> getStatistik() {
    final allResep = getAllResep();
    return {
      'total': allResep.length,
      'menunggu': allResep.where((r) => r['status'] == 'Menunggu').length,
      'diproses': allResep.where((r) => r['status'] == 'Diproses').length,
      'selesai': allResep.where((r) => r['status'] == 'Selesai').length,
    };
  }

  // Dummy data
  List<Map<String, dynamic>> _getDummyResepData() {
    return [
      {
        'id': 'RSP001',
        'noAntrean': 'A-012',
        'namaPasien': 'Anisa Ayu',
        'poli': 'Poli Umum',
        'dokter': 'dr. Faizal Qadri',
        'tanggal': '15 Desember 2025, 09:15 WIB',
        'status': 'Menunggu',
        'statusColor': const Color(0xFFFF9800).value,
        'jumlahObat': 3,
        'daftarObat': [
          {
            'nama': 'Paracetamol 500mg',
            'jumlah': '10 tablet',
            'aturan': '3x sehari setelah makan',
            'stok': 245,
          },
          {
            'nama': 'Amoxicillin 500mg',
            'jumlah': '15 kapsul',
            'aturan': '3x sehari sebelum makan',
            'stok': 98,
          },
          {
            'nama': 'Vitamin C 100mg',
            'jumlah': '20 tablet',
            'aturan': '1x sehari',
            'stok': 105,
          },
        ],
      },
      {
        'id': 'RSP002',
        'noAntrean': 'G-015',
        'namaPasien': 'Budi Santoso',
        'poli': 'Poli Gigi',
        'dokter': 'drg. Nisa Ayu',
        'tanggal': '15 Desember 2025, 10:30 WIB',
        'status': 'Menunggu',
        'statusColor': const Color(0xFFFF9800).value,
        'jumlahObat': 2,
        'daftarObat': [
          {
            'nama': 'Asam Mefenamat 500mg',
            'jumlah': '12 tablet',
            'aturan': '3x sehari saat nyeri',
            'stok': 89,
          },
          {
            'nama': 'Chlorhexidine Mouthwash',
            'jumlah': '1 botol (200ml)',
            'aturan': 'Kumur 2x sehari',
            'stok': 34,
          },
        ],
      },
      {
        'id': 'RSP003',
        'noAntrean': 'K-008',
        'namaPasien': 'Siti Rahayu',
        'poli': 'Poli KIA',
        'dokter': 'dr. Siti Nurhaliza',
        'tanggal': '15 Desember 2025, 11:00 WIB',
        'status': 'Menunggu',
        'statusColor': const Color(0xFFFF9800).value,
        'jumlahObat': 2,
        'daftarObat': [
          {
            'nama': 'Tablet Besi (Fe Sulfat)',
            'jumlah': '30 tablet',
            'aturan': '1x sehari setelah makan',
            'stok': 156,
          },
          {
            'nama': 'Asam Folat 1mg',
            'jumlah': '30 tablet',
            'aturan': '1x sehari',
            'stok': 178,
          },
        ],
      },
      {
        'id': 'RSP004',
        'noAntrean': 'A-008',
        'namaPasien': 'Dewi Lestari',
        'poli': 'Poli Umum',
        'dokter': 'dr. Faizal Qadri',
        'tanggal': '14 Desember 2025, 14:20 WIB',
        'tanggalSerah': '14 Desember 2025, 15:00 WIB',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50).value,
        'jumlahObat': 4,
        'daftarObat': [
          {
            'nama': 'Amoxicillin 500mg',
            'jumlah': '15 kapsul',
            'aturan': '3x sehari sebelum makan',
            'stok': 98,
          },
          {
            'nama': 'Paracetamol 500mg',
            'jumlah': '10 tablet',
            'aturan': '3x sehari saat demam',
            'stok': 245,
          },
          {
            'nama': 'OBH Sirup',
            'jumlah': '1 botol (60ml)',
            'aturan': '3x sehari 1 sendok makan',
            'stok': 67,
          },
          {
            'nama': 'Vitamin C 100mg',
            'jumlah': '20 tablet',
            'aturan': '1x sehari',
            'stok': 105,
          },
        ],
      },
      {
        'id': 'RSP005',
        'noAntrean': 'A-005',
        'namaPasien': 'Ahmad Ridwan',
        'poli': 'Poli Umum',
        'dokter': 'dr. Faizal Qadri',
        'tanggal': '14 Desember 2025, 13:15 WIB',
        'tanggalSerah': '14 Desember 2025, 13:45 WIB',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50).value,
        'jumlahObat': 2,
        'daftarObat': [
          {
            'nama': 'Metformin 500mg',
            'jumlah': '60 tablet',
            'aturan': '2x sehari setelah makan',
            'stok': 234,
          },
          {
            'nama': 'Captopril 25mg',
            'jumlah': '30 tablet',
            'aturan': '1x sehari pagi',
            'stok': 187,
          },
        ],
      },
    ];
  }
}
