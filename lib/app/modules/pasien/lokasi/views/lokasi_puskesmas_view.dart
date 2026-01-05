import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';



import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/lokasi_puskesmas_controller.dart';

class LokasiPuskesmasView extends GetView<LokasiPuskesmasController> {
  const LokasiPuskesmasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller di-initialize
    final controller = Get.put(LokasiPuskesmasController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Informasi Puskesmas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF02B1BA),
            ),
          );
        }

        return QuarterCircleBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Section
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: controller.puskesmasLocation == null
                        ? Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 64,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Lokasi belum diatur oleh admin',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: controller.openInGoogleMaps,
                            child: Stack(
                              children: [
                                FlutterMap(
                                  options: MapOptions(
                                    initialCenter: controller.puskesmasLocation!,
                                    initialZoom: 16.0,
                                    maxZoom: 18.0,
                                    minZoom: 10.0,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.app_puskesmas_tugas_ri',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: controller.puskesmasLocation!,
                                          width: 40,
                                          height: 40,
                                          alignment: Alignment.topCenter,
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          controller.locationPermissionGranted.value
                                              ? Icons.directions
                                              : Icons.touch_app,
                                          size: 16,
                                          color: const Color(0xFF02B1BA),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          controller.locationPermissionGranted.value
                                              ? 'Tap untuk arah'
                                              : 'Tap untuk buka Maps',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF02B1BA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Distance Badge
                                if (controller.distanceInKm.value != null)
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF02B1BA),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.near_me,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${controller.distanceInKm.value!.toStringAsFixed(2)} km',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.namaPuskesmas ?? 'Belum diatur',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: controller.namaPuskesmas == null 
                                      ? const Color(0xFF94A3B8) 
                                      : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.alamatLengkap ?? 'Alamat belum diatur oleh admin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.alamatLengkap == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
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
                      _buildContactRow(Icons.phone, 'Telepon', controller.telepon ?? 'Belum diatur', onTap: controller.telepon != null ? controller.openPhone : null),
                      _buildContactRow(Icons.email, 'Email', controller.email ?? 'Belum diatur', onTap: controller.email != null ? controller.openEmail : null),
                      _buildContactRow(Icons.language, 'Website', controller.website ?? 'Belum diatur', onTap: controller.website != null ? controller.openWebsite : null, isLast: true),
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
                    children: _buildOperationalHours(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildOperationalHours() {
    if (controller.jamOperasionalList.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Jam operasional belum diatur oleh admin',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }
    
    return List.generate(controller.jamOperasionalList.length, (index) {
      final jam = controller.jamOperasionalList[index];
      final isLast = index == controller.jamOperasionalList.length - 1;
      
      return _buildHoursRow(
        jam.hari,
        jam.jamDisplay,
        isLast: isLast,
        isClosed: !jam.isBuka, // Gunakan status dari model
      );
    });
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
