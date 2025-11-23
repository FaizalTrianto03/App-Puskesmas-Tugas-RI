import 'package:flutter/material.dart';

class JadwalPraktekView extends StatelessWidget {
  const JadwalPraktekView({Key? key}) : super(key: key);

  // Data dummy jadwal praktek mingguan
  static final List<Map<String, dynamic>> dummyJadwal = [
    {
      'hari': 'Senin',
      'tanggal': '25 November 2025',
      'jamMulai': '08:00',
      'jamSelesai': '14:00',
      'poli': 'Poli Umum',
      'status': 'Aktif',
      'statusColor': const Color(0xFF4CAF50),
      'jumlahPasien': 12,
    },
    {
      'hari': 'Selasa',
      'tanggal': '26 November 2025',
      'jamMulai': '08:00',
      'jamSelesai': '14:00',
      'poli': 'Poli Umum',
      'status': 'Aktif',
      'statusColor': const Color(0xFF4CAF50),
      'jumlahPasien': 10,
    },
    {
      'hari': 'Rabu',
      'tanggal': '27 November 2025',
      'jamMulai': '08:00',
      'jamSelesai': '12:00',
      'poli': 'Poli Umum',
      'status': 'Aktif',
      'statusColor': const Color(0xFF4CAF50),
      'jumlahPasien': 8,
    },
    {
      'hari': 'Kamis',
      'tanggal': '28 November 2025',
      'jamMulai': '13:00',
      'jamSelesai': '17:00',
      'poli': 'Poli Umum',
      'status': 'Libur',
      'statusColor': const Color(0xFFFF4242),
      'jumlahPasien': 0,
    },
    {
      'hari': 'Jumat',
      'tanggal': '29 November 2025',
      'jamMulai': '08:00',
      'jamSelesai': '11:00',
      'poli': 'Poli Umum',
      'status': 'Aktif',
      'statusColor': const Color(0xFF4CAF50),
      'jumlahPasien': 6,
    },
    {
      'hari': 'Sabtu',
      'tanggal': '30 November 2025',
      'jamMulai': '08:00',
      'jamSelesai': '13:00',
      'poli': 'Poli Umum',
      'status': 'Aktif',
      'statusColor': const Color(0xFF4CAF50),
      'jumlahPasien': 9,
    },
    {
      'hari': 'Minggu',
      'tanggal': '1 Desember 2025',
      'jamMulai': '-',
      'jamSelesai': '-',
      'poli': 'Poli Umum',
      'status': 'Libur',
      'statusColor': const Color(0xFFFF4242),
      'jumlahPasien': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jadwal Praktek',
          style: TextStyle(
            color: Color(0xFF02B1BA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Jadwal Mingguan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02B1BA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dummyJadwal.map((jadwal) => _buildJadwalCard(jadwal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF02B1BA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dr. Faizal Qadri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dokter Poli Umum',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      '5 Hari Praktek / Minggu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
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

  Widget _buildJadwalCard(Map<String, dynamic> jadwal) {
    final isLibur = jadwal['status'] == 'Libur';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLibur 
              ? const Color(0xFFFF4242).withOpacity(0.3) 
              : const Color(0xFF02B1BA).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLibur 
                          ? const Color(0xFFFF4242).withOpacity(0.1)
                          : const Color(0xFF02B1BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isLibur ? Icons.event_busy : Icons.event_available,
                      color: isLibur 
                          ? const Color(0xFFFF4242)
                          : const Color(0xFF02B1BA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal['hari'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jadwal['tanggal'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: jadwal['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: jadwal['statusColor'],
                    width: 1.5,
                  ),
                ),
                child: Text(
                  jadwal['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: jadwal['statusColor'],
                  ),
                ),
              ),
            ],
          ),
          if (!isLibur) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.access_time,
                    label: 'Jam Praktek',
                    value: '${jadwal['jamMulai']} - ${jadwal['jamSelesai']}',
                    color: const Color(0xFF02B1BA),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.people,
                    label: 'Pasien',
                    value: '${jadwal['jumlahPasien']} Orang',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.local_hospital,
              label: 'Lokasi',
              value: jadwal['poli'],
              color: const Color(0xFFFF9800),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF4242),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tidak ada jadwal praktek',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
