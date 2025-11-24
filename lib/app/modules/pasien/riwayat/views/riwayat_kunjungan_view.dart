import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_kunjungan_controller.dart';
import '../../../../widgets/quarter_circle_background.dart';

class RiwayatKunjunganView extends GetView<RiwayatKunjunganController> {
  const RiwayatKunjunganView({Key? key}) : super(key: key);

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
          'Riwayat Kunjungan',
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
              Container(
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
                        Icons.info_outline,
                        color: Color(0xFF02B1BA),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Berikut adalah daftar riwayat kunjungan dan ringkasan pemeriksaan Anda di Puskesmas.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Daftar Kunjungan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 12),
              
              _buildRiwayatCard(
                poli: 'Poli Umum',
                tanggal: '5 Oktober 2025, 10:30 WIB',
                noAntrean: 'A-005',
                dokter: 'dr. Faizal Qadri',
                diagnosis: 'Pemeriksaan kesehatan umum. Tekanan darah normal. Diberikan resep obat vitamin dan paracetamol. Rujuk ke laboratorium jika diperlukan pemeriksaan lanjutan.',
                resep: '2 item',
                status: 'Selesai',
                statusColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 12),
              
              _buildRiwayatCard(
                poli: 'Poli Gigi',
                tanggal: '29 September 2025, 09:30 WIB',
                noAntrean: 'G-003',
                dokter: 'drg. Andi Wijaya',
                diagnosis: 'Penambalan gigi geraham kanan atas. Pembersihan karang gigi. Edukasi cara menyikat gigi yang benar. Kontrol 2 minggu lagi.',
                resep: '',
                status: 'Selesai',
                statusColor: const Color(0xFF4CAF50),
                kontrolDate: '06 Okt 2024',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard({
    required String poli,
    required String tanggal,
    required String noAntrean,
    required String dokter,
    required String diagnosis,
    required String resep,
    required String status,
    required Color statusColor,
    String? kontrolDate,
  }) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
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
                      poli,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                dokter,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Ringkasan Pemeriksaan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            diagnosis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          
          if (resep.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Resep: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  resep,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          
          if (kontrolDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Kontrol: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  kontrolDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Show detail
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFF02B1BA),
                ),
                label: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: Color(0xFF02B1BA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
