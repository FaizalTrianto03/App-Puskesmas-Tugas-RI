import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../utils/snackbar_helper.dart';

class FormPemeriksaanView extends StatefulWidget {
  final Map<String, dynamic> pasienData;

  const FormPemeriksaanView({
    Key? key,
    required this.pasienData,
  }) : super(key: key);

  @override
  State<FormPemeriksaanView> createState() => _FormPemeriksaanViewState();
}

class _FormPemeriksaanViewState extends State<FormPemeriksaanView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _diagnosaController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _tindakanController = TextEditingController();
  final _catatanController = TextEditingController();
  
  // Tanda Vital Controllers
  final _tekananDarahController = TextEditingController();
  final _suhuController = TextEditingController();
  final _nadiController = TextEditingController();
  final _pernapasanController = TextEditingController();
  
  // Obat List
  final List<Map<String, TextEditingController>> _obatList = [];

  @override
  void initState() {
    super.initState();
    // Isi keluhan dari data pasien
    _keluhanController.text = widget.pasienData['keluhan'] ?? '';
    // Tambah 1 obat default
    _tambahObat();
  }

  void _tambahObat() {
    setState(() {
      _obatList.add({
        'nama': TextEditingController(),
        'dosis': TextEditingController(),
      });
    });
  }

  void _hapusObat(int index) {
    setState(() {
      _obatList[index]['nama']!.dispose();
      _obatList[index]['dosis']!.dispose();
      _obatList.removeAt(index);
    });
  }

  void _simpanHasilPemeriksaan() {
    if (_formKey.currentState!.validate()) {
      // Validasi minimal 1 obat terisi
      bool adaObat = false;
      for (var obat in _obatList) {
        if (obat['nama']!.text.isNotEmpty && obat['dosis']!.text.isNotEmpty) {
          adaObat = true;
          break;
        }
      }

      if (!adaObat) {
        SnackbarHelper.showError('Minimal 1 obat harus diisi');
        return;
      }

      // TODO: Simpan ke database
      SnackbarHelper.showSuccess('Hasil pemeriksaan berhasil disimpan');
      
      // Kembali ke dashboard
      Get.back();
    }
  }

  @override
  void dispose() {
    _diagnosaController.dispose();
    _keluhanController.dispose();
    _tindakanController.dispose();
    _catatanController.dispose();
    _tekananDarahController.dispose();
    _suhuController.dispose();
    _nadiController.dispose();
    _pernapasanController.dispose();
    for (var obat in _obatList) {
      obat['nama']!.dispose();
      obat['dosis']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientInfoCard(),
                      const SizedBox(height: 16),
                      _buildTandaVitalSection(),
                      const SizedBox(height: 16),
                      _buildDiagnosaSection(),
                      const SizedBox(height: 16),
                      _buildKeluhanSection(),
                      const SizedBox(height: 16),
                      _buildTindakanSection(),
                      const SizedBox(height: 16),
                      _buildObatSection(),
                      const SizedBox(height: 16),
                      _buildCatatanSection(),
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
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
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
            padding: const EdgeInsets.all(10),
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
                  widget.pasienData['nama'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.pasienData['umur']} • ${widget.pasienData['golDarah']} • ${widget.pasienData['antrian']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTandaVitalSection() {
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
                  Icons.favorite,
                  color: Color(0xFF2196F3),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tanda Vital',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _tekananDarahController,
                  labelText: 'Tekanan Darah',
                  hintText: '120/80',
                  keyboardType: TextInputType.text,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                  validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  controller: _suhuController,
                  labelText: 'Suhu (°C)',
                  hintText: '36.5',
                  keyboardType: TextInputType.number,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                  validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _nadiController,
                  labelText: 'Nadi (bpm)',
                  hintText: '78',
                  keyboardType: TextInputType.number,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                  validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  controller: _pernapasanController,
                  labelText: 'Pernapasan (x/mnt)',
                  hintText: '18',
                  keyboardType: TextInputType.number,
                  borderColor: const Color(0xFF02B1BA),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  hintColor: Colors.grey.shade600,
                  validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                ),
              ),
            ],
          ),
        ],
      ),
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
            controller: _diagnosaController,
            labelText: 'Hasil Diagnosa',
            hintText: 'Masukkan diagnosa',
            maxLines: 2,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildKeluhanSection() {
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
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF9800),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Keluhan Pasien',
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
            controller: _keluhanController,
            labelText: 'Keluhan',
            hintText: 'Detail keluhan',
            maxLines: 3,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
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
            controller: _tindakanController,
            labelText: 'Tindakan',
            hintText: 'Tindakan yang dilakukan',
            maxLines: 3,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
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
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Color(0xFF9C27B0),
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
                onPressed: _tambahObat,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._obatList.asMap().entries.map((entry) {
            final index = entry.key;
            final obat = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
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
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      if (_obatList.length > 1)
                        IconButton(
                          onPressed: () => _hapusObat(index),
                          icon: const Icon(Icons.delete, color: Color(0xFFFF4242)),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: obat['nama']!,
                    labelText: 'Nama Obat',
                    hintText: 'contoh: Paracetamol 500mg',
                    borderColor: const Color(0xFF02B1BA),
                    borderWidth: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: obat['dosis']!,
                    labelText: 'Dosis',
                    hintText: 'contoh: 3x1 tablet/hari',
                    borderColor: const Color(0xFF02B1BA),
                    borderWidth: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey.shade600,
                  ),
                ],
              ),
            );
          }).toList(),
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
            controller: _catatanController,
            labelText: 'Catatan',
            hintText: 'Catatan tambahan',
            maxLines: 3,
            borderColor: const Color(0xFF02B1BA),
            borderWidth: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            hintColor: Colors.grey.shade600,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Catatan wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _simpanHasilPemeriksaan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF02B1BA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
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
    );
  }
}
