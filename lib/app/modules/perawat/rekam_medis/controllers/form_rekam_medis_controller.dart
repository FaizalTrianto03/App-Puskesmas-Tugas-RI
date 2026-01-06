import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../data/services/pemeriksaan/pemeriksaan_service.dart';
import '../../../../data/services/firestore/user_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../detail_pemeriksaan/views/detail_pemeriksaan_view.dart';

class FormRekamMedisController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();
  final PemeriksaanService _pemeriksaanService = PemeriksaanService();
  final UserFirestoreService _userService = UserFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  // Controllers untuk Identitas Pasien (read-only)
  final namaPasienController = TextEditingController();
  final noRekamMedisController = TextEditingController();
  final noAntrianController = TextEditingController();
  final usiaController = TextEditingController();
  final poliTujuanController = TextEditingController();
  
  // Controllers untuk Tanda Vital
  final tekananDarahSistolikController = TextEditingController();
  final tekananDarahDiastolikController = TextEditingController();
  final nadiController = TextEditingController();
  final suhuController = TextEditingController();
  final pernapasanController = TextEditingController();
  
  // Controllers untuk Antropometri
  final beratBadanController = TextEditingController();
  final tinggiBadanController = TextEditingController();
  final imtController = TextEditingController();
  
  // Controllers untuk Keluhan & Anamnesis
  final keluhanUtamaController = TextEditingController();
  final riwayatPenyakitController = TextEditingController();
  final alergiController = TextEditingController();

  // Dokter assignment
  final dokterList = <Map<String, dynamic>>[].obs;
  final selectedDokterId = Rxn<String>();
  final selectedDokterNama = Rxn<String>();
  final isLoadingDokter = false.obs;

  // Data pasien saat ini
  Map<String, dynamic>? pasienData;

  @override
  void onInit() {
    super.onInit();
    
    // Add listener untuk auto-calculate IMT
    beratBadanController.addListener(_calculateIMT);
    tinggiBadanController.addListener(_calculateIMT);
    
    // Load list dokter
    loadDokterList();
  }

  @override
  void onClose() {
    // Dispose all controllers
    namaPasienController.dispose();
    noRekamMedisController.dispose();
    noAntrianController.dispose();
    usiaController.dispose();
    poliTujuanController.dispose();
    tekananDarahSistolikController.dispose();
    tekananDarahDiastolikController.dispose();
    nadiController.dispose();
    suhuController.dispose();
    pernapasanController.dispose();
    beratBadanController.dispose();
    tinggiBadanController.dispose();
    imtController.dispose();
    keluhanUtamaController.dispose();
    riwayatPenyakitController.dispose();
    alergiController.dispose();
    super.onClose();
  }

  /// Initialize dengan data pasien dari antrian
  void initializePasienData(Map<String, dynamic> data) {
    pasienData = data;
    
    // Set identitas pasien (read-only)
    namaPasienController.text = data['namaLengkap'] ?? '';
    noRekamMedisController.text = data['noRekamMedis'] ?? '';
    noAntrianController.text = data['queueNumber'] ?? '';
    usiaController.text = _calculateAge(data['tanggalLahir']);
    poliTujuanController.text = data['jenisLayanan'] ?? data['poliklinik'] ?? 'Poli Umum';
    
    // Set keluhan dari data pendaftaran
    keluhanUtamaController.text = data['keluhan'] ?? '';
    
    // Load existing rekam medis jika ada
    _loadExistingRekamMedis(data['id']);
  }

  /// Load list dokter dari Firestore
  Future<void> loadDokterList() async {
    try {
      isLoadingDokter.value = true;
      final result = await _userService.getAllDokter();
      dokterList.value = result;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat daftar dokter');
    } finally {
      isLoadingDokter.value = false;
    }
  }

  /// Set selected dokter
  void setSelectedDokter(String? dokterId) {
    selectedDokterId.value = dokterId;
    
    if (dokterId != null) {
      final dokter = dokterList.firstWhereOrNull((d) => d['id'] == dokterId);
      selectedDokterNama.value = dokter?['namaLengkap'];
    } else {
      selectedDokterNama.value = null;
    }
  }

  /// Load rekam medis yang sudah pernah diinput (jika ada)
  void _loadExistingRekamMedis(String antrianId) {
    final existingData = _pemeriksaanService.getPemeriksaanByPasienId(antrianId);
    
    if (existingData != null) {
      // Load tanda vital
      final tandaVital = existingData['tandaVital'] as Map<String, dynamic>? ?? {};
      
      // Parse tekanan darah (format: "120/80")
      final tekananDarah = tandaVital['tekananDarah']?.toString().split('/') ?? [];
      if (tekananDarah.length == 2) {
        tekananDarahSistolikController.text = tekananDarah[0].trim();
        tekananDarahDiastolikController.text = tekananDarah[1].trim();
      }
      
      nadiController.text = tandaVital['nadi']?.toString() ?? '';
      suhuController.text = tandaVital['suhu']?.toString() ?? '';
      pernapasanController.text = tandaVital['pernapasan']?.toString() ?? '';
      
      // Load antropometri
      beratBadanController.text = existingData['beratBadan']?.toString() ?? '';
      tinggiBadanController.text = existingData['tinggiBadan']?.toString() ?? '';
      
      // Load anamnesis
      riwayatPenyakitController.text = existingData['riwayatPenyakit']?.toString() ?? '';
      alergiController.text = existingData['alergi']?.toString() ?? '';
    }
  }

  /// Calculate IMT otomatis
  void _calculateIMT() {
    final berat = double.tryParse(beratBadanController.text);
    final tinggi = double.tryParse(tinggiBadanController.text);
    
    if (berat != null && tinggi != null && tinggi > 0) {
      final tinggiMeter = tinggi / 100;
      final imt = berat / (tinggiMeter * tinggiMeter);
      imtController.text = imt.toStringAsFixed(1);
    } else {
      imtController.text = '';
    }
  }

  /// Calculate umur dari tanggal lahir
  String _calculateAge(String? tanggalLahir) {
    if (tanggalLahir == null || tanggalLahir.isEmpty) return '-';
    
    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      return '$age Tahun';
    } catch (e) {
      return '-';
    }
  }

  /// Validasi field wajib
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validasi angka
  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }
    return null;
  }

  /// Validasi tekanan darah dengan range normal
  String? validateTekananDarah(String? value, String type) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (type == 'sistolik') {
      if (number < 70 || number > 250) {
        return 'Normal: 70-250';
      }
    } else if (type == 'diastolik') {
      if (number < 40 || number > 150) {
        return 'Normal: 40-150';
      }
    }
    
    return null;
  }

  /// Validasi nadi
  String? validateNadi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (number < 40 || number > 180) {
      return 'Normal: 40-180 bpm';
    }
    
    return null;
  }

  /// Validasi suhu
  String? validateSuhu(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (number < 35 || number > 42) {
      return 'Normal: 35-42°C';
    }
    
    return null;
  }

  /// Validasi pernapasan
  String? validatePernapasan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (number < 10 || number > 40) {
      return 'Normal: 10-40 x/mnt';
    }
    
    return null;
  }

  /// Validasi berat badan
  String? validateBeratBadan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (number < 1 || number > 300) {
      return 'Tidak valid';
    }
    
    return null;
  }

  /// Validasi tinggi badan
  String? validateTinggiBadan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Harus angka';
    }
    
    if (number < 50 || number > 250) {
      return 'Tidak valid';
    }
    
    return null;
  }

  /// Get status IMT
  String getStatusIMT() {
    final imtValue = double.tryParse(imtController.text);
    if (imtValue == null) return '';
    
    if (imtValue < 18.5) {
      return 'Berat Kurang';
    } else if (imtValue < 25) {
      return 'Normal';
    } else if (imtValue < 30) {
      return 'Berat Lebih';
    } else {
      return 'Obesitas';
    }
  }

  /// Get color untuk status IMT
  Color getStatusIMTColor() {
    final imtValue = double.tryParse(imtController.text);
    if (imtValue == null) return Colors.grey;
    
    if (imtValue < 18.5 || imtValue >= 30) {
      return Colors.red;
    } else if (imtValue < 25) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  /// Simpan rekam medis
  Future<void> simpanRekamMedis() async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Mohon lengkapi semua field dengan benar');
      return;
    }

    if (pasienData == null) {
      SnackbarHelper.showError('Data pasien tidak valid');
      return;
    }

    isLoading.value = true;

    try {
      final perawatId = _sessionService.getUserId();
      final perawatName = _sessionService.getNamaLengkap();

      if (perawatId == null || perawatName == null) {
        SnackbarHelper.showError('Sesi tidak valid');
        isLoading.value = false;
        return;
      }

      // Prepare rekam medis data
      final rekamMedisData = {
        'antrianId': pasienData!['id'],
        'pasienId': pasienData!['pasienId'],
        'pasienNama': pasienData!['namaLengkap'],
        'noRekamMedis': pasienData!['noRekamMedis'],
        'perawatId': perawatId,
        'perawatName': perawatName,
        'poliklinik': pasienData!['poliklinik'],
        
        // Tanda Vital
        'tandaVital': {
          'tekananDarah': '${tekananDarahSistolikController.text}/${tekananDarahDiastolikController.text}',
          'nadi': nadiController.text,
          'suhu': suhuController.text,
          'pernapasan': pernapasanController.text,
        },
        
        // Antropometri
        'beratBadan': beratBadanController.text,
        'tinggiBadan': tinggiBadanController.text,
        'imt': imtController.text,
        'statusIMT': getStatusIMT(),
        
        // Keluhan & Anamnesis
        'keluhanUtama': keluhanUtamaController.text.trim(),
        'riwayatPenyakit': riwayatPenyakitController.text.trim().isEmpty 
            ? 'Tidak ada' 
            : riwayatPenyakitController.text.trim(),
        'alergi': alergiController.text.trim().isEmpty 
            ? 'Tidak ada' 
            : alergiController.text.trim(),
        
        'timestamp': DateTime.now().toIso8601String(),
        'inputBy': 'perawat',
      };

      // Simpan rekam medis
      await _pemeriksaanService.savePemeriksaan(rekamMedisData);

      isLoading.value = false;

      SnackbarHelper.showSuccess('Rekam medis berhasil disimpan!');
      
      // Kembali ke halaman sebelumnya dengan result success
      await Future.delayed(const Duration(milliseconds: 600));
      Get.back(result: true);
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Gagal menyimpan: $e');
    }
  }

  /// Reset form
  void resetForm() {
    formKey.currentState?.reset();
    
    // Clear semua field kecuali identitas pasien
    tekananDarahSistolikController.clear();
    tekananDarahDiastolikController.clear();
    nadiController.clear();
    suhuController.clear();
    pernapasanController.clear();
    beratBadanController.clear();
    tinggiBadanController.clear();
    imtController.clear();
    keluhanUtamaController.clear();
    riwayatPenyakitController.clear();
    alergiController.clear();
  }

  /// Simpan data dan verifikasi pasien ke Firestore
  Future<void> simpanDanVerifikasi() async {
    // Validasi manual field required (pernapasan opsional)
    if (tekananDarahSistolikController.text.trim().isEmpty ||
        tekananDarahDiastolikController.text.trim().isEmpty ||
        nadiController.text.trim().isEmpty ||
        suhuController.text.trim().isEmpty ||
        beratBadanController.text.trim().isEmpty ||
        tinggiBadanController.text.trim().isEmpty ||
        keluhanUtamaController.text.trim().isEmpty ||
        alergiController.text.trim().isEmpty) {
      SnackbarHelper.showError('Mohon lengkapi semua field yang bertanda *');
      return;
    }

    // Validasi dokter assignment
    if (selectedDokterId.value == null || selectedDokterNama.value == null) {
      SnackbarHelper.showError('Mohon pilih dokter pemeriksa');
      return;
    }
    
    // Konfirmasi sebelum simpan dan verifikasi
    final confirm = await ConfirmationDialog.show(
      title: 'Simpan dan Verifikasi?',
      message: 'Data pemeriksaan akan disimpan dan pasien akan diverifikasi untuk menunggu dokter. Apakah Anda yakin?',
      type: ConfirmationType.confirmation,
      confirmText: 'Ya, Simpan',
      cancelText: 'Batal',
    );
    
    if (confirm != true) return;
    
    isLoading.value = true;
    
    try {
      final perawatId = _sessionService.getUserId();
      final perawatName = _sessionService.getNamaLengkap();
      final antrianId = pasienData!['id'];
      
      if (perawatId == null || perawatName == null) {
        SnackbarHelper.showError('Sesi tidak valid');
        isLoading.value = false;
        return;
      }
      
      // Update antrian dengan perawatData lengkap
      await _firestore.collection('antrian').doc(antrianId).update({
        'status': 'menunggu_dokter',
        'dokterId': selectedDokterId.value,
        'dokterNama': selectedDokterNama.value,
        'perawatData': {
          'perawatId': perawatId,
          'perawatName': perawatName,
          'verifiedAt': FieldValue.serverTimestamp(),
          // Tanda Vital
          'tekananDarahSistolik': int.parse(tekananDarahSistolikController.text.trim()),
          'tekananDarahDiastolik': int.parse(tekananDarahDiastolikController.text.trim()),
          'nadi': int.parse(nadiController.text.trim()),
          'suhu': double.parse(suhuController.text.trim()),
          'pernapasan': pernapasanController.text.trim().isEmpty 
              ? null 
              : int.parse(pernapasanController.text.trim()),
          // Antropometri
          'beratBadan': double.parse(beratBadanController.text.trim()),
          'tinggiBadan': int.parse(tinggiBadanController.text.trim()),
          'imt': double.parse(imtController.text.trim()),
          // Keluhan & Anamnesis
          'keluhanUtama': keluhanUtamaController.text.trim(),
          'riwayatPenyakit': riwayatPenyakitController.text.trim().isEmpty
              ? 'Tidak ada'
              : riwayatPenyakitController.text.trim(),
          'alergi': alergiController.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      isLoading.value = false;
      SnackbarHelper.showSuccess('Pasien berhasil diverifikasi!');
      
      // Ambil data terbaru dari Firestore untuk detail view
      final updatedDoc = await _firestore.collection('antrian').doc(antrianId).get();
      final updatedData = updatedDoc.data();
      
      if (updatedData != null) {
        updatedData['id'] = updatedDoc.id;
        
        // Navigate ke Detail Pemeriksaan (readonly view)
        await Future.delayed(const Duration(milliseconds: 500));
        Get.off(
          () => const DetailPemeriksaanView(),
          arguments: updatedData,
        );
      } else {
        // Fallback jika data tidak ditemukan
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      }
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Gagal menyimpan: ${e.toString()}');
    }
  }
}

