import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/kelola_data_diri_controller.dart';

class KelolaDataDiriView extends GetView<KelolaDataDiriController> {
  const KelolaDataDiriView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final ScrollController _scrollController = ScrollController();
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          'Kelola Data Diri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF02B1BA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF02B1BA),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'Nama Lengkap'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.namaController,
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: const Color(0xFF02B1BA),
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF02B1BA),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'NIK'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.nikController,
                        hintText: 'Masukkan 16 digit NIK',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: const Color(0xFF02B1BA),
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIK harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF02B1BA),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'Alamat'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.alamatController,
                        hintText: 'Masukkan alamat lengkap',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: const Color(0xFF02B1BA),
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF02B1BA),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'Nomor HP'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.noHpController,
                        hintText: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: const Color(0xFF02B1BA),
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor HP harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF02B1BA),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'Email'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: const Color(0xFF02B1BA),
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Email harus menggunakan Gmail (@gmail.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF02B1BA),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(text: 'Jenis Kelamin'),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF02B1BA),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.jenisKelamin.value = 'L';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: controller.jenisKelamin.value == 'L'
                                                  ? const Color(0xFF02B1BA)
                                                  : Colors.white,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(11),
                                                bottomLeft: Radius.circular(11),
                                              ),
                                            ),
                                            child: Text(
                                              'L',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: controller.jenisKelamin.value == 'L'
                                                    ? Colors.white
                                                    : const Color(0xFF02B1BA),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 48,
                                        color: const Color(0xFF02B1BA),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.jenisKelamin.value = 'P';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: controller.jenisKelamin.value == 'P'
                                                  ? const Color(0xFF02B1BA)
                                                  : Colors.white,
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(11),
                                                bottomRight: Radius.circular(11),
                                              ),
                                            ),
                                            child: Text(
                                              'P',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: controller.jenisKelamin.value == 'P'
                                                    ? Colors.white
                                                    : const Color(0xFF02B1BA),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF02B1BA),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(text: 'Tanggal Lahir'),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2003, 9, 9),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: Color(0xFF02B1BA),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      controller.tanggalLahir.value = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                    }
                                  },
                                  child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF02B1BA),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.tanggalLahir.value.isEmpty ? 'dd/mm/yyyy' : controller.tanggalLahir.value,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: controller.tanggalLahir.value.isEmpty ? Colors.grey : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value 
                            ? null 
                            : () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateDataDiri();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF02B1BA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SIMPAN PERUBAHAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
