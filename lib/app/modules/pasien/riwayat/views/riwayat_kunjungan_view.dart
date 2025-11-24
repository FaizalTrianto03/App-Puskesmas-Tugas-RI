import 'package:flutter/material.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../../detail_riwayat/views/detail_riwayat_view.dart';

class RiwayatKunjunganView extends StatelessWidget {
  const RiwayatKunjunganView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> riwayatList = [
      {
        'poli': 'Poli Gigi',
        'tanggal': '20 November 2025, 13:45 WIB',
        'noAntrean': 'G-008',
        'dokter': 'drg. Nisa Ayu',
        'diagnosis': 'Pulpitis (Peradangan Pulpa Gigi)',
        'keluhan': 'Nyeri hebat pada gigi geraham kiri bawah, terutama saat makan dan di malam hari. Keluhan dirasakan sejak 4 hari yang lalu.',
        'tindakan': 'Perawatan saluran akar (root canal treatment), pemberian obat pereda nyeri dan antibiotik. Penambalan sementara.',
        'resep': '3 item',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'kontrolDate': '27 November 2025',
      },
      {
        'poli': 'Poli Umum',
        'tanggal': '5 Oktober 2025, 10:30 WIB',
        'noAntrean': 'A-005',
        'dokter': 'dr. Faizal Qadri',
        'diagnosis': 'Febris (Demam) akibat infeksi virus',
        'keluhan': 'Pasien mengeluhkan demam, sakit kepala, dan badan terasa lemas sejak dua hari lalu terakhir.',
        'tindakan': 'Pemberian obat antipiretik, vitamin. Istirahat cukup dan konsumsi cairan yang banyak.',
        'resep': '2 item',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'kontrolDate': null,
      },
      {
        'poli': 'Poli Gigi',
        'tanggal': '29 September 2025, 09:30 WIB',
        'noAntrean': 'G-003',
        'dokter': 'drg. Nisa Ayu',
        'diagnosis': 'Karies Dentis (Gigi Berlubang)',
        'keluhan': 'Nyeri pada gigi geraham kanan atas, terutama saat makan dan minum dingin.',
        'tindakan': 'Penambalan gigi geraham kanan atas. Pembersihan karang gigi. Edukasi cara menyikat gigi yang benar.',
        'resep': '',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'kontrolDate': '06 Oktober 2025',
      },
      {
        'poli': 'Poli Gigi',
        'tanggal': '15 September 2025, 14:00 WIB',
        'noAntrean': 'G-012',
        'dokter': 'drg. Nisa Ayu',
        'diagnosis': 'Gingivitis (Radang Gusi)',
        'keluhan': 'Gusi bengkak, berdarah saat menyikat gigi, dan terasa nyeri sejak 3 hari yang lalu.',
        'tindakan': 'Pembersihan karang gigi (scaling), pemberian obat kumur antiseptik, dan vitamin. Edukasi cara menyikat gigi yang benar.',
        'resep': '2 item',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'kontrolDate': '22 September 2025',
      },
      {
        'poli': 'Poli Umum',
        'tanggal': '2 September 2025, 08:15 WIB',
        'noAntrean': 'A-002',
        'dokter': 'dr. Faizal Qadri',
        'diagnosis': 'Gastritis (Maag Akut)',
        'keluhan': 'Nyeri ulu hati, mual, dan kembung setelah makan. Keluhan dirasakan sejak kemarin malam.',
        'tindakan': 'Pemberian obat antasida dan PPI (Proton Pump Inhibitor). Anjuran diet teratur dan hindari makanan pedas.',
        'resep': '2 item',
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'kontrolDate': '9 September 2025',
      },
    ];

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
                  color: const Color(0xFF02B1BA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Berikut adalah daftar riwayat kunjungan dan ringkasan pemeriksaan Anda di Puskesmas.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
              
              // List of riwayat
              ...riwayatList.map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRiwayatCard(context, data),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> data) {
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
                      data['poli'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['tanggal'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No: ${data['noAntrean']}',
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
                  color: (data['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: data['statusColor'] as Color,
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
              const Icon(Icons.person, size: 18, color: Color(0xFF02B1BA)),
              const SizedBox(width: 8),
              Text(
                data['dokter'],
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
            data['keluhan'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          
          if (data['resep'].isNotEmpty) ...[
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
                  data['resep'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          
          if (data['kontrolDate'] != null) ...[
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
                  data['kontrolDate'],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRiwayatView(data: data),
                    ),
                  );
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
