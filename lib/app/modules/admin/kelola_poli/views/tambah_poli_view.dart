import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/kelola_poli_controller.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_text_field.dart';

class TambahPoliView extends GetView<KelolaPoliController> {
  const TambahPoliView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final isEdit = arguments?['isEdit'] ?? false;
    final poliId = arguments?['poliId'] as String?;

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
          isEdit ? 'Edit Poli' : 'Tambah Poli',
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
                // Nama Poli
                _buildLabel('Nama Poli'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.namaPoliController,
                  hintText: 'Masukkan nama poli',
                  prefixIcon: const Icon(Icons.local_hospital, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: controller.validateNamaPoli,
                ),
                const SizedBox(height: 16),

                // Kode Poli
                _buildLabel('Kode Poli'),
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
                          controller: controller.kodePoliController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Contoh: UMUM, GIGI',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          validator: controller.validateKodePoli,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                _buildLabel('Deskripsi (Opsional)'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.deskripsiController,
                  hintText: 'Masukkan deskripsi poli',
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
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
                        onTap: () => controller.selectedStatus.value = 'aktif',
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: controller.selectedStatus.value == 'aktif'
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: controller.selectedStatus.value == 'aktif'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Aktif',
                                style: TextStyle(
                                  color: controller.selectedStatus.value == 'aktif'
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
                        onTap: () => controller.selectedStatus.value = 'nonaktif',
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: controller.selectedStatus.value == 'nonaktif'
                                ? Colors.grey.shade600
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: controller.selectedStatus.value == 'nonaktif'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Nonaktif',
                                style: TextStyle(
                                  color: controller.selectedStatus.value == 'nonaktif'
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
                            if (isEdit && poliId != null) {
                              controller.updatePoli(poliId);
                            } else {
                              controller.addPoli();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Poli',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      ),
    );
  }
}
