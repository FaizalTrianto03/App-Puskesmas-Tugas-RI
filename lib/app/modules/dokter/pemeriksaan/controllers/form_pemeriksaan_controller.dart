import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/obat_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/obat_firestore_service.dart';
import '../../../../data/services/firestore/ruangan_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../views/detail_pemeriksaan_view.dart';

/// Model untuk item resep obat
class ResepObatItem {
  String? idObat;
  String namaObat;
  String dosis;
  int jumlah;
  String satuan;
  String aturanPakai;
  int hargaSatuan;
  int get totalHarga => jumlah * hargaSatuan;

  // Controllers for text fields
  final TextEditingController dosisController;
  final TextEditingController jumlahController;
  final TextEditingController aturanPakaiController;

  ResepObatItem({
    this.idObat,
    this.namaObat = '',
    this.dosis = '',
    this.jumlah = 1,
    this.satuan = 'tablet',
    this.aturanPakai = '',
    this.hargaSatuan = 0,
  })  : dosisController = TextEditingController(text: dosis),
        jumlahController = TextEditingController(text: jumlah > 0 ? jumlah.toString() : '1'),
        aturanPakaiController = TextEditingController(text: aturanPakai);

  Map<String, dynamic> toMap() {
    return {
      'idObat': idObat ?? '',
      'namaObat': namaObat,
      'dosis': dosisController.text.trim(),
      'jumlah': int.tryParse(jumlahController.text) ?? 1,
      'satuan': satuan,
      'aturanPakai': aturanPakaiController.text.trim(),
      'hargaSatuan': hargaSatuan,
      'totalHarga': (int.tryParse(jumlahController.text) ?? 1) * hargaSatuan,
    };
  }

  void dispose() {
    dosisController.dispose();
    jumlahController.dispose();
    aturanPakaiController.dispose();
  }
}

class FormPemeriksaanController extends GetxController {
  final AntrianFirestoreService _antrianFirestoreService = AntrianFirestoreService();
  final ObatFirestoreService _obatFirestoreService = ObatFirestoreService();
  final RuanganFirestoreService _ruanganFirestoreService = RuanganFirestoreService();
  final SessionService _sessionService = Get.find<SessionService>();

  final formKey = GlobalKey<FormState>();

  // Controllers untuk form
  final diagnosaController = TextEditingController();
  final tindakanController = TextEditingController();
  final catatanController = TextEditingController();

  // Master Obat List dari Firestore
  final masterObatList = <ObatModel>[].obs;
  
  // Resep Obat List - struktur lengkap
  final resepObatList = <ResepObatItem>[].obs;
  
  // Ruangan untuk rawat inap
  final ruanganList = <Map<String, dynamic>>[].obs;
  final perluRawatInap = false.obs;
  final selectedRuangan = Rxn<Map<String, dynamic>>();
  
  final isLoading = false.obs;
  final isLoadingMasterData = false.obs;

  // ID dokumen antrian di Firestore (bukan pasienId user)
  String? antrianId;
  String? pasienNama;
  String? jenisPembayaran;

  @override
  void onInit() {
    super.onInit();
    _loadMasterData();
    // Tambah 1 resep obat default
    tambahResepObat();
  }

  Future<void> _loadMasterData() async {
    try {
      isLoadingMasterData.value = true;
      
      // Load master obat yang stoknya masih ada
      final allObat = await _obatFirestoreService.getAllObat();
      masterObatList.value = allObat.where((obat) => obat.stok > 0).toList();
      
      // Load ruangan yang tersedia
      final allRuangan = await _ruanganFirestoreService.getRuanganByStatus('tersedia');
      ruanganList.value = allRuangan;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data master: $e');
    } finally {
      isLoadingMasterData.value = false;
    }
  }

  void initializePasienData(Map<String, dynamic> pasienData) {
    // Ambil document ID antrian (bukan pasienId user)
    antrianId = pasienData['id'] ?? '';
    pasienNama = pasienData['namaLengkap'] ?? pasienData['nama'] ?? '';
    
    // Cek jenis pembayaran berdasarkan BPJS
    final nomorBPJS = pasienData['nomorBPJS'];
    jenisPembayaran = (nomorBPJS != null && nomorBPJS.toString().isNotEmpty) ? 'BPJS' : 'Umum';
  }

  void tambahResepObat() {
    resepObatList.add(ResepObatItem());
  }

