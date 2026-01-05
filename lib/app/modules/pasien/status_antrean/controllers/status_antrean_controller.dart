import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class StatusAntreanController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService =
      UserProfileFirestoreService();

  final antrianData = Rxn<AntrianModel>();
  final userProfile = Rxn<UserProfileModel>();
  final queuePosition = 0.obs;
  final totalQueue = 0.obs; // Total antrian hari ini untuk poli yang sama
  final progressPercentage = 0.0.obs; // Progress dalam persen (0.0 - 1.0)
  final estimatedTime =
      ''.obs; // minutes remaining as string, or '0' for segera
  final isLoading = false.obs;
  final isInitialLoading = true.obs; // Flag untuk loading pertama kali

  // ✅ Observable untuk current timeline info (untuk preview di dashboard)
  final currentTimelineStage =
      ''.obs; // 'pendaftaran', 'perawat', 'dokter', 'apoteker', 'selesai'
  final currentTimelineStatus = ''.obs; // 'menunggu', 'dilayani', 'selesai'
  final currentTimelineDescription = ''.obs; // Deskripsi detail

  // Form pembatalan
  final alasanDropdownController = TextEditingController();
  final alasanCustomController = TextEditingController();
  final showCustomAlasan = false.obs;

  // ✅ GANTI Timer dengan Stream Subscription untuk real-time updates
  StreamSubscription? _antrianSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _watchAntrianRealtime(); // ✅ Gunakan stream instead of timer
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      userProfile.value = profile;
    } catch (e) {
      // Silent fail - profile is optional
    }
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel(); // ✅ Cancel stream subscription
    alasanDropdownController.dispose();
    alasanCustomController.dispose();
    super.onClose();
  }

  // ✅ Real-time stream untuk update antrian tanpa polling
  void _watchAntrianRealtime() {
    isInitialLoading.value = true;

    _antrianSubscription?.cancel();
    _antrianSubscription = _antrianService.watchActiveAntrian().listen(
      (antrian) async {
        isInitialLoading.value = false;

        if (antrian == null) {
          // Tidak ada antrian aktif, redirect ke dashboard
          if (antrianData.value != null) {
            // Sebelumnya ada antrian, sekarang null = selesai/dibatalkan
            SnackbarHelper.showInfo('Antrian selesai');
          }
          Get.offAllNamed(Routes.pasienDashboard);
          return;
        }

        antrianData.value = antrian;

        // Update posisi antrian dan timeline info
        await _updateQueuePosition();
        _updateCurrentTimeline();
      },
      onError: (error) {
        isInitialLoading.value = false;
        SnackbarHelper.showError('Gagal memuat data antrian');
      },
    );
  }

  // ✅ Fallback load data (untuk manual refresh)
  Future<void> _loadAntrianData() async {
    try {
      isInitialLoading.value = true;

      // Fetch antrian aktif langsung dari Firestore
      final antrian = await _antrianService.getActiveAntrian();

      isInitialLoading.value = false;

      if (antrian == null) {
        SnackbarHelper.showInfo('Tidak ada antrian aktif');
        Get.offAllNamed(Routes.pasienDashboard);
        return;
      }

      antrianData.value = antrian;

      // Update posisi antrian
      await _updateQueuePosition();
      _updateCurrentTimeline();
    } catch (error) {
      isInitialLoading.value = false;
      SnackbarHelper.showError('Gagal memuat data antrian');
    }
  }

  // ✅ Update current timeline info untuk preview di dashboard
  void _updateCurrentTimeline() {
    final status = antrianData.value?.status ?? '';

    // Tentukan stage saat ini
    if (status == 'menunggu' ||
        status == 'menunggu_verifikasi' ||
        status == 'menunggu_perawat' ||
        status == 'dilayani_perawat') {
      currentTimelineStage.value = 'perawat';
      if (status == 'dilayani_perawat') {
        currentTimelineStatus.value = 'dilayani';
        currentTimelineDescription.value = 'Sedang diperiksa oleh perawat';
      } else {
        currentTimelineStatus.value = 'menunggu';
        currentTimelineDescription.value = 'Menunggu pemeriksaan perawat';
      }
    } else if (status == 'menunggu_dokter' ||
        status == 'dilayani_dokter' ||
        status == 'sedang_dilayani') {
      currentTimelineStage.value = 'dokter';
      if (status == 'dilayani_dokter' || status == 'sedang_dilayani') {
        currentTimelineStatus.value = 'dilayani';
        currentTimelineDescription.value = 'Sedang diperiksa oleh dokter';
      } else {
        currentTimelineStatus.value = 'menunggu';
        currentTimelineDescription.value = 'Menunggu pemeriksaan dokter';
      }
    } else if (status == 'selesai_diperiksa' ||
        status == 'menunggu_apoteker' ||
        status == 'dilayani_apoteker') {
      currentTimelineStage.value = 'apoteker';
      if (status == 'dilayani_apoteker') {
        currentTimelineStatus.value = 'dilayani';
        currentTimelineDescription.value = 'Obat sedang disiapkan';
      } else {
        currentTimelineStatus.value = 'menunggu';
        currentTimelineDescription.value = 'Menunggu penyiapan obat';
      }
    } else if (status == 'siap_ambil_obat') {
      currentTimelineStage.value = 'pembayaran';
      currentTimelineStatus.value = 'siap';
      currentTimelineDescription.value = 'Obat siap - Silakan bayar dan ambil';
    } else if (status == 'selesai') {
      currentTimelineStage.value = 'selesai';
      currentTimelineStatus.value = 'selesai';
      currentTimelineDescription.value = 'Pelayanan selesai';
    } else if (status == 'pending') {
      currentTimelineStage.value = 'pending';
      currentTimelineStatus.value = 'pending';
      currentTimelineDescription.value =
          'Antrian tertunda - Harap tetap menunggu';
    } else if (status == 'dilewati') {
      currentTimelineStage.value = 'dilewati';
      currentTimelineStatus.value = 'dilewati';
      currentTimelineDescription.value = 'Antrian dilewati sementara';
    } else if (status == 'dibatalkan') {
      currentTimelineStage.value = 'dibatalkan';
      currentTimelineStatus.value = 'dibatalkan';
      currentTimelineDescription.value = 'Antrian dibatalkan';
    } else {
      currentTimelineStage.value = 'pendaftaran';
      currentTimelineStatus.value = 'menunggu';
      currentTimelineDescription.value = 'Menunggu verifikasi';
    }
  }

  Future<void> _updateQueuePosition() async {
    if (antrianData.value == null) return;

    try {
      // Get posisi antrian saat ini
      final position = await _antrianService.getQueuePosition(
        antrianData.value!.queueNumber,
        antrianData.value!.jenisLayanan,
      );

      // Get total antrian hari ini untuk poli yang sama
      final total = await _antrianService.getTodayQueueCountByPoli(
        antrianData.value!.jenisLayanan,
      );

      queuePosition.value = position;
      totalQueue.value = total;

      // ✅ HITUNG PROGRESS BERDASARKAN STATUS + POSISI ANTRIAN
      final status = antrianData.value?.status ?? '';
      double baseProgress = 0.0;

      // Base progress berdasarkan status workflow (5 tahap pelayanan)
      switch (status) {
        case 'menunggu':
        case 'menunggu_verifikasi':
          baseProgress = 0.15; // 15% - Pendaftaran selesai, menunggu verifikasi
          break;
        case 'dilewati':
          baseProgress = 0.10; // 10% - Dilewati sementara
          break;
        case 'pending':
          baseProgress = 0.12; // 12% - Antrian tertunda
          break;
        case 'menunggu_perawat':
          baseProgress = 0.25; // 25% - Menunggu dipanggil perawat
          break;
        case 'dilayani_perawat':
          baseProgress = 0.40; // 40% - Sedang diperiksa perawat
          break;
        case 'menunggu_dokter':
          baseProgress = 0.50; // 50% - Menunggu dipanggil dokter
          break;
        case 'dilayani_dokter':
        case 'sedang_dilayani':
          baseProgress = 0.65; // 65% - Sedang diperiksa dokter
          break;
        case 'selesai_diperiksa':
          baseProgress = 0.75; // 75% - Selesai diperiksa, menunggu obat
          break;
        case 'menunggu_apoteker':
          baseProgress = 0.80; // 80% - Menunggu obat disiapkan
          break;
        case 'dilayani_apoteker':
          baseProgress = 0.85; // 85% - Obat sedang disiapkan
          break;
        case 'siap_ambil_obat':
          baseProgress = 0.90; // 90% - Obat siap, menunggu pembayaran
          break;
        case 'dipanggil':
          baseProgress = 0.85; // 85% - Dipanggil ke ruangan
          break;
        case 'dibatalkan':
          baseProgress = 0.0; // 0% - Dibatalkan
          break;
        case 'selesai':
          baseProgress = 1.0; // 100% - Selesai semua
          break;
        default:
          baseProgress = 0.10; // 10% - Status tidak diketahui
      }

      // Tambah progress berdasarkan posisi antrian (max 10% bonus)
      // Semakin sedikit antrian di depan, semakin tinggi progress
      double positionBonus = 0.0;
      if (total > 0 && position > 0) {
        // Formula: (total - position) / total * 0.1
        // Contoh: Posisi 1 dari 10 = (10-1)/10 * 0.1 = 0.09 (9% bonus)
        //         Posisi 5 dari 10 = (10-5)/10 * 0.1 = 0.05 (5% bonus)
        //         Posisi 10 dari 10 = (10-10)/10 * 0.1 = 0.0 (0% bonus)
        positionBonus = ((total - position) / total) * 0.10;
      }

      progressPercentage.value = (baseProgress + positionBonus).clamp(0.0, 1.0);

      // Hitung estimasi waktu
      if (position > 0) {
        final minutes = position * 15; // 15 menit per pasien
        estimatedTime.value = minutes.toString();
      } else {
        estimatedTime.value = '0';
      }
    } catch (e) {
      // Error calculating position
    }
  }

  Future<void> refreshData() async {
    // Manual refresh
    isLoading.value = true;
    await _loadAntrianData();
    isLoading.value = false;
  }

  String getStatusText() {
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi Perawat';
      case 'dilewati':
        return 'Antrian Dilewati Sementara';
      case 'pending':
        return 'Antrian Tertunda - Harap Tunggu';
      case 'menunggu_dokter':
        return 'Menunggu Dokter';
      case 'sedang_dilayani':
      case 'dilayani_dokter':
        return 'Sedang Dilayani Dokter';
      case 'selesai_diperiksa':
        return 'Selesai Diperiksa - Menunggu Obat';
      case 'menunggu_apoteker':
        return 'Menunggu Penyiapan Obat';
      case 'dilayani_apoteker':
        return 'Obat Sedang Disiapkan';
      case 'siap_ambil_obat':
        return 'Obat Siap - Silakan Bayar';
      case 'dipanggil':
        return 'Dipanggil - Segera ke Ruangan';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  String getStatusColor() {
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
      case 'menunggu_verifikasi':
        return 'orange';
      case 'dilewati':
        return 'deepOrange';
      case 'pending':
        return 'amber';
      case 'menunggu_dokter':
        return 'blue';
      case 'sedang_dilayani':
      case 'dilayani_dokter':
        return 'green';
      case 'selesai_diperiksa':
      case 'menunggu_apoteker':
        return 'purple';
      case 'dilayani_apoteker':
        return 'purple';
      case 'siap_ambil_obat':
        return 'teal';
      case 'dipanggil':
        return 'green';
      case 'selesai':
        return 'gray';
      case 'dibatalkan':
        return 'red';
      default:
        return 'gray';
    }
  }

  void showPembatalanModal() {
    // Reset form
    alasanDropdownController.clear();
    alasanCustomController.clear();
    showCustomAlasan.value = false;

    final alasanOptions = [
      'Berhalangan hadir',
      'Jadwal bentrok',
      'Kondisi sudah membaik',
      'Salah pilih poli',
      'Lainnya',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4242).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.cancel_outlined,
                            color: Color(0xFFFF4242),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Batalkan Antrian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF4242),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dropdown Alasan
                    const Text(
                      'Alasan Pembatalan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Pilih alasan pembatalan'),
                          value:
                              alasanDropdownController.text.isEmpty
                                  ? null
                                  : alasanDropdownController.text,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF02B1BA),
                          ),
                          items:
                              alasanOptions.map((alasan) {
                                return DropdownMenuItem(
                                  value: alasan,
                                  child: Text(alasan),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              alasanDropdownController.text = value ?? '';
                              showCustomAlasan.value = (value == 'Lainnya');
                              if (value != 'Lainnya') {
                                alasanCustomController.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    // Field Custom (hanya muncul jika pilih Lainnya)
                    if (showCustomAlasan.value) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Alasan Lainnya',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: alasanCustomController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Tuliskan alasan pembatalan...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _prosesPembatalan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4242),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Batalkan Antrian',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _prosesPembatalan() async {
    if (antrianData.value == null) return;

    // Validasi input
    if (alasanDropdownController.text.isEmpty) {
      SnackbarHelper.showError('Harap pilih alasan pembatalan');
      return;
    }

    if (alasanDropdownController.text == 'Lainnya' &&
        alasanCustomController.text.trim().isEmpty) {
      SnackbarHelper.showError('Harap isi alasan pembatalan');
      return;
    }

    // Tentukan alasan final
    final alasanFinal =
        alasanDropdownController.text == 'Lainnya'
            ? alasanCustomController.text.trim()
            : alasanDropdownController.text;

    Get.back(); // Tutup modal

    isLoading.value = true;

    try {
      final antrianId = antrianData.value!.id;
      if (antrianId != null) {
        await _antrianService.cancelAntrianWithReason(antrianId, alasanFinal);

        SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.pasienDashboard);
        });
      } else {
        SnackbarHelper.showError('ID antrian tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal membatalkan antrian: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool canCancelQueue() {
    final status = antrianData.value?.status ?? '';
    // Hanya bisa dibatalkan jika masih status menunggu verifikasi
    return status == 'menunggu' || status == 'menunggu_verifikasi';
  }

  void kembaliKeDashboard() {
    Get.offAllNamed(Routes.pasienDashboard);
  }

  // ============ PEMBAYARAN ============

  /// Cek apakah pasien adalah BPJS
  bool get isBPJS =>
      antrianData.value?.nomorBPJS != null &&
      antrianData.value!.nomorBPJS!.isNotEmpty;

  /// Get total biaya obat (dari pembayaranData atau hitung dari resepObat)
  int get totalBiayaObat {
    // Coba ambil dari pembayaranData dulu
    final pembayaran = antrianData.value?.pembayaranData;
    final biayaObatFromPembayaran =
        pembayaran?['totalObat'] as int? ?? pembayaran?['biayaObat'] as int?;

    if (biayaObatFromPembayaran != null && biayaObatFromPembayaran > 0) {
      return biayaObatFromPembayaran;
    }

    // Fallback: hitung dari resepObat
    return antrianData.value?.totalBiayaObat ?? 0;
  }

  /// Get total biaya layanan (dummy: 25000 untuk umum, 0 untuk BPJS)
  int get totalBiayaLayanan {
    if (isBPJS) return 0;

    final pembayaran = antrianData.value?.pembayaranData;
    final biayaLayanan =
        pembayaran?['totalLayanan'] as int? ??
        pembayaran?['biayaLayanan'] as int?;

    // Default biaya layanan 25000 jika belum diset
    return biayaLayanan ?? 25000;
  }

  /// Get total pembayaran
  int get totalPembayaran => totalBiayaObat + totalBiayaLayanan;

  /// Cek apakah section pembayaran harus ditampilkan (obat sudah disiapkan)
  bool get siapBayar {
    final status = antrianData.value?.status ?? '';
    return status == 'siap_ambil_obat' ||
        status == 'selesai' ||
        (antrianData.value?.apotekerData?['waktuSiap'] != null);
  }

  /// Cek apakah bisa melakukan pembayaran (selalu bisa saat siap_ambil_obat)
  bool get bisaBayar {
    final status = antrianData.value?.status ?? '';
    return status == 'siap_ambil_obat' && !sudahDibayar;
  }

  /// Cek apakah bisa ambil obat (setelah bayar)
  bool get bisaAmbilObat {
    return sudahDibayar && antrianData.value?.status != 'selesai';
  }

  /// Cek apakah sudah dibayar
  bool get sudahDibayar {
    final pembayaran = antrianData.value?.pembayaranData;
    return pembayaran?['statusPembayaran'] == 'lunas' ||
        pembayaran?['statusPembayaran'] == 'sudah_bayar';
  }

  /// Konfirmasi pembayaran saja (tanpa set status selesai)
  Future<void> konfirmasiPembayaranSaja() async {
    try {
      isLoading.value = true;

      final antrianId = antrianData.value?.id;
      if (antrianId == null) {
        SnackbarHelper.showError('ID antrian tidak ditemukan');
        return;
      }

      // Update pembayaran data saja, status tetap siap_ambil_obat
      final metodePembayaran = isBPJS ? 'bpjs' : 'tunai';

      await _antrianService.updatePembayaran(
        antrianId: antrianId,
        metodePembayaran: metodePembayaran,
        totalObat: totalBiayaObat,
        totalLayanan: totalBiayaLayanan,
        totalBayar: isBPJS ? 0 : totalPembayaran,
      );

      SnackbarHelper.showSuccess(
        isBPJS
            ? 'Konfirmasi BPJS berhasil'
            : 'Pembayaran berhasil - Silahkan ambil obat',
      );

      // Refresh data
      await _loadAntrianData();
    } catch (e) {
      SnackbarHelper.showError('Gagal memproses pembayaran: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Konfirmasi sudah ambil obat (set status selesai)
  Future<void> konfirmasiAmbilObat() async {
    try {
      isLoading.value = true;

      final antrianId = antrianData.value?.id;
      if (antrianId == null) {
        SnackbarHelper.showError('ID antrian tidak ditemukan');
        return;
      }

      // Set status selesai
      await _antrianService.selesaikanKunjungan(
        antrianId: antrianId,
        metodePembayaran: isBPJS ? 'bpjs' : 'tunai',
        totalObat: totalBiayaObat,
        totalLayanan: totalBiayaLayanan,
        totalBayar: isBPJS ? 0 : totalPembayaran,
        catatan: 'Obat sudah diambil',
      );

      SnackbarHelper.showSuccess('Selesai! Terima kasih telah berkunjung');

      // Refresh data
      await _loadAntrianData();
    } catch (e) {
      SnackbarHelper.showError('Gagal konfirmasi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Konfirmasi pembayaran lama (backward compatibility)
  Future<void> konfirmasiPembayaran() async {
    // Jika sudah bayar, langsung ambil obat
    if (sudahDibayar) {
      await konfirmasiAmbilObat();
    } else {
      // Bayar dulu
      await konfirmasiPembayaranSaja();
    }
  }

  /// Format currency
  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
