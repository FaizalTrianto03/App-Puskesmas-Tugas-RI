import 'package:flutter/material.dart';

import '../../../../utils/snackbar_helper.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/kelola_data_diri_view.dart';
import '../../status_antrean/views/status_antrean_view.dart';

class PasienPendaftaranView extends StatefulWidget {
  final bool hasActiveQueue;
  const PasienPendaftaranView({Key? key, this.hasActiveQueue = false}) : super(key: key);

  @override
  State<PasienPendaftaranView> createState() => _PasienPendaftaranViewState();
}

class _PasienPendaftaranViewState extends State<PasienPendaftaranView> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPoli;
  final TextEditingController _keluhanController = TextEditingController();
  String selectedPembayaran = 'BPJS';
  bool showPoliOptions = false;
  String? poliError;
  String? keluhanError;

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
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
        child: widget.hasActiveQueue
            ? _buildActiveQueueWarning()
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KelolaDataDiriView(),
                              ),
                            );
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
                    _buildDetailRow('Nama:', 'Anisa Ayu'),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('NIK:', '20221037031009'),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Tanggal Lahir:', '09/09/2003'),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Jenis Kelamin:', 'Perempuan'),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('No. HP:', '081234567899'),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Alamat:', 'Jln. Tirto Mulyo, Dau, Malang'),
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
              
              // Poli Tujuan
              _buildLabel('Poli Tujuan'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
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
                      width: 2,
                    ),
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
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: keluhanError != null ? Colors.red : const Color(0xFF02B1BA),
                    width: 2,
                  ),
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPembayaran = 'BPJS';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedPembayaran == 'BPJS'
                              ? const Color(0xFF02B1BA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF02B1BA), width: 2),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPembayaran = 'Umum';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedPembayaran == 'Umum'
                              ? const Color(0xFF02B1BA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF02B1BA), width: 2),
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
                ],
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
                            '10:15',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF4242),
                              height: 1,
                            ),
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
              
              // Button Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
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
                    
                    if (!isValid) {
                      return;
                    }
                    
                    SnackbarHelper.showSuccess('Pendaftaran berhasil! Nomor antrean Anda telah dibuat.');
                    
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'DAFTAR & AMBIL NOMOR ANTREAN',
                    style: TextStyle(
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
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatusAntreanView(hasActiveQueue: true),
                        ),
                      );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
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
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
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