  void hapusResepObat(int index) {
    if (resepObatList.length > 1) {
      resepObatList[index].dispose();
      resepObatList.removeAt(index);
    } else {
      SnackbarHelper.showWarning('Minimal 1 obat harus ada');
    }
  }

  /// Dipanggil saat memilih obat dari dropdown/autocomplete
  void pilihObat(int index, ObatModel obat) {
    final item = resepObatList[index];
    item.idObat = obat.id;
    item.namaObat = obat.namaObat;
    item.satuan = obat.satuan;
    item.hargaSatuan = obat.hargaSatuan;
    resepObatList.refresh();
  }

  /// Hitung total biaya obat
  int get totalBiayaObat {
    int total = 0;
    for (var item in resepObatList) {
      if (item.idObat != null && item.idObat!.isNotEmpty) {
        final jumlah = int.tryParse(item.jumlahController.text) ?? 1;
        total += jumlah * item.hargaSatuan;
      }
    }
    return total;
  }

  void toggleRawatInap(bool value) {
    perluRawatInap.value = value;
    if (!value) {
      selectedRuangan.value = null;
    }
  }

  void pilihRuangan(Map<String, dynamic>? ruangan) {
    selectedRuangan.value = ruangan;
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini harus diisi';
    }
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini harus diisi';
    }
    if (double.tryParse(value) == null) {
      return 'Harus berupa angka';
    }
    return null;
  }

  void simpanHasilPemeriksaan() async {
    if (formKey.currentState?.validate() ?? false) {
      // Validasi minimal 1 obat terisi dengan benar
      final validResepObat = resepObatList
          .where((item) =>
              item.idObat != null &&
              item.idObat!.isNotEmpty &&
              item.dosisController.text.trim().isNotEmpty)
          .toList();

      if (validResepObat.isEmpty) {
        SnackbarHelper.showError('Minimal 1 obat harus dipilih dan diisi dosisnya');
        return;
      }

      // Validasi ruangan jika rawat inap
      if (perluRawatInap.value && selectedRuangan.value == null) {
        SnackbarHelper.showError('Pilih ruangan untuk rawat inap');
        return;
      }

      // Validasi antrianId
      if (antrianId == null || antrianId!.isEmpty) {
        SnackbarHelper.showError('Data antrian tidak valid');
        return;
      }

      try {
        isLoading.value = true;

        // Get data dokter dari session - gunakan firebaseUid, fallback ke userId
        final dokterId = _sessionService.getFirebaseUid() ?? _sessionService.getUserId() ?? '';
        final namaDokter = _sessionService.getNamaLengkap() ?? 'Dokter';
        
        if (dokterId.isEmpty) {
          SnackbarHelper.showError('Session tidak valid, silakan login ulang');
          return;
        }

        // Siapkan data resep obat dengan struktur lengkap
        final resepObatData = validResepObat.map((item) => item.toMap()).toList();

        // Simpan langsung ke Firestore menggunakan document ID
        final success = await _antrianFirestoreService.simpanHasilPemeriksaanDokter(
          antrianId: antrianId!,
          dokterId: dokterId,
          dokterNama: namaDokter,
          diagnosa: diagnosaController.text.trim(),
          tindakan: tindakanController.text.trim(),
          catatan: catatanController.text.trim(),
          resepObat: resepObatData,
          perluRawatInap: perluRawatInap.value,
          ruanganId: selectedRuangan.value?['id'],
          ruanganNama: selectedRuangan.value?['namaRuangan'],
        );

        if (success) {
          // Ambil data terbaru untuk ditampilkan di detail view
          final updatedData = await _antrianFirestoreService.getAntrianMapById(antrianId!);
          
          SnackbarHelper.showSuccess('Hasil pemeriksaan berhasil disimpan');

          await Future.delayed(const Duration(milliseconds: 400));
          
          // Navigate ke detail view dengan data terbaru
          if (updatedData != null) {
            Get.off(() => DetailPemeriksaanView(pasienData: updatedData));
          } else {
            Get.back(result: true);
          }
        } else {
          SnackbarHelper.showError('Gagal menyimpan hasil pemeriksaan');
        }
      } catch (e) {
        SnackbarHelper.showError('Gagal menyimpan: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    diagnosaController.dispose();
    tindakanController.dispose();
    catatanController.dispose();
    for (var item in resepObatList) {
      item.dispose();
    }
    super.onClose();
  }
}
