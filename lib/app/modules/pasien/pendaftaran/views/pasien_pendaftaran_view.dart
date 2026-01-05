import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pendaftaran_controller.dart';
import 'pasien_active_queue_view.dart';
import '../../../../routes/app_pages.dart';

class PasienPendaftaranView extends GetView<PendaftaranController> {
  const PasienPendaftaranView({super.key});

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
          'Pendaftaran Pasien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        // Jika ada antrian aktif, tampilkan halaman terpisah
        if (controller.hasActiveQueue.value) {
          return const PasienActiveQueueView();
        }

        // Form pendaftaran
        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Stats
                _buildHeaderStats(),
                const SizedBox(height: 16),

                // Detail Pendaftaran Card
                _buildDetailPendaftaranCard(),
                const SizedBox(height: 16),

                // Poli Dropdown
                _buildSectionTitle('Poli Tujuan'),
                const SizedBox(height: 8),
                _buildPoliDropdown(),
                const SizedBox(height: 16),

                // Keluhan
                _buildSectionTitle('Keluhan'),
                const SizedBox(height: 8),
                _buildKeluhanField(),
                const SizedBox(height: 16),

                // Pembayaran
                _buildSectionTitle('Jenis Pembayaran'),
                const SizedBox(height: 8),
                _buildPembayaranButtons(),
                Obx(() {
                  if (controller.useBPJS.value) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildBPJSField(),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),

                // Estimasi Waktu
                _buildEstimationCard(),
                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF4DD4DB)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(() {
        final count = controller.queueCount.value;
        final minutesPerPatient = 15;
        final totalMinutes = (count + 1) * minutesPerPatient;
        final totalWaitHours = totalMinutes / 60; // Float division
        
        // Format: 0.25, 0.5, 0.75, 1.0, dst
        final hoursFormatted = totalWaitHours.toStringAsFixed(2);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(count.toString(), 'Antrean'),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
            _buildStatItem(minutesPerPatient.toString(), 'Menit/Pasien'),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
            _buildStatItem(hoursFormatted, 'Jam Tunggu'),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPendaftaranCard() {
    return Obx(() {
      final profile = controller.userProfile.value;
      final isLoading = controller.isLoadingProfile.value;
      
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Pendaftaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Navigate dan tunggu result
                    await Get.toNamed(Routes.pasienKelolaDataDiri);
                    // Reload profile setelah kembali dari edit
                    controller.refreshProfile();
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF02B1BA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF02B1BA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Color(0xFF02B1BA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Nama:', isLoading ? 'Memuat...' : (profile?.namaLengkap ?? '-')),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('NIK:', isLoading ? 'Memuat...' : (profile?.nik ?? '-')),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('Tanggal Lahir:', isLoading ? 'Memuat...' : (profile?.tanggalLahir ?? '-')),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('Jenis Kelamin:', isLoading ? 'Memuat...' : _getJenisKelamin(profile?.jenisKelamin)),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('No. HP:', isLoading ? 'Memuat...' : (profile?.noHp ?? '-')),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('Alamat:', isLoading ? 'Memuat...' : (profile?.alamat ?? '-')),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF02B1BA),
        ),
        children: [
          TextSpan(text: title),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF02B1BA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi Waktu Kedatangan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final estimatedTime = controller.estimatedTime.value;
                  return Text(
                    estimatedTime != null
                        ? DateFormat('HH:mm').format(estimatedTime)
                        : '--:--',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4242),
                      height: 1,
                    ),
                  );
                }),
                const SizedBox(height: 6),
                const Text(
                  'Jika Anda mendaftar saat ini, perkiraan waktu pelayanan Anda adalah sekitar jam tersebut.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4242).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.info,
                        size: 14,
                        color: Color(0xFFFF4242),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Waktu dapat berubah sesuai kondisi antrean',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFF4242),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliDropdown() {
    return Obx(() {
      if (controller.isLoadingPoli.value) {
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF02B1BA), width: 2),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text(
                'Memuat daftar poli...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () => _showPoliPicker(),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF02B1BA),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02B1BA).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.selectedLayanan.value.isEmpty
                      ? 'Silahkan pilih Poli tujuan Anda'
                      : controller.selectedLayanan.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.selectedLayanan.value.isEmpty
                        ? Colors.grey
                        : const Color(0xFF1E293B),
                    fontWeight: controller.selectedLayanan.value.isEmpty
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: const Color(0xFF02B1BA),
                size: 28,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showPoliPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02B1BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Color(0xFF02B1BA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pilih Poli Tujuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // List Poli
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.layananOptions.length,
                itemBuilder: (context, index) {
                  final option = controller.layananOptions[index];
                  final isSelected = controller.selectedLayanan.value == option['value'];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF02B1BA).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF02B1BA)
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        controller.setLayanan(option['value'] as String);
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF02B1BA)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.local_hospital,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option['label'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF02B1BA)
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF02B1BA),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  Widget _buildKeluhanField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.description_outlined, color: Colors.grey, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller.keluhanController,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'Isi keluhan Anda',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPembayaranButtons() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildPaymentButton(
                label: 'BPJS',
                icon: Icons.credit_card,
                isSelected: controller.useBPJS.value,
                onTap: () => controller.useBPJS.value = true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentButton(
                label: 'Umum',
                icon: Icons.payments,
                isSelected: !controller.useBPJS.value,
                onTap: () => controller.useBPJS.value = false,
              ),
            ),
          ],
        ));
  }

  Widget _buildBPJSField() {
    return TextFormField(
      controller: controller.nomorBPJSController,
      keyboardType: TextInputType.number,
      maxLength: 13,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: controller.validateBPJS,
      decoration: InputDecoration(
        hintText: 'Nomor BPJS (13 digit)',
        prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF02B1BA), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF02B1BA), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF02B1BA), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4242), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4242), width: 2.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPaymentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF02B1BA),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF02B1BA),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.submitPendaftaran,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF02B1BA),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'DAFTAR & AMBIL NOMOR ANTREAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )),
    );
  }

  String _getJenisKelamin(String? jenisKelamin) {
    if (jenisKelamin == null || jenisKelamin.isEmpty) return '-';
    
    final normalized = jenisKelamin.trim().toUpperCase();
    
    if (normalized == 'L' || normalized == 'LAKI' || normalized == 'LAKI-LAKI') {
      return 'Laki-laki';
    } else if (normalized == 'P' || normalized == 'PEREMPUAN') {
      return 'Perempuan';
    }
    
    return jenisKelamin; // Return original jika tidak match
  }
}
