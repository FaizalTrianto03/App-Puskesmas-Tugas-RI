import 'package:flutter/material.dart';

class TimelineItemWidget extends StatelessWidget {
  final Map<String, dynamic> riwayat;
  final bool isLast;
  final VoidCallback onTap;

  const TimelineItemWidget({
    Key? key,
    required this.riwayat,
    required this.isLast,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tanggal = riwayat['tanggal_pemeriksaan'] as DateTime;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            _buildTimelineIndicator(),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: _buildContent(tanggal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Column(
      children: [
        // Circle indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor().withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        // Timeline line
        if (!isLast)
          Container(
            width: 2,
            height: 80,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(top: 4),
          ),
      ],
    );
  }

  Widget _buildContent(DateTime tanggal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header: Nama Pasien & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riwayat['nama_pasien'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. RM: ${riwayat['no_rm']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tanggal & Waktu
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatTanggal(tanggal),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatWaktu(tanggal),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),
          
          // Keluhan
          _buildInfoRow(
            icon: Icons.sick,
            label: 'Keluhan',
            value: riwayat['keluhan'],
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          
          // Diagnosa
          _buildInfoRow(
            icon: Icons.assignment,
            label: 'Diagnosa',
            value: riwayat['diagnosa'],
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          
          // Vital Signs Summary
          _buildVitalSignsSummary(),
          
          const SizedBox(height: 12),
          
          // Perawat Info
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Perawat: ${riwayat['perawat_nama']}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Lihat Detail Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Detail'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF02B1BA),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF02B1BA)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalSignsSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildVitalItem(
            icon: Icons.favorite,
            label: 'TD',
            value: '${riwayat['tekanan_darah_sistolik']}/${riwayat['tekanan_darah_diastolik']}',
            unit: 'mmHg',
          ),
          _buildVitalDivider(),
          _buildVitalItem(
            icon: Icons.thermostat,
            label: 'Suhu',
            value: '${riwayat['suhu_tubuh']}',
            unit: '°C',
          ),
          _buildVitalDivider(),
          _buildVitalItem(
            icon: Icons.monitor_weight,
            label: 'BB',
            value: '${riwayat['berat_badan']}',
            unit: 'kg',
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF02B1BA)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Color _getStatusColor() {
    final status = riwayat['status'].toString().toLowerCase();
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'dalam_pemeriksaan':
        return Colors.orange;
      case 'menunggu':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    final status = riwayat['status'].toString().toLowerCase();
    switch (status) {
      case 'selesai':
        return Icons.check;
      case 'dalam_pemeriksaan':
        return Icons.medical_services;
      case 'menunggu':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    final status = riwayat['status'].toString().toLowerCase();
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'dalam_pemeriksaan':
        return 'Dalam Pemeriksaan';
      case 'menunggu':
        return 'Menunggu';
      default:
        return 'Unknown';
    }
  }

  String _formatTanggal(DateTime tanggal) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }

  String _formatWaktu(DateTime tanggal) {
    final hour = tanggal.hour.toString().padLeft(2, '0');
    final minute = tanggal.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
