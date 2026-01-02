import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/confirmation_dialog.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/resep_obat_controller.dart';

class DetailResepView extends StatelessWidget {
  final Map<String, dynamic> resep;

  const DetailResepView({Key? key, required this.resep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResepObatController>();
    final bool isMenunggu = resep['status'] == 'Menunggu';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail Resep',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: QuarterCircleBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoPasien(),
                    const SizedBox(height: 16),
                    _buildDaftarObat(),
                    const SizedBox(height: 16),
                    if (resep['status'] == 'Selesai') _buildInfoPenyerahan(),
                    const SizedBox(height: 24),
                    if (isMenunggu) _buildActionButtons(controller),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPasien() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  resep['id'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02B1BA),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: resep['statusColor'],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  resep['status'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            resep['namaPasien'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.confirmation_number,
            'No. Antrean',
            resep['noAntrean'],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.local_hospital, 'Poli', resep['poli']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline, 'Dokter', resep['dokter']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'Tanggal', resep['tanggal']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDaftarObat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Obat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          resep['daftarObat'].length,
          (index) => _buildObatCard(resep['daftarObat'][index], index),
        ),
      ],
    );
  }

  Widget _buildObatCard(Map<String, dynamic> obat, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Color(0xFF02B1BA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obat['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jumlah: ${obat['jumlah']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aturan: ${obat['aturan']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Stok tersedia: ${obat['stok']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPenyerahan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Obat Telah Diserahkan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Tanggal penyerahan
          _buildInfoDetailRow(
            Icons.event,
            'Tanggal Penyerahan',
            _formatDateTime(resep['tanggalSerah']),
          ),
          // Apoteker yang menyerahkan
          if (resep['apotekerName'] != null) ...[
            const SizedBox(height: 8),
            _buildInfoDetailRow(
              Icons.person,
              'Diserahkan oleh',
              resep['apotekerName'],
            ),
          ],
          // Catatan penyerahan
          if (resep['catatanPenyerahan'] != null &&
              resep['catatanPenyerahan'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Catatan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    resep['catatanPenyerahan'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final day = dateTime.day.toString().padLeft(2, '0');
      final month = months[dateTime.month - 1];
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day $month $year, $hour:$minute WIB';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildActionButtons(ResepObatController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _KonfirmasiButton(
            onPressed: () => _showKonfirmasiDialog(controller),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _BatalButton(
            onPressed: () {
              ConfirmationDialog.show(
                title: 'Batalkan Resep',
                message: 'Apakah Anda yakin ingin membatalkan resep ini?',
                confirmText: 'Ya, Batalkan',
                cancelText: 'Tidak',
                onConfirm: () {
                  controller.batalkanResep(resep['id']);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Dialog konfirmasi penyerahan obat yang lebih detail
  void _showKonfirmasiDialog(ResepObatController controller) async {
    // Reset catatan controller
    controller.catatanController.clear();

    final confirm = await ConfirmationDialog.show(
      title: 'Konfirmasi Penyerahan Obat',
      message:
          'Pastikan Anda telah menyerahkan semua obat dalam resep ${resep['id']} kepada ${resep['namaPasien']}.\n\nObat yang diserahkan:',
      type: ConfirmationType.confirmation,
      confirmText: 'Ya, Serahkan',
      cancelText: 'Batal',
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Daftar obat yang akan diserahkan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF02B1BA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF02B1BA).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(resep['daftarObat'].length, (index) {
                  final obat = resep['daftarObat'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medication,
                          size: 16,
                          color: Color(0xFF02B1BA),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${obat['nama']} (${obat['jumlah']})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Field untuk catatan (opsional)
          const Text(
            'Catatan (Opsional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.catatanController,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Pasien sudah diberi edukasi tentang aturan minum obat',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF02B1BA),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.konfirmasiPenyerahan(resep['id'], resep['namaPasien']);
    }
  }
}

class _KonfirmasiButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _KonfirmasiButton({required this.onPressed});

  @override
  State<_KonfirmasiButton> createState() => _KonfirmasiButtonState();
}

class _KonfirmasiButtonState extends State<_KonfirmasiButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF4CAF50,
                  ).withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Konfirmasi Penyerahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BatalButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _BatalButton({required this.onPressed});

  @override
  State<_BatalButton> createState() => _BatalButtonState();
}

class _BatalButtonState extends State<_BatalButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _isHovered ? Colors.red.shade50 : Colors.white,
          side: BorderSide(
            color: const Color(0xFFFF4242),
            width: _isHovered ? 2 : 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Color(0xFFFF4242), size: 24),
            SizedBox(width: 8),
            Text(
              'Batalkan Resep',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4242),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
