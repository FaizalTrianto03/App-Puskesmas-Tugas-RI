import 'dart:async'; // ✅ Import untuk StreamSubscription

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/user_profile_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../dashboard/controllers/pasien_dashboard_controller.dart';
import '../../../../routes/app_pages.dart';
import '../../status_antrean/views/status_antrean_view.dart';

class PasienPendaftaranView extends StatefulWidget {
  const PasienPendaftaranView({Key? key}) : super(key: key);

  @override
  State<PasienPendaftaranView> createState() => _PasienPendaftaranViewState();
}

class _PasienPendaftaranViewState extends State<PasienPendaftaranView> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPoli;
  final TextEditingController _keluhanController = TextEditingController();
  final FocusNode _keluhanFocusNode = FocusNode();
  final FocusNode _poliFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // Firestore services
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  
  // User data from Firestore
  UserProfileModel? _userProfile;
  bool _isLoadingProfile = true;
  
  final _poliKey = GlobalKey();
  final _keluhanKey = GlobalKey();
  
  String? selectedPembayaran;
  bool showPoliOptions = false;
  String? poliError;
  String? keluhanError;
  String? pembayaranError;
  bool isHoverBPJS = false;
  bool isHoverUmum = false;
  bool _isKeluhanFocused = false;
  bool _isPoliFocused = false;
  bool _hasActiveQueue = false;
  bool _isCheckingActiveQueue = true;
  StreamSubscription? _antrianStreamSubscription; // ✅ Tambahkan stream listener

  DateTime? _estimatedTime;
  bool _isEstimatingTime = false;

  final List<String> poliList = [
    'Poli Umum',
    'Poli Gigi',
    'Poli KIA',
  ];

  // Mapping dokter berdasarkan poli
  String _getDokterByPoli() {
    if (selectedPoli == 'Poli Umum') {
      return 'dr. Faizal Qadri';
    } else if (selectedPoli == 'Poli Gigi') {
      return 'drg. Nisa Ayu';
    } else if (selectedPoli == 'Poli KIA') {
      return 'dr. Siti Nurhaliza';
    }
    return '-';
  }

  @override
  void initState() {
    super.initState();
    
    _keluhanController.clear();
    selectedPoli = null;
    selectedPembayaran = null;
    poliError = null;
    keluhanError = null;
    pembayaranError = null;
    showPoliOptions = false;
    
    _keluhanFocusNode.addListener(() {
      setState(() {
        _isKeluhanFocused = _keluhanFocusNode.hasFocus;
      });
    });
    
    _poliFocusNode.addListener(() {
      setState(() {
        _isPoliFocused = _poliFocusNode.hasFocus;
      });
    });
    
    // Load user profile from Firestore
    _loadUserProfile();
    _checkActiveQueue();
    
    // ✅ Setup real-time listener untuk auto-update status antrian
    _setupAntrianListener();
  }

  /// ✅ Setup stream listener untuk auto-update _hasActiveQueue
  void _setupAntrianListener() {
    print('[PasienPendaftaranView] Setting up antrian stream listener');
    
    _antrianStreamSubscription?.cancel(); // Cancel existing listener jika ada
    
    _antrianStreamSubscription = _antrianService.watchActiveAntrian().listen(
      (activeAntrian) {
        if (!mounted) return;
        
        final hasActive = activeAntrian != null;
        
        print('[PasienPendaftaranView] Stream update: hasActiveQueue=$hasActive, queueNumber=${activeAntrian?.queueNumber}');
        
        setState(() {
          _hasActiveQueue = hasActive;
          _isCheckingActiveQueue = false;
        });
      },
      onError: (error) {
        print('[PasienPendaftaranView] Stream error: $error');
        if (!mounted) return;
        setState(() {
          _hasActiveQueue = false;
          _isCheckingActiveQueue = false;
        });
      },
    );
  }

  Future<void> _checkActiveQueue() async {
    try {
      setState(() {
        _isCheckingActiveQueue = true;
      });
      
      // Fetch langsung dari Firestore
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (!mounted) return;
      setState(() {
        _hasActiveQueue = activeAntrian != null;
        _isCheckingActiveQueue = false;
      });
      print('[PasienPendaftaranView] Check active queue: active=${activeAntrian != null}, queueNumber=${activeAntrian?.queueNumber}');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasActiveQueue = false;
        _isCheckingActiveQueue = false;
      });
      print('[PasienPendaftaranView] Check error: $error');
    }
  }

  Future<void> _updateEstimatedTime() async {
    if (selectedPoli == null) {
      setState(() {
        _estimatedTime = null;
      });
      return;
    }

    setState(() {
      _isEstimatingTime = true;
    });

    try {
      // Hitung jumlah antrean aktif hari ini untuk poli yang dipilih
      final count = await _antrianService.getTodayQueueCountByPoli(selectedPoli!);

      // Asumsi 15 menit per pasien (sesuai teks di header)
      const minutesPerPatient = 15;
      final totalMinutes = (count + 1) * minutesPerPatient;

      final now = DateTime.now();
      final estimated = now.add(Duration(minutes: totalMinutes));

      setState(() {
        _estimatedTime = estimated;
      });
    } catch (_) {
      // Jika gagal, biarkan estimasi kosong
      setState(() {
        _estimatedTime = null;
      });
    } finally {
      setState(() {
        _isEstimatingTime = false;
      });
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _antrianStreamSubscription?.cancel(); // ✅ Cancel stream listener
    _keluhanFocusNode.dispose();
    _poliFocusNode.dispose();
    _scrollController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Pendaftaran Pasien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: _isCheckingActiveQueue
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF02B1BA)),
                ),
              )
            : _hasActiveQueue
                ? _buildActiveQueueWarning()
                : Form(
          key: _formKey,
          child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF02B1BA), Color(0xFF4DD4DB)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('6', 'Antrean'),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
                    _buildStatItem('15', 'Menit/Pasien'),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
                    _buildStatItem('1', 'Jam Tunggu'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Detail Pendaftaran
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Pendaftaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.pasienKelolaDataDiri);
                          },
                          child: Row(
                            children: [
                              const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF02B1BA),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color(0xFF02B1BA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Nama:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.namaLengkap ?? '-')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('NIK:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.nik ?? '-')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Tanggal Lahir:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.tanggalLahir ?? '-')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Jenis Kelamin:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('No. HP:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.noHp ?? '-')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Alamat:', _isLoadingProfile ? 'Memuat...' : (_userProfile?.alamat ?? '-')),
                    if (selectedPoli != null) ...[
                      const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                      _buildDetailRow('Poli Tujuan:', selectedPoli!),
                      const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                      _buildDetailRow('Dokter:', _getDokterByPoli()),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ⚠️ WARNING BANNER - Jika ada antrian aktif
              if (_hasActiveQueue)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4242).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF4242),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.block,
                        color: Color(0xFFFF4242),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'TIDAK BISA DAFTAR!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF4242),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Anda masih memiliki antrian aktif. Selesaikan atau batalkan antrian sebelumnya terlebih dahulu.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1E293B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Poli Tujuan
              // Disable form jika ada antrian aktif
              IgnorePointer(
                ignoring: _hasActiveQueue,
                child: Opacity(
                  opacity: _hasActiveQueue ? 0.5 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              _buildLabel('Poli Tujuan'),
              const SizedBox(height: 8),
              Focus(
                focusNode: _poliFocusNode,
                child: Container(
                  key: _poliKey,
                  child: GestureDetector(
                  onTap: () {
                    _poliFocusNode.requestFocus();
                    setState(() {
                      showPoliOptions = !showPoliOptions;
                      poliError = null;
                    });
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: poliError != null ? Colors.red : const Color(0xFF02B1BA),
                        width: _isPoliFocused ? 2.5 : 2,
                      ),
                      boxShadow: _isPoliFocused
                          ? [
                              BoxShadow(
                                color: const Color(0xFF02B1BA).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedPoli ?? 'Silahkan pilih Poli tujuan Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedPoli == null ? Colors.grey : const Color(0xFF1E293B),
                            fontWeight: selectedPoli == null ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        showPoliOptions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: const Color(0xFF02B1BA),
                      ),
                    ],
                  ),
                ),
                ),
              ),
              ),
              if (poliError != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    poliError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              if (showPoliOptions) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPoli = 'Poli Umum';
                      showPoliOptions = false;
                      poliError = null;
                    });
                    _updateEstimatedTime();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Poli Umum',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPoli = 'Poli Gigi';
                      showPoliOptions = false;
                      poliError = null;
                    });
                    _updateEstimatedTime();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Poli Gigi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPoli = 'Poli KIA';
                      showPoliOptions = false;
                      poliError = null;
                    });
                    _updateEstimatedTime();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Poli KIA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Keluhan
              _buildLabel('Keluhan'),
              const SizedBox(height: 8),
              Container(
                key: _keluhanKey,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: keluhanError != null 
                        ? Colors.red 
                        : (_isKeluhanFocused ? const Color(0xFF02B1BA) : const Color(0xFF02B1BA)),
                    width: _isKeluhanFocused ? 2.5 : 2,
                  ),
                  boxShadow: _isKeluhanFocused
                      ? [
                          BoxShadow(
                            color: const Color(0xFF02B1BA).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : [],
                  ),
                  child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.description_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _keluhanController,
                        focusNode: _keluhanFocusNode,
                        maxLines: 1,
                        onChanged: (value) {
                          if (keluhanError != null && value.isNotEmpty) {
                            setState(() {
                              keluhanError = null;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Isi keluhan Anda',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (keluhanError != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    keluhanError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Pembayaran
              _buildLabel('Jenis Pembayaran'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) {
                        setState(() {
                          isHoverBPJS = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHoverBPJS = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPembayaran = 'BPJS';
                            pembayaranError = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedPembayaran == 'BPJS'
                                ? const Color(0xFF02B1BA)
                                : (isHoverBPJS ? const Color(0xFFE0F7F8) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: pembayaranError != null 
                                  ? Colors.red 
                                  : const Color(0xFF02B1BA),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'BPJS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedPembayaran == 'BPJS'
                                    ? Colors.white
                                    : const Color(0xFF02B1BA),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) {
                        setState(() {
                          isHoverUmum = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHoverUmum = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPembayaran = 'Umum';
                            pembayaranError = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedPembayaran == 'Umum'
                                ? const Color(0xFF02B1BA)
                                : (isHoverUmum ? const Color(0xFFE0F7F8) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: pembayaranError != null 
                                  ? Colors.red 
                                  : const Color(0xFF02B1BA),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Umum',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedPembayaran == 'Umum'
                                    ? Colors.white
                                    : const Color(0xFF02B1BA),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (pembayaranError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Text(
                    pembayaranError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Estimasi Waktu
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF84F3EE).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF02B1BA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimasi Waktu Kedatangan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '',
                          ),
                          Builder(
                            builder: (_) {
                              if (_isEstimatingTime) {
                                return const SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4242)),
                                  ),
                                );
                              }

                              final displayText = _estimatedTime != null
                                  ? DateFormat('HH:mm').format(_estimatedTime!)
                                  : '--:--';

                              return Text(
                                displayText,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF4242),
                                  height: 1,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Jika Anda mendaftar saat ini, perkiraan waktu pelayanan Anda adalah sekitar jam tersebut.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4242).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info,
                                  size: 14,
                                  color: Color(0xFFFF4242),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Waktu dapat berubah sesuai kondisi antrean',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFFF4242),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Button Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // DISABLE tombol jika loading ATAU ada antrian aktif
                  onPressed: (_isLoading || _hasActiveQueue) ? null : () async {
                    // Reset errors
                    setState(() {
                      poliError = null;
                      keluhanError = null;
                      pembayaranError = null;
                    });
                    
                    // ❌ BLOCK jika ada antrian aktif
                    if (_hasActiveQueue) {
                      SnackbarHelper.showError(
                        'TIDAK BISA DAFTAR! Anda masih memiliki antrian aktif!',
                      );
                      return;
                    }
                    
                    bool isValid = true;
                    
                    // Validasi Poli Tujuan
                    if (selectedPoli == null) {
                      setState(() {
                        poliError = 'Poli tujuan harus dipilih';
                      });
                      isValid = false;
                    }
                    
                    // Validasi Keluhan
                    if (_keluhanController.text.trim().isEmpty) {
                      setState(() {
                        keluhanError = 'Keluhan harus diisi';
                      });
                      isValid = false;
                    }
                    
                    // Validasi Jenis Pembayaran
                    if (selectedPembayaran == null) {
                      setState(() {
                        pembayaranError = 'Jenis pembayaran harus dipilih';
                      });
                      isValid = false;
                    }
                    
                    if (!isValid) {
                      return;
                    }
                    
                    // ✅ DOUBLE CHECK: Validasi lagi sebelum submit
                    // Mencegah race condition jika user cepat klik submit
                    try {
                      final recheck = await _antrianService.getActiveAntrian();
                      if (recheck != null) {
                        // Ada antrian aktif!
                        setState(() {
                          _hasActiveQueue = true;
                          _isCheckingActiveQueue = false;
                        });
                        SnackbarHelper.showError('Anda sudah memiliki antrian aktif!');
                        return;
                      }
                    } catch (e) {
                      print('[PasienPendaftaranView] Recheck error: $e');
                    }
                    
                    // Set loading
                    setState(() {
                      _isLoading = true;
                    });
                    
                    try {
                      // Get Firestore services
                      final antrianService = AntrianFirestoreService();
                      final profileService = UserProfileFirestoreService();
                      
                      // Get user profile from Firestore
                      final userProfile = await profileService.getUserProfile();
                      
                      if (userProfile == null) {
                        throw Exception('Profile tidak ditemukan dan gagal dibuat otomatis. Silakan lengkapi profile Anda terlebih dahulu.');
                      }
                      
                      final namaLengkap = userProfile.namaLengkap;
                      final noRekamMedis = userProfile.noRekamMedis ?? 'RM-${DateTime.now().millisecondsSinceEpoch}';
                      
                      // Create antrian to Firestore
                      final antrian = await antrianService.createAntrian(
                        namaLengkap: namaLengkap,
                        noRekamMedis: noRekamMedis,
                        jenisLayanan: selectedPoli!,
                        keluhan: _keluhanController.text.trim(),
                        nomorBPJS: selectedPembayaran == 'BPJS' ? '1234567890' : null,
                      );
                      
                      final queueNumber = antrian.queueNumber;
                      
                      setState(() {
                        _isLoading = false;
                      });
                      
                      // Refresh dashboard controller untuk update status antrian
                      try {
                        final dashboardController = Get.find<PasienDashboardController>();
                        await dashboardController.checkActiveQueue();
                      } catch (e) {
                        print('[PasienPendaftaranView] Dashboard update error: $e');
                      }
                      
                      // Kembali ke dashboard
                      Get.back(result: true);
                      
                      // Tampilkan notif setelah kembali
                      await Future.delayed(const Duration(milliseconds: 200));
                      SnackbarHelper.showSuccess('Pendaftaran berhasil! Nomor antrean: $queueNumber');
                      
                      // Navigate langsung ke Status Antrian
                      await Future.delayed(const Duration(milliseconds: 500));
                      Get.toNamed(Routes.pasienStatusAntrean);
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                      });
                      SnackbarHelper.showError('Gagal mendaftar: ${e.toString()}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasActiveQueue 
                        ? Colors.grey  // Warna abu jika ada antrian aktif
                        : const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _hasActiveQueue 
                              ? 'TIDAK BISA DAFTAR - ANTRIAN AKTIF ADA'
                              : 'DAFTAR & AMBIL NOMOR ANTREAN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildActiveQueueWarning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFFFFB547),
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 4,
            borderRadius: 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84F3EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'ANTREAN AKTIF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02B1BA),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5CC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    size: 64,
                    color: Color(0xFFFF4242),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Maaf, Anda tidak dapat menambahkan\nantrean baru karena masih memiliki\nantrean yang aktif.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => const StatusAntreanView());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB547),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF02B1BA),
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length && draw) {
          dest.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
        } else if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
