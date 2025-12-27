import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/lokasi_puskesmas_controller.dart';

class LokasiPuskesmasView extends StatefulWidget {
  const LokasiPuskesmasView({Key? key}) : super(key: key);

  @override
  State<LokasiPuskesmasView> createState() => _LokasiPuskesmasViewState();
}

class _LokasiPuskesmasViewState extends State<LokasiPuskesmasView> {
  late final LokasiPuskesmasController controller;

  @override
  void initState() {
    super.initState();
    controller = LokasiPuskesmasController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Lokasi Puskesmas',
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
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: controller.openInGoogleMaps,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-7.913862, 112.585557),
                            initialZoom: 16.0,
                            maxZoom: 18.0,
                            minZoom: 10.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app_puskesmas_tugas_ri',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: controller.puskesmasLocation,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF02B1BA),
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 16,
                                  color: Color(0xFF02B1BA),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tap untuk buka Maps',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF02B1BA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Alamat Lengkap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02B1BA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF02B1BA),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Puskesmas Dau',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Jl. Raya Sengkaling No.212, Sengkaling, Mulyoagung, Kec. Dau, Kabupaten Malang, Jawa Timur 65151',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Kontak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildContactRow(Icons.phone, 'Telepon', controller.telepon, onTap: controller.openPhone),
                    _buildContactRow(Icons.email, 'Email', controller.email, onTap: controller.openEmail),
                    _buildContactRow(Icons.language, 'Website', controller.website, onTap: controller.openWebsite, isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Jam Operasional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildHoursRow('Senin - Kamis', '07:30 - 12:00 WIB'),
                    _buildHoursRow('Jumat', '07:30 - 10:00 WIB'),
                    _buildHoursRow('Sabtu', '07:30 - 11:00 WIB'),
                    _buildHoursRow('Minggu & Libur', 'Tutup', isLast: true, isClosed: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, {bool isLast = false, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF02B1BA)),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const Text(
                ': ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: onTap != null ? const Color(0xFF02B1BA) : const Color(0xFF64748B),
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: const Color(0xFF02B1BA),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoursRow(String day, String hours, {bool isLast = false, bool isClosed = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isClosed ? const Color(0xFFFF4242) : const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}
