import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/kelola_ruangan_controller.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_text_field.dart';

class TambahRuanganView extends GetView<KelolaRuanganController> {
  const TambahRuanganView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final isEdit = arguments?['isEdit'] ?? false;
    final ruanganId = arguments?['ruanganId'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
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
        title: Text(
          isEdit ? 'Edit Ruangan' : 'Tambah Ruangan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Ruangan
                _buildLabel('Nama Ruangan'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.namaRuanganController,
                  hintText: 'Masukkan nama ruangan',
                  prefixIcon: const Icon(Icons.meeting_room, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: controller.validateNamaRuangan,
                ),
                const SizedBox(height: 16),

                // Kode Ruangan
                _buildLabel('Kode Ruangan'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF02B1BA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(Icons.qr_code, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller.kodeRuanganController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Contoh: R101, R202',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          validator: controller.validateKodeRuangan,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lokasi
                _buildLabel('Lokasi'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.lokasiController,
                  hintText: 'Contoh: Lantai 2 Gedung A',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: controller.validateLokasi,
                ),
                const SizedBox(height: 16),

                // Kapasitas
                _buildLabel('Kapasitas'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF02B1BA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(Icons.people, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller.kapasitasController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Jumlah orang',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          validator: controller.validateKapasitas,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fasilitas
                _buildLabel('Fasilitas (Opsional)'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.fasilitasController,
                  hintText: 'Contoh: AC, TV, Tempat Tidur Pasien',
                  prefixIcon: const Icon(Icons.home_repair_service, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Status
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.selectedStatus.value = 'tersedia',
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: controller.selectedStatus.value == 'tersedia'
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: controller.selectedStatus.value == 'tersedia'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tersedia',
                                style: TextStyle(
                                  color: controller.selectedStatus.value == 'tersedia'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.selectedStatus.value = 'digunakan',
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: controller.selectedStatus.value == 'digunakan'
                                ? Colors.grey.shade600
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: controller.selectedStatus.value == 'digunakan'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Digunakan',
                                style: TextStyle(
                                  color: controller.selectedStatus.value == 'digunakan'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 32),

                // Submit Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (isEdit && ruanganId != null) {
                              controller.updateRuangan(ruanganId);
                            } else {
                              controller.addRuangan();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEdit ? 'Perbarui Ruangan' : 'Tambah Ruangan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
        children: [
          TextSpan(text: label),
          if (!label.contains('Opsional'))
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
