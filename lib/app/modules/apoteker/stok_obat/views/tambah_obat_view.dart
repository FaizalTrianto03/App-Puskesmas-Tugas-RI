import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_date_picker_modal.dart';
import '../controllers/stok_obat_controller.dart';

// Currency Input Formatter
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse and format
    final number = int.parse(numericValue);
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TambahObatView extends GetView<StokObatController> {
  const TambahObatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEdit = Get.arguments?['isEdit'] ?? false;
    final obatId = Get.arguments?['obatId'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        title: Text(
          isEdit ? 'Edit Obat' : 'Tambah Obat',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              onPressed: () {
                final args = Get.arguments as Map<String, dynamic>?;
                final obatId = args?['obatId'] as String?;
                final namaObat = controller.namaObatController.text;
                
                if (obatId != null && namaObat.isNotEmpty) {
                  controller.hapusObat(obatId, namaObat);
                }
              },
              tooltip: 'Hapus Obat',
            ),
        ],
      ),
      body: QuarterCircleBackground(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informasi Obat',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF02B1BA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Obat
                _buildLabel('Nama Obat'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.namaObatController,
                  hintText: 'Masukkan nama obat',
                  prefixIcon: const Icon(Icons.medication, color: Colors.grey),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama obat harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Jenis Obat Dropdown
                _buildLabel('Jenis Obat'),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF02B1BA),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedJenisObat.value.isEmpty
                            ? null
                            : controller.selectedJenisObat.value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.category, color: Colors.grey),
                        ),
                        hint: const Text('Pilih jenis obat'),
                        items: controller.jenisObatOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedJenisObat.value = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis obat harus dipilih';
                          }
                          return null;
                        },
                      ),
                    )),
                const SizedBox(height: 16),

                // Kategori Dropdown
                _buildLabel('Kategori'),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF02B1BA),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedKategori.value.isEmpty
                            ? null
                            : controller.selectedKategori.value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.label, color: Colors.grey),
                        ),
                        hint: const Text('Pilih kategori'),
                        items: controller.kategoriOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedKategori.value = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kategori harus dipilih';
                          }
                          return null;
                        },
                      ),
                    )),
                const SizedBox(height: 16),

                // Stok
                _buildLabel('Stok'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF02B1BA), width: 1),
                  ),
                  child: TextFormField(
                    controller: controller.stokController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Masukkan jumlah stok',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.inventory_2, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok harus diisi';
                      }
                      final stok = int.tryParse(value);
                      if (stok == null || stok < 0) {
                        return 'Stok harus berupa angka positif';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Satuan Dropdown
                _buildLabel('Satuan'),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF02B1BA),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedSatuan.value.isEmpty
                            ? null
                            : controller.selectedSatuan.value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.scale, color: Colors.grey),
                        ),
                        hint: const Text('Pilih satuan'),
                        items: controller.satuanOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedSatuan.value = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Satuan harus dipilih';
                          }
                          return null;
                        },
                      ),
                    )),
                const SizedBox(height: 16),

                // Harga Satuan
                _buildLabel('Harga Satuan'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF02B1BA), width: 1),
                  ),
                  child: TextFormField(
                    controller: controller.hargaSatuanController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga satuan harus diisi';
                      }
                      // Remove formatting untuk validasi
                      final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      final harga = int.tryParse(numericValue);
                      if (harga == null || harga <= 0) {
                        return 'Harga satuan harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Tanggal Kadaluarsa
                _buildLabel('Tanggal Kadaluarsa (Opsional)'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await CustomDatePickerModal.show(
                      context,
                      initialDate: controller.tanggalKadaluarsa.value.isNotEmpty
                          ? _parseDate(controller.tanggalKadaluarsa.value)
                          : DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 tahun ke depan
                    );
                    if (picked != null) {
                      controller.tanggalKadaluarsa.value = 
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    }
                  },
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              controller.tanggalKadaluarsa.value.isEmpty
                                  ? 'Pilih tanggal kadaluarsa'
                                  : controller.tanggalKadaluarsa.value,
                              style: TextStyle(
                                color: controller.tanggalKadaluarsa.value.isEmpty
                                    ? Colors.grey
                                    : const Color(0xFF1E293B),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
                const SizedBox(height: 16),

                // Keterangan (Optional)
                _buildLabel('Keterangan (Opsional)'),
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
                  child: TextFormField(
                    controller: controller.keteranganController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan keterangan tambahan',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.simpanObat(isEdit: isEdit, obatId: obatId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02B1BA),
                        foregroundColor: Colors.white,
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
                          : Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Obat',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )),
                const SizedBox(height: 16),
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
        color: Color(0xFF1E293B),
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      // Ignore parsing error
    }
    return DateTime.now();
  }
}
