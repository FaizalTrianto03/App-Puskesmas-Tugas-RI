import 'package:flutter/material.dart';

import '../../../../widgets/quarter_circle_background.dart';
import 'detail_riwayat_view.dart';

class RiwayatKunjunganView extends StatefulWidget {
  const RiwayatKunjunganView({Key? key}) : super(key: key);

  @override
  State<RiwayatKunjunganView> createState() => _RiwayatKunjunganViewState();
}

class _RiwayatKunjunganViewState extends State<RiwayatKunjunganView> {
  String selectedBulan = 'Semua';
  String selectedPoli = 'Semua';

  final List<String> bulanOptions = [
    'Semua',
    'Desember 2025',
    'November 2025',
    'Oktober 2025',
    'September 2025',
    'Agustus 2025',
  ];

  final List<String> poliOptions = [
    'Semua',
    'Poli Umum',
    'Poli Gigi',
    'Poli KIA',
  ];

  final List<Map<String, dynamic>> allRiwayatList = [
    {
      'poli': 'Poli Umum',
      'tanggal': '15 Desember 2025, 09:15 WIB',
      'noAntrean': 'A-012',
      'dokter': 'dr. Faizal Qadri',
      'diagnosis': 'Hipertensi Grade 1',
      'keluhan': 'Pasien mengeluhkan sakit kepala berulang sejak 1 minggu terakhir, terutama di pagi hari. Tekanan darah terukur 145/95 mmHg.',
      'tindakan': 'Pemberian obat antihipertensi (Amlodipine 5mg), edukasi diet rendah garam, dan olahraga teratur. Kontrol tekanan darah secara rutin.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '22 Desember 2025',
    },
    {
      'poli': 'Poli KIA',
      'tanggal': '12 Desember 2025, 10:30 WIB',
      'noAntrean': 'K-008',
      'dokter': 'dr. Siti Nurhaliza',
      'diagnosis': 'Kehamilan Normal (28 minggu)',
      'keluhan': 'Pasien datang untuk pemeriksaan rutin kehamilan trimester ketiga. Tidak ada keluhan khusus.',
      'tindakan': 'Pemeriksaan USG, pengukuran tekanan darah, berat badan, dan tinggi fundus. Pemberian vitamin ibu hamil dan edukasi persiapan persalinan.',
      'resep': '2 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '19 Desember 2025',
    },
    {
      'poli': 'Poli Gigi',
      'tanggal': '8 Desember 2025, 14:00 WIB',
      'noAntrean': 'G-015',
      'dokter': 'drg. Nisa Ayu',
      'diagnosis': 'Periodontitis Kronis',
      'keluhan': 'Gusi sering berdarah saat sikat gigi, gigi terasa goyang, dan bau mulut tidak sedap sejak 2 bulan terakhir.',
      'tindakan': 'Scaling dan root planing, pemberian antibiotik dan obat kumur. Edukasi perawatan gigi dan gusi yang benar.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '15 Desember 2025',
    },
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
      'poli': 'Poli KIA',
      'tanggal': '18 November 2025, 11:00 WIB',
      'noAntrean': 'K-005',
      'dokter': 'dr. Siti Nurhaliza',
      'diagnosis': 'Imunisasi Bayi (DPT-HB-Hib 3)',
      'keluhan': 'Pasien bayi usia 4 bulan datang untuk imunisasi rutin sesuai jadwal.',
      'tindakan': 'Pemberian vaksin DPT-HB-Hib dosis ke-3. Pemeriksaan tumbuh kembang bayi normal. Edukasi ASI eksklusif dan MPASI.',
      'resep': '',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '18 Desember 2025',
    },
    {
      'poli': 'Poli Umum',
      'tanggal': '10 November 2025, 08:30 WIB',
      'noAntrean': 'A-003',
      'dokter': 'dr. Faizal Qadri',
      'diagnosis': 'Diabetes Mellitus Tipe 2',
      'keluhan': 'Pasien mengeluhkan sering haus, sering buang air kecil, dan mudah lelah sejak 2 minggu terakhir. Gula darah sewaktu 245 mg/dL.',
      'tindakan': 'Pemberian obat antidiabetes (Metformin 500mg), edukasi diet diabetes, dan olahraga teratur. Monitoring gula darah rutin.',
      'resep': '4 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '17 November 2025',
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
      'poli': 'Poli KIA',
      'tanggal': '28 Oktober 2025, 13:15 WIB',
      'noAntrean': 'K-011',
      'dokter': 'dr. Siti Nurhaliza',
      'diagnosis': 'Anemia pada Ibu Hamil',
      'keluhan': 'Ibu hamil usia kehamilan 24 minggu mengeluh mudah lelah, pusing, dan pucat. Hemoglobin 9.5 g/dL.',
      'tindakan': 'Pemberian tablet besi (Fe sulfat), asam folat, dan vitamin B kompleks. Edukasi pola makan tinggi zat besi.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '4 November 2025',
    },
    {
      'poli': 'Poli Gigi',
      'tanggal': '22 Oktober 2025, 09:00 WIB',
      'noAntrean': 'G-006',
      'dokter': 'drg. Nisa Ayu',
      'diagnosis': 'Abses Gigi',
      'keluhan': 'Bengkak pada gusi dan pipi kanan bawah disertai nyeri berdenyut sejak 3 hari yang lalu. Demam ringan.',
      'tindakan': 'Insisi dan drainase abses, pemberian antibiotik dan analgesik. Rujukan untuk perawatan saluran akar setelah infeksi mereda.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '29 Oktober 2025',
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
    {
      'poli': 'Poli KIA',
      'tanggal': '25 Agustus 2025, 10:45 WIB',
      'noAntrean': 'K-007',
      'dokter': 'dr. Siti Nurhaliza',
      'diagnosis': 'Infeksi Saluran Pernapasan Akut (ISPA) pada Balita',
      'keluhan': 'Anak usia 3 tahun batuk berdahak, pilek, dan demam sejak 2 hari yang lalu. Nafsu makan menurun.',
      'tindakan': 'Pemberian obat batuk, antipiretik, dan vitamin. Edukasi perawatan di rumah dan pemberian ASI/cairan cukup.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': null,
    },
    {
      'poli': 'Poli Umum',
      'tanggal': '18 Agustus 2025, 14:30 WIB',
      'noAntrean': 'A-015',
      'dokter': 'dr. Faizal Qadri',
      'diagnosis': 'Asam Urat (Gout)',
      'keluhan': 'Nyeri dan bengkak pada ibu jari kaki kanan sejak semalam. Riwayat sering konsumsi makanan tinggi purin.',
      'tindakan': 'Pemberian obat anti-inflamasi (NSAID) dan penurun asam urat. Edukasi diet rendah purin dan perbanyak minum air putih.',
      'resep': '3 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': '25 Agustus 2025',
    },
    {
      'poli': 'Poli Gigi',
      'tanggal': '10 Agustus 2025, 11:15 WIB',
      'noAntrean': 'G-009',
      'dokter': 'drg. Nisa Ayu',
      'diagnosis': 'Stomatitis Aphtosa (Sariawan)',
      'keluhan': 'Sariawan multiple di lidah dan bibir bagian dalam, nyeri saat makan dan berbicara sejak 3 hari yang lalu.',
      'tindakan': 'Pemberian obat kumur antiseptik, gel topikal, dan vitamin B kompleks. Edukasi kebersihan mulut dan hindari makanan asam/pedas.',
      'resep': '2 item',
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'kontrolDate': null,
    },
  ];

  List<Map<String, dynamic>> get filteredRiwayatList {
    return allRiwayatList.where((data) {
      bool matchesBulan = selectedBulan == 'Semua' ||
          data['tanggal'].toString().contains(selectedBulan.split(' ')[0]);
      bool matchesPoli = selectedPoli == 'Semua' ||
          data['poli'] == selectedPoli;
      return matchesBulan && matchesPoli;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final riwayatList = filteredRiwayatList;
    
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
                'Filter Bulan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: bulanOptions.map((bulan) {
                    final isSelected = selectedBulan == bulan;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(bulan),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedBulan = bulan;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF02B1BA).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Filter Poli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: poliOptions.map((poli) {
                    final isSelected = selectedPoli == poli;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(poli),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedPoli = poli;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF02B1BA).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.assignment,
                      label: 'Total Kunjungan',
                      value: '${riwayatList.length}',
                      color: const Color(0xFF02B1BA),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildSummaryItem(
                      icon: Icons.calendar_month,
                      label: 'Periode',
                      value: selectedBulan == 'Semua' ? '6 Bulan' : '1 Bulan',
                      color: const Color(0xFF4CAF50),
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

              if (riwayatList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada data kunjungan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
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
