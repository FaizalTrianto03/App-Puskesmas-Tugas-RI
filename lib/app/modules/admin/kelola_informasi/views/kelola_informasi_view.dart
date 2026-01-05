import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../../../data/models/jam_operasional_model.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/kelola_informasi_controller.dart';

class KelolaInformasiView extends GetView<KelolaInformasiController> {
  const KelolaInformasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          'Kelola Informasi Puskesmas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(
            () =>
                controller.isSaving.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: controller.savePuskesmasData,
                    ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
          );
        }

        return QuarterCircleBackground(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.loadPuskesmasData();
            },
            color: const Color(0xFF02B1BA),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Pilih Lokasi'),
                  const SizedBox(height: 8),
                  Text(
                    'Tap pada peta untuk memilih lokasi puskesmas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMapPicker(),
                  const SizedBox(height: 12),
                  _buildUseCurrentLocationButton(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Alamat Lengkap'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.alamatController,
                    label: 'Alamat Lengkap',
                    icon: Icons.location_on,
                    hint: 'Jl. Raya Sengkaling No.212...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Kontak'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.teleponController,
                    label: 'Telepon',
                    icon: Icons.phone,
                    hint: '(0341) 462123',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Email',
                    icon: Icons.email,
                    hint: 'email@puskesmas.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.websiteController,
                    label: 'Website',
                    icon: Icons.language,
                    hint: 'puskesmas.malangkab.go.id',
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Jam Operasional'),
                  const SizedBox(height: 12),
                  _buildJamOperasionalSection(),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isSaving.value
                                ? null
                                : controller.savePuskesmasData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02B1BA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            controller.isSaving.value
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Simpan Data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF02B1BA),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF02B1BA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF02B1BA)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMapPicker() {
    return Obx(() {
      final center = controller.mapCenter.value;
      final selected = controller.selectedLocation.value;

      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF02B1BA), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              center == null
                  ? Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Color(0xFF94A3B8)),
                          SizedBox(height: 8),
                          Text(
                            'Memuat peta...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Stack(
                    children: [
                      FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 16.0,
                          maxZoom: 18.0,
                          minZoom: 10.0,
                          onTap: (_, point) => controller.onMapTap(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.app_puskesmas_tugas_ri',
                          ),
                          MarkerLayer(
                            markers: [
                              if (selected != null)
                                Marker(
                                  point: selected,
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
                      // Zoom controls
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          children: [
                            // Center on marker button
                            if (controller.selectedLocation.value != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (controller.selectedLocation.value != null) {
                                        controller.mapController.move(
                                          controller.selectedLocation.value!,
                                          16.0,
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (controller.selectedLocation.value != null)
                              const SizedBox(height: 8),
                            // Zoom In
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final currentZoom =
                                        controller.mapController.camera.zoom;
                                    controller.mapController.move(
                                      controller.mapController.camera.center,
                                      currentZoom + 1,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFF02B1BA),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Zoom Out
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final currentZoom =
                                        controller.mapController.camera.zoom;
                                    controller.mapController.move(
                                      controller.mapController.camera.center,
                                      currentZoom - 1,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.remove,
                                      color: Color(0xFF02B1BA),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      );
    });
  }

  Widget _buildUseCurrentLocationButton() {
    return Obx(() {
      if (!controller.locationPermissionGranted.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izin lokasi diperlukan untuk menggunakan lokasi saat ini',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                ),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.useCurrentLocation,
          icon: const Icon(Icons.my_location),
          label: const Text('Gunakan Lokasi Saat Ini'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF02B1BA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildJamOperasionalSection() {
    return Obx(() {
      final jamList = controller.jamOperasionalList;

      if (jamList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(Icons.schedule, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Belum ada jam operasional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan jadwal operasional puskesmas',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAddJamDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Tambah Jam Operasional'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B1BA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          ...jamList
              .map(
                (jam) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          jam.isBuka
                              ? [
                                const Color(0xFF02B1BA),
                                const Color(0xFF00969E),
                              ]
                              : [
                                const Color(0xFFEF4444),
                                const Color(0xFFDC2626),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (jam.isBuka
                                ? const Color(0xFF02B1BA)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      jam.hari,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showEditJamDialog(jam),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Color(0xFF02B1BA),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap:
                                      () => controller.removeJamOperasional(
                                        jam.id!,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: Color(0xFFFF4242),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                jam.jamDisplay,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddJamDialog,
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'Tambah Jam Operasional',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF02B1BA),
                side: const BorderSide(color: Color(0xFF02B1BA), width: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showAddJamDialog() {
    String? hari;
    String jamBuka = '07:30';
    String jamTutup = '14:00';
    bool isTutup = false;

    // Filter hari yang sudah dipilih (hide dari dropdown)
    final allHariOptions = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final selectedHariSet =
        controller.jamOperasionalList.map((jam) => jam.hari).toSet();
    final hariOptions =
        allHariOptions.where((h) => !selectedHariSet.contains(h)).toList();

    // Check jika semua hari sudah dipilih
    if (hariOptions.isEmpty) {
      Get.snackbar(
        'Tidak Bisa Menambah',
        'Semua hari dalam seminggu sudah memiliki jadwal operasional.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                            Icons.schedule,
                            color: Color(0xFF02B1BA),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tambah Jam Operasional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF02B1BA),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Grid Layout 2x2
                    Row(
                      children: [
                        // Kiri Atas: Hari
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hari',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Text('Pilih'),
                                    value: hari,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF02B1BA),
                                    ),
                                    items:
                                        hariOptions.map((h) {
                                          return DropdownMenuItem(
                                            value: h,
                                            child: Text(h),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        hari = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kanan Atas: Switch Tutup
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      isTutup
                                          ? const Color(0xFFFEF2F2)
                                          : const Color(0xFFF0FDFA),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isTutup ? 'Tutup' : 'Buka',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isTutup
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF02B1BA),
                                      ),
                                    ),
                                    Switch(
                                      value: isTutup,
                                      onChanged: (value) {
                                        setState(() {
                                          isTutup = value;
                                        });
                                      },
                                      activeColor: const Color(0xFFEF4444),
                                      inactiveThumbColor: const Color(
                                        0xFF02B1BA,
                                      ),
                                      inactiveTrackColor: const Color(
                                        0xFF02B1BA,
                                      ).withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Kiri Bawah: Jam Buka
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Buka',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    isTutup
                                        ? null
                                        : () async {
                                          final parts = jamBuka.split(':');
                                          final initialHour =
                                              int.tryParse(parts[0]) ?? 7;
                                          final initialMinute =
                                              int.tryParse(parts[1]) ?? 30;

                                          final TimeOfDay?
                                          picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: initialHour,
                                              minute: initialMinute,
                                            ),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                        primary: Color(
                                                          0xFF02B1BA,
                                                        ),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (picked != null) {
                                            final hour = picked.hour
                                                .toString()
                                                .padLeft(2, '0');
                                            final minute = picked.minute
                                                .toString()
                                                .padLeft(2, '0');
                                            setState(() {
                                              jamBuka = '$hour:$minute';
                                            });
                                          }
                                        },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isTutup
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF02B1BA),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        isTutup
                                            ? const Color(0xFFF8FAFC)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color:
                                            isTutup
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF02B1BA),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTutup ? '--:--' : jamBuka,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isTutup
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kanan Bawah: Jam Tutup
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Tutup',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    isTutup
                                        ? null
                                        : () async {
                                          final parts = jamTutup.split(':');
                                          final initialHour =
                                              int.tryParse(parts[0]) ?? 14;
                                          final initialMinute =
                                              int.tryParse(parts[1]) ?? 0;

                                          final TimeOfDay?
                                          picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: initialHour,
                                              minute: initialMinute,
                                            ),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                        primary: Color(
                                                          0xFF02B1BA,
                                                        ),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (picked != null) {
                                            final hour = picked.hour
                                                .toString()
                                                .padLeft(2, '0');
                                            final minute = picked.minute
                                                .toString()
                                                .padLeft(2, '0');
                                            setState(() {
                                              jamTutup = '$hour:$minute';
                                            });
                                          }
                                        },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isTutup
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF02B1BA),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        isTutup
                                            ? const Color(0xFFF8FAFC)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color:
                                            isTutup
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF02B1BA),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTutup ? '--:--' : jamTutup,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isTutup
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (hari == null || hari!.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Harap pilih hari',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final jamOperasional = JamOperasionalModel(
                                hari: hari!,
                                jamBuka: isTutup ? '' : jamBuka,
                                jamTutup: isTutup ? '' : jamTutup,
                              );
                              controller.addJamOperasional(jamOperasional);
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02B1BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Tambah',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditJamDialog(JamOperasionalModel jam) {
    String? hari = jam.hari;
    String jamBuka = jam.jamBuka.isNotEmpty ? jam.jamBuka : '07:30';
    String jamTutup = jam.jamTutup.isNotEmpty ? jam.jamTutup : '14:00';
    bool isTutup = !jam.isBuka;

    // Filter hari yang sudah dipilih, tapi allow current hari (untuk edit)
    final allHariOptions = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final selectedHariSet =
        controller.jamOperasionalList
            .where((j) => j.id != jam.id) // Exclude current jam being edited
            .map((j) => j.hari)
            .toSet();
    final hariOptions =
        allHariOptions.where((h) => !selectedHariSet.contains(h)).toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                            Icons.edit,
                            color: Color(0xFF02B1BA),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit Jam Operasional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF02B1BA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Grid Layout 2x2
                    Row(
                      children: [
                        // Kiri Atas: Hari
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hari',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Text('Pilih'),
                                    value: hari,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF02B1BA),
                                    ),
                                    items:
                                        hariOptions.map((h) {
                                          return DropdownMenuItem(
                                            value: h,
                                            child: Text(h),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        hari = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kanan Atas: Switch Tutup
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      isTutup
                                          ? const Color(0xFFFEF2F2)
                                          : const Color(0xFFF0FDFA),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isTutup ? 'Tutup' : 'Buka',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isTutup
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF02B1BA),
                                      ),
                                    ),
                                    Switch(
                                      value: isTutup,
                                      onChanged: (value) {
                                        setState(() {
                                          isTutup = value;
                                        });
                                      },
                                      activeColor: const Color(0xFFEF4444),
                                      inactiveThumbColor: const Color(
                                        0xFF02B1BA,
                                      ),
                                      inactiveTrackColor: const Color(
                                        0xFF02B1BA,
                                      ).withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Kiri Bawah: Jam Buka
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Buka',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    isTutup
                                        ? null
                                        : () async {
                                          final parts = jamBuka.split(':');
                                          final initialHour =
                                              int.tryParse(parts[0]) ?? 7;
                                          final initialMinute =
                                              int.tryParse(parts[1]) ?? 30;

                                          final TimeOfDay?
                                          picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: initialHour,
                                              minute: initialMinute,
                                            ),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                        primary: Color(
                                                          0xFF02B1BA,
                                                        ),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (picked != null) {
                                            final hour = picked.hour
                                                .toString()
                                                .padLeft(2, '0');
                                            final minute = picked.minute
                                                .toString()
                                                .padLeft(2, '0');
                                            setState(() {
                                              jamBuka = '$hour:$minute';
                                            });
                                          }
                                        },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isTutup
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF02B1BA),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        isTutup
                                            ? const Color(0xFFF8FAFC)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color:
                                            isTutup
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF02B1BA),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTutup ? '--:--' : jamBuka,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isTutup
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kanan Bawah: Jam Tutup
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Tutup',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    isTutup
                                        ? null
                                        : () async {
                                          final parts = jamTutup.split(':');
                                          final initialHour =
                                              int.tryParse(parts[0]) ?? 14;
                                          final initialMinute =
                                              int.tryParse(parts[1]) ?? 0;

                                          final TimeOfDay?
                                          picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: initialHour,
                                              minute: initialMinute,
                                            ),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                        primary: Color(
                                                          0xFF02B1BA,
                                                        ),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (picked != null) {
                                            final hour = picked.hour
                                                .toString()
                                                .padLeft(2, '0');
                                            final minute = picked.minute
                                                .toString()
                                                .padLeft(2, '0');
                                            setState(() {
                                              jamTutup = '$hour:$minute';
                                            });
                                          }
                                        },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isTutup
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF02B1BA),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        isTutup
                                            ? const Color(0xFFF8FAFC)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color:
                                            isTutup
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF02B1BA),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTutup ? '--:--' : jamTutup,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isTutup
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (hari == null || hari!.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Harap pilih hari',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final updatedJam = JamOperasionalModel(
                                id: jam.id,
                                hari: hari!,
                                jamBuka: isTutup ? '' : jamBuka,
                                jamTutup: isTutup ? '' : jamTutup,
                              );
                              controller.updateJamOperasional(
                                jam.id!,
                                updatedJam,
                              );
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02B1BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
