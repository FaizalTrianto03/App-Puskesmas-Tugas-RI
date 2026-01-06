import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../controllers/form_rekam_medis_controller.dart';

class FormRekamMedisView extends GetView<FormRekamMedisController> {
  final Map<String, dynamic> pasienData;

  const FormRekamMedisView({Key? key, required this.pasienData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller with patient data
    Get.lazyPut(() => FormRekamMedisController());
    controller.initializePasienData(pasienData);

    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF02B1BA),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Form Rekam Medis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
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
              child: QuarterCircleBackground(
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Identitas Pasien - Compact Design
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary,
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
                              _buildSectionTitle('Identitas Pasien'),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Nama Pasien',
                                controller.namaPasienController.text,
                              ),
                              _buildInfoRow(
                                'No. Rekam Medis',
                                controller.noRekamMedisController.text,
                              ),
                              _buildInfoRow(
                                'No. Antrian',
                                controller.noAntrianController.text,
                              ),
                              _buildInfoRow(
                                'Usia',
                                controller.usiaController.text,
                              ),
                              _buildInfoRow(
                                'Poli Tujuan',
                                controller.poliTujuanController.text,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tanda Vital
                        _buildSectionTitle('Tanda Vital'),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Tekanan Darah'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberField(
                                controller:
                                    controller.tekananDarahSistolikController,
                                hintText: '120',
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '/',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildNumberFieldWithSuffix(
                                controller:
                                    controller.tekananDarahDiastolikController,
                                hintText: '80',
                                suffix: 'mmHg',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Nadi'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.nadiController,
                          hintText: '78',
                          suffix: '/menit',
                        ),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Suhu'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.suhuController,
                          hintText: '36',
                          suffix: '°C',
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Pernapasan'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.pernapasanController,
                          hintText: '18',
                          suffix: '/menit',
                        ),
                        const SizedBox(height: 24),

                        // Antropometri
                        _buildSectionTitle('Antropometri'),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Berat Badan'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.beratBadanController,
                          hintText: '60',
                          suffix: 'kg',
                        ),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Tinggi Badan'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.tinggiBadanController,
                          hintText: '170',
                          suffix: 'cm',
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('IMT'),
                        const SizedBox(height: 8),
                        _buildNumberFieldWithSuffix(
                          controller: controller.imtController,
                          hintText: '20.8',
                          suffix: 'kg/m²',
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),

                        // Info Box IMT
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Indeks Massa Tubuh (IMT) dihitung otomatis : Berat Badan (kg) dibagi Tinggi Badan (m)',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Keluhan & Anamnesis
                        _buildSectionTitle('Keluhan & Anamnesis'),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Keluhan Utama'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: controller.keluhanUtamaController,
                          hintText:
                              'Contoh : Demam sejak 3 hari yang lalu, dan flu',
                          maxLines: 3,
                          backgroundColor: AppColors.white,
                          textColor: Colors.black87,
                          hintColor: Colors.grey,
                          borderColor: AppColors.primary,
                          borderWidth: 2,
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Riwayat Penyakit'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: controller.riwayatPenyakitController,
                          hintText: 'Contoh : Demam berdarah',
                          maxLines: 2,
                          backgroundColor: AppColors.white,
                          textColor: Colors.black87,
                          hintColor: Colors.grey,
                          borderColor: AppColors.primary,
                          borderWidth: 2,
                        ),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Alergi'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: controller.alergiController,
                          hintText: 'Contoh : Udang dan kacang tanah',
                          maxLines: 2,
                          backgroundColor: AppColors.white,
                          textColor: Colors.black87,
                          hintColor: Colors.grey,
                          borderColor: AppColors.primary,
                          borderWidth: 2,
                        ),
                        const SizedBox(height: 24),

                        // Dokter Assignment
                        _buildSectionTitle('Dokter Pemeriksa'),
                        const SizedBox(height: 12),

                        _buildLabelRequired('Pilih Dokter'),
                        const SizedBox(height: 8),
                        Obx(() {
                          if (controller.isLoadingDokter.value) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.dokterList.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tidak ada dokter tersedia',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedDokterId.value,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                                hintText: 'Pilih dokter pemeriksa',
                              ),
                              items: controller.dokterList.map((dokter) {
                                return DropdownMenuItem<String>(
                                  value: dokter['id'],
                                  child: Text(
                                    dokter['namaLengkap'] ?? '',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.setSelectedDokter(value);
                              },
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primary,
                              ),
                              dropdownColor: Colors.white,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Warning Box - Permanen Visible
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFB020),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF8C00),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Peringatan',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: const Color(0xFFFF8C00),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pastikan semua data bertanda bintang merah (*) sudah terisi dengan benar sebelum disimpan',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF856404),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'BATAL',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    controller.isLoading.value
                                        ? null
                                        : controller.simpanDanVerifikasi,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    controller.isLoading.value
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          'Simpan',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLabelRequired(String label) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' *', style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNumberFieldWithSuffix({
    required TextEditingController controller,
    required String hintText,
    required String suffix,
    bool readOnly = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          readOnly: readOnly,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Hanya angka dan titik desimal
          ],
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffix,
            suffixStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            filled: true,
            fillColor: readOnly ? AppColors.backgroundLight : AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
