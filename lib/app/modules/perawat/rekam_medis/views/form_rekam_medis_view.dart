import 'package:flutter/material.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';

class FormRekamMedisView extends StatefulWidget {
  final Map<String, dynamic> pasienData;

  const FormRekamMedisView({
    Key? key,
    required this.pasienData,
  }) : super(key: key);

  @override
  State<FormRekamMedisView> createState() => _FormRekamMedisViewState();
}

class _FormRekamMedisViewState extends State<FormRekamMedisView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - Identitas Pasien (read-only from pasienData)
  late final TextEditingController _namaPasienController;
  late final TextEditingController _idPasienController;
  late final TextEditingController _usiaController;
  late final TextEditingController _poliTujuanController;
  
  // Controllers - Tanda Vital
  final _tekananDarahSistolikController = TextEditingController();
  final _tekananDarahDiastolikController = TextEditingController();
  final _nadiController = TextEditingController();
  final _suhuController = TextEditingController();
  final _pernapasanController = TextEditingController();
  
  // Controllers - Antropometri
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _imtController = TextEditingController();
  
  // Controllers - Keluhan & Anamnesis
  final _keluhanUtamaController = TextEditingController();
  final _riwayatPenyakitController = TextEditingController();
  final _alergiController = TextEditingController();

  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    // Initialize from pasienData
    _namaPasienController = TextEditingController(text: widget.pasienData['nama'] ?? 'Anisa Ayu');
    _idPasienController = TextEditingController(text: '202210370311009');
    _usiaController = TextEditingController(text: '21 Tahun');
    _poliTujuanController = TextEditingController(text: 'Poli umum');
    
    // Add listeners untuk auto-calculate IMT
    _beratBadanController.addListener(_calculateIMT);
    _tinggiBadanController.addListener(_calculateIMT);
  }

  void _calculateIMT() {
    final berat = double.tryParse(_beratBadanController.text);
    final tinggi = double.tryParse(_tinggiBadanController.text);
    
    if (berat != null && tinggi != null && tinggi > 0) {
      final tinggiMeter = tinggi / 100;
      final imt = berat / (tinggiMeter * tinggiMeter);
      _imtController.text = imt.toStringAsFixed(1);
    } else {
      _imtController.text = '';
    }
  }

  void _simpanData() {
    setState(() {
      _showWarning = false;
    });

    if (_formKey.currentState!.validate()) {
      // Validasi semua field tanda vital terisi
      if (_tekananDarahSistolikController.text.isEmpty ||
          _tekananDarahDiastolikController.text.isEmpty ||
          _nadiController.text.isEmpty ||
          _suhuController.text.isEmpty ||
          _pernapasanController.text.isEmpty ||
          _beratBadanController.text.isEmpty ||
          _tinggiBadanController.text.isEmpty ||
          _keluhanUtamaController.text.isEmpty) {
        setState(() {
          _showWarning = true;
        });
        return;
      }

      // TODO: Simpan ke database
      SnackbarHelper.showSuccess('Data rekam medis berhasil disimpan');
      Navigator.pop(context);
    } else {
      setState(() {
        _showWarning = true;
      });
    }
  }

  @override
  void dispose() {
    _namaPasienController.dispose();
    _idPasienController.dispose();
    _usiaController.dispose();
    _poliTujuanController.dispose();
    _tekananDarahSistolikController.dispose();
    _tekananDarahDiastolikController.dispose();
    _nadiController.dispose();
    _suhuController.dispose();
    _pernapasanController.dispose();
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    _imtController.dispose();
    _keluhanUtamaController.dispose();
    _riwayatPenyakitController.dispose();
    _alergiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Form Rekam Medis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identitas Pasien
              _buildSectionTitle('Identitas Pasien'),
              const SizedBox(height: 12),
              _buildLabel('Nama Pasien'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_namaPasienController),
              const SizedBox(height: 12),
              
              _buildLabel('Id Pasien'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_idPasienController),
              const SizedBox(height: 12),
              
              _buildLabel('Usia'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_usiaController),
              const SizedBox(height: 12),
              
              _buildLabel('Poli Tujuan'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_poliTujuanController),
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
                      controller: _tekananDarahSistolikController,
                      hintText: '120',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: _buildNumberFieldWithSuffix(
                      controller: _tekananDarahDiastolikController,
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
                controller: _nadiController,
                hintText: '78',
                suffix: '/menit',
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Suhu'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _suhuController,
                hintText: '36',
                suffix: '°C',
              ),
              const SizedBox(height: 12),
              
              _buildLabel('Pernapasan'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _pernapasanController,
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
                controller: _beratBadanController,
                hintText: '60',
                suffix: 'kg',
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Tinggi Badan'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _tinggiBadanController,
                hintText: '170',
                suffix: 'cm',
              ),
              const SizedBox(height: 12),
              
              _buildLabel('IMT'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _imtController,
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
                controller: _keluhanUtamaController,
                hintText: 'Contoh : Demam sejak 3 hari yang lalu, dan flu',
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
                controller: _riwayatPenyakitController,
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
                controller: _alergiController,
                hintText: 'Contoh : Udang dan kacang tanah',
                maxLines: 2,
                backgroundColor: AppColors.white,
                textColor: Colors.black87,
                hintColor: Colors.grey,
                borderColor: AppColors.primary,
                borderWidth: 2,
              ),
              const SizedBox(height: 16),
              
              // Warning Box
              if (_showWarning)
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                      onPressed: _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SIMPAN DATA',
                        style: AppTextStyles.bodyLarge.copyWith(
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
          const TextSpan(
            text: ' (*)',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.grey,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberFieldWithSuffix({
    required TextEditingController controller,
    required String hintText,
    required String suffix,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      readOnly: readOnly,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffix,
        suffixStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.grey,
        ),
        filled: true,
        fillColor: readOnly ? AppColors.backgroundLight : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
