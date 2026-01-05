import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/obat_model.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/form_pemeriksaan_controller.dart';

class FormPemeriksaanView extends StatefulWidget {
  final Map<String, dynamic> pasienData;

  const FormPemeriksaanView({
    super.key,
    required this.pasienData,
  });

  @override
  State<FormPemeriksaanView> createState() => _FormPemeriksaanViewState();
}

class _FormPemeriksaanViewState extends State<FormPemeriksaanView> {
  late FormPemeriksaanController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    controller = Get.put(FormPemeriksaanController());
    controller.initializePasienData(widget.pasienData);
  }

  @override
  void dispose() {
    Get.delete<FormPemeriksaanController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
        title: const Text(
          'Form Pemeriksaan Pasien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingMasterData.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF02B1BA)),
                SizedBox(height: 16),
                Text('Memuat data master...'),
              ],
            ),
          );
        }

        return Column(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientInfoCard(),
                        const SizedBox(height: 16),
                        _buildPerawatDataSection(),
                        const SizedBox(height: 16),
                        _buildDiagnosaSection(),
                        const SizedBox(height: 16),
                        _buildTindakanSection(),
                        const SizedBox(height: 16),
                        _buildObatSection(),
                        const SizedBox(height: 16),
                        _buildRawatInapSection(),
                        const SizedBox(height: 16),
                        _buildCatatanSection(),
                        const SizedBox(height: 16),
                        _buildTotalBiayaSection(),
                        const SizedBox(height: 24),
                        _buildSimpanButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPatientInfoCard() {
    final nomorBPJS = widget.pasienData['nomorBPJS'];
    final isBPJS = nomorBPJS != null && nomorBPJS.toString().isNotEmpty;
    final jenisPembayaran = isBPJS ? 'BPJS' : 'Umum';

    return Column(
      children: [
        // Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02B1BA).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pasienData['namaLengkap'] ??
                          widget.pasienData['nama'] ??
                          '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. RM: ${widget.pasienData['noRekamMedis'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBPJS ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jenisPembayaran,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isBPJS ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Antrian Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
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
                  Icons.confirmation_number,
                  color: Color(0xFF02B1BA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Antrian',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      widget.pasienData['queueNumber'] ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.pasienData['jenisLayanan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02B1BA),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Section Readonly - Data dari Perawat
  Widget _buildPerawatDataSection() {
    final perawatData = widget.pasienData['perawatData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF02B1BA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Data Pemeriksaan Perawat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (perawatData['perawatName'] != null)
                Text(
                  'oleh ${perawatData['perawatName']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tanda Vital Row
          Row(
            children: [
              _buildReadonlyField('TD', '${perawatData['tekananDarahSistolik'] ?? '-'}/${perawatData['tekananDarahDiastolik'] ?? '-'}', 'mmHg'),
              const SizedBox(width: 8),
              _buildReadonlyField('Suhu', '${perawatData['suhu'] ?? '-'}', '°C'),
              const SizedBox(width: 8),
              _buildReadonlyField('Nadi', '${perawatData['nadi'] ?? '-'}', 'x/mnt'),
              const SizedBox(width: 8),
              _buildReadonlyField('RR', '${perawatData['pernapasan'] ?? '-'}', 'x/mnt'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildReadonlyField('BB', '${perawatData['beratBadan'] ?? '-'}', 'kg'),
              const SizedBox(width: 8),
              _buildReadonlyField('TB', '${perawatData['tinggiBadan'] ?? '-'}', 'cm'),
              const SizedBox(width: 8),
              _buildReadonlyField('IMT', '${perawatData['imt'] ?? '-'}', 'kg/m²'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Keluhan dan Riwayat
          _buildReadonlyTextRow('Keluhan Utama', perawatData['keluhanUtama'] ?? widget.pasienData['keluhan'] ?? '-'),
          const SizedBox(height: 8),
          _buildReadonlyTextRow('Riwayat Penyakit', perawatData['riwayatPenyakit'] ?? '-'),
          const SizedBox(height: 8),
          _buildReadonlyTextRow('Alergi', perawatData['alergi'] ?? '-'),
        ],
      ),
    );
  }
  
  Widget _buildReadonlyField(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReadonlyTextRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosaSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF02B1BA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Diagnosa',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.diagnosaController,
            labelText: 'Hasil Diagnosa',
            hintText: 'Masukkan diagnosa',
            maxLines: 2,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: controller.validateRequired,
          ),
        ],
      ),
    );
  }

  Widget _buildTindakanSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.healing,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tindakan Medis',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.tindakanController,
            labelText: 'Tindakan',
            hintText: 'Tindakan yang dilakukan',
            maxLines: 3,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: controller.validateRequired,
          ),
        ],
      ),
    );
  }

  Widget _buildObatSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02B1BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Color(0xFF02B1BA),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Resep Obat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: controller.tambahResepObat,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B1BA),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            return Column(
              children: controller.resepObatList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildObatCard(index, item);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildObatCard(int index, ResepObatItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF02B1BA).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obat ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              Obx(() {
                if (controller.resepObatList.length > 1) {
                  return IconButton(
                    onPressed: () => controller.hapusResepObat(index),
                    icon: const Icon(Icons.delete, color: Color(0xFFFF4242)),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 10),

          // Autocomplete Obat
          _buildObatAutocomplete(index, item),
          const SizedBox(height: 10),

          // Row: Dosis & Jumlah
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: item.dosisController,
                  labelText: 'Dosis',
                  hintText: 'contoh: 500mg',
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: item.jumlahController,
                  labelText: 'Jumlah',
                  hintText: '10',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                  onChanged: (_) => controller.resepObatList.refresh(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Aturan Pakai
          CustomTextField(
            controller: item.aturanPakaiController,
            labelText: 'Aturan Pakai',
            hintText: 'contoh: 3x1 sehari sesudah makan',
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
          ),

          // Info obat yang dipilih
          if (item.idObat != null && item.idObat!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.satuan} @ Rp ${_formatCurrency(item.hargaSatuan)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Obx(() {
                    controller.resepObatList.length; // trigger rebuild
                    final jumlah =
                        int.tryParse(item.jumlahController.text) ?? 1;
                    final total = jumlah * item.hargaSatuan;
                    return Text(
                      'Subtotal: Rp ${_formatCurrency(total)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObatAutocomplete(int index, ResepObatItem item) {
    return Autocomplete<ObatModel>(
      displayStringForOption: (ObatModel option) => option.namaObat,
      initialValue: TextEditingValue(text: item.namaObat),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return controller.masterObatList;
        }
        return controller.masterObatList.where((ObatModel obat) {
          return obat.namaObat
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (ObatModel selection) {
        controller.pilihObat(index, selection);
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Pilih Obat',
            hintText: 'Ketik nama obat...',
            labelStyle: const TextStyle(color: Color(0xFF02B1BA)),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            prefixIcon:
                const Icon(Icons.search, color: Color(0xFF02B1BA), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF02B1BA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF02B1BA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF02B1BA), width: 2),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final obat = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF02B1BA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.medication,
                          size: 18, color: Color(0xFF02B1BA)),
                    ),
                    title: Text(
                      obat.namaObat,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Stok: ${obat.stok} ${obat.satuan} • Rp ${_formatCurrency(obat.hargaSatuan)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: _buildStokBadge(obat.stok),
                    onTap: () => onSelected(obat),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStokBadge(int stok) {
    Color bgColor;
    Color textColor;
    if (stok == 0) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else if (stok <= 10) {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$stok',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildRawatInapSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.hotel,
                  color: Color(0xFF2196F3),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rawat Inap (Opsional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Pasien perlu rawat inap?',
                  style: TextStyle(fontSize: 14),
                ),
                value: controller.perluRawatInap.value,
                onChanged: controller.toggleRawatInap,
                activeColor: const Color(0xFF02B1BA),
              )),
          Obx(() {
            if (!controller.perluRawatInap.value) return const SizedBox.shrink();

            if (controller.ruanganList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tidak ada ruangan tersedia saat ini',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<Map<String, dynamic>>(
              value: controller.selectedRuangan.value,
              decoration: InputDecoration(
                labelText: 'Pilih Ruangan',
                labelStyle: const TextStyle(color: Color(0xFF02B1BA)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF02B1BA)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF02B1BA)),
                ),
              ),
              items: controller.ruanganList.map((ruangan) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: ruangan,
                  child: Text(
                    '${ruangan['namaRuangan']} (${ruangan['kodeRuangan']})',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: controller.pilihRuangan,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCatatanSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.note_alt,
                  color: Color(0xFFFF4242),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Catatan Dokter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.catatanController,
            labelText: 'Catatan (Opsional)',
            hintText: 'Catatan tambahan',
            maxLines: 3,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBiayaSection() {
    final jenisPembayaran = widget.pasienData['jenisPembayaran'] ??
        widget.pasienData['metodePembayaran'] ??
        'Umum';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: jenisPembayaran == 'BPJS'
            ? Colors.green.shade50
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              jenisPembayaran == 'BPJS' ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                jenisPembayaran == 'BPJS'
                    ? Icons.verified_user
                    : Icons.receipt_long,
                color: jenisPembayaran == 'BPJS'
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                jenisPembayaran == 'BPJS' ? 'Ditanggung BPJS' : 'Estimasi Biaya Obat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: jenisPembayaran == 'BPJS'
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (jenisPembayaran == 'BPJS')
            Text(
              'Biaya obat dan layanan ditanggung oleh BPJS Kesehatan',
              style: TextStyle(fontSize: 13, color: Colors.green.shade700),
            )
          else
            Obx(() {
              controller.resepObatList.length; // trigger rebuild
              return Text(
                'Rp ${_formatCurrency(controller.totalBiayaObat)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSimpanButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.simpanHasilPemeriksaan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF02B1BA),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Hasil Pemeriksaan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
