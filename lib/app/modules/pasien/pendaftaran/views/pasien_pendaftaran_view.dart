import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pasien_pendaftaran_controller.dart';
import '../../../../widgets/quarter_circle_background.dart';

class PasienPendaftaranView extends GetView<PasienPendaftaranController> {
  const PasienPendaftaranView({Key? key}) : super(key: key);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsRow(),
              const SizedBox(height: 24),
              _buildDetailPendaftaran(context),
              const SizedBox(height: 24),
              _buildPoliTujuan(context),
              const SizedBox(height: 16),
              _buildKeluhan(),
              const SizedBox(height: 16),
              _buildJenisPembayaran(),
              const SizedBox(height: 24),
              _buildEstimasiWaktu(),
              const SizedBox(height: 24),
              _buildDaftarButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        _buildStatCard('6', 'Antrean', const Color(0xFF02B1BA)),
        const SizedBox(width: 12),
        _buildStatCard('15', 'Menit/Pasien', const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        _buildStatCard('1', 'Jam Tunggu', const Color(0xFFFF4242)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPendaftaran(BuildContext context) {
    return Container(
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
              TextButton.icon(
                onPressed: () {
                  // Navigate to edit profile
                },
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Color(0xFF02B1BA),
                ),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF02B1BA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Nama:', 'Anisa Ayu'),
          _buildDetailRow('NIK:', '20221037031009'),
          _buildDetailRow('Poli:', 'Poli Umum'),
          _buildDetailRow('Dokter:', 'dr. Faizal Qadri'),
          _buildDetailRow('Tanggal:', '10 Oktober 2025'),
          _buildDetailRow('Waktu Daftar:', '08:30 WIB', isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
  }

  Widget _buildPoliTujuan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Poli Tujuan'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showPoliPicker(context);
          },
          child: AbsorbPointer(
            child: _buildTextField(
              controller: controller.poliController,
              hintText: 'Silahkan pilih Poli tujuan Anda',
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeluhan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Keluhan'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.keluhanController,
          hintText: 'Isi keluhan Anda',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildJenisPembayaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Keluhan'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildPaymentButton(
                'BPJS',
                controller.selectedJenisBPJS.value == 'BPJS',
                () => controller.setJenisBPJS('BPJS'),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildPaymentButton(
                'Umum',
                controller.selectedJenisBPJS.value == 'Umum',
                () => controller.setJenisBPJS('Umum'),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstimasiWaktu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF02B1BA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF02B1BA),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi Waktu Kedatangan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '10:15',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4242),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jika Anda mendaftar saat ini, perkiraan waktu pelayanan Anda adalah sekitar jam tersebut.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFFFF4242),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Waktu dapat berubah sesuai kondisi antrean',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.daftarAntrean,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF02B1BA),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF02B1BA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showPoliPicker(BuildContext context) {
    final poliList = [
      'Poli Umum',
      'Poli Gigi',
      'Poli KIA',
      'Poli Lansia',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Poli',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...poliList.map((poli) => ListTile(
              title: Text(poli),
              onTap: () {
                controller.setSelectedPoli(poli);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}
