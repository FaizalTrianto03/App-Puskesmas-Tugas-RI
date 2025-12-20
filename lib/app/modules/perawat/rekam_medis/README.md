# Rekam Medis Controller - Perawat Module

Dokumentasi lengkap untuk Controller dan Binding halaman Rekam Medis Perawat.

---

## 📁 Struktur File

```
lib/app/modules/perawat/rekam_medis/
├── bindings/
│   ├── rekam_medis_binding.dart           # Binding untuk list rekam medis
│   └── form_rekam_medis_binding.dart      # Binding untuk form input
├── controllers/
│   ├── rekam_medis_controller.dart        # Controller list rekam medis
│   └── form_rekam_medis_controller.dart   # Controller form input
└── views/
    └── form_rekam_medis_view.dart         # UI form rekam medis
```

---

## 🎯 RekamMedisController

Controller utama untuk mengelola list antrian yang perlu diisi rekam medisnya.

### **Fitur Utama:**
- ✅ Load antrian yang sudah diverifikasi (status: `menunggu_dokter`)
- ✅ Search & filter pasien
- ✅ Tracking statistik pasien
- ✅ Navigate ke form input rekam medis

### **Properties:**

```dart
// Observable
final isLoading = false.obs;
final antrianList = <Map<String, dynamic>>[].obs;
final selectedFilter = 'semua'.obs;
final searchQuery = ''.obs;
```

### **Methods:**

#### `loadAntrianTerverifikasi()`
Load daftar antrian yang sudah diverifikasi perawat dan menunggu dokter.

```dart
void loadAntrianTerverifikasi()
```

#### `setSearchQuery(String query)`
Set pencarian pasien berdasarkan nama, nomor antrian, atau rekam medis.

```dart
void setSearchQuery('Anisa')
```

#### `filteredAntrianList`
Getter untuk list yang sudah difilter.

```dart
List<Map<String, dynamic>> get filteredAntrianList
```

#### `getTotalPasien()`
Mendapatkan jumlah total pasien.

```dart
int getTotalPasien()
```

---

## 📝 FormRekamMedisController

Controller untuk form input rekam medis pasien.

### **Fitur Utama:**
- ✅ Auto-calculate IMT (Indeks Massa Tubuh)
- ✅ Validasi komprehensif untuk vital signs
- ✅ Load existing data rekam medis
- ✅ Simpan rekam medis ke database

### **Text Controllers:**

#### Identitas (Read-only)
```dart
final namaPasienController = TextEditingController();
final idPasienController = TextEditingController();
final usiaController = TextEditingController();
final poliTujuanController = TextEditingController();
```

#### Tanda Vital
```dart
final tekananDarahSistolikController = TextEditingController();
final tekananDarahDiastolikController = TextEditingController();
final nadiController = TextEditingController();
final suhuController = TextEditingController();
final pernapasanController = TextEditingController();
```

#### Antropometri
```dart
final beratBadanController = TextEditingController();
final tinggiBadanController = TextEditingController();
final imtController = TextEditingController(); // Auto-calculated
```

#### Anamnesis
```dart
final keluhanUtamaController = TextEditingController();
final riwayatPenyakitController = TextEditingController();
final alergiController = TextEditingController();
```

### **Methods:**

#### `initializePasienData(Map<String, dynamic> data)`
Initialize form dengan data pasien dari antrian.

```dart
controller.initializePasienData({
  'id': 'G-009',
  'namaLengkap': 'Anisa Ayu',
  'pasienId': 'P001',
  'noRekamMedis': 'RM001',
  'keluhan': 'Demam dan batuk',
  'poliklinik': 'Poli Umum',
  'tanggalLahir': '2001-01-15',
});
```

#### Validasi Methods

##### `validateTekananDarah(String? value, String type)`
Validasi tekanan darah dengan range normal.

```dart
// Sistolik: 70-250 mmHg
// Diastolik: 40-150 mmHg
controller.validateTekananDarah('120', 'sistolik')
```

##### `validateNadi(String? value)`
Validasi nadi (40-180 bpm).

```dart
controller.validateNadi('72')
```

##### `validateSuhu(String? value)`
Validasi suhu tubuh (35-42°C).

```dart
controller.validateSuhu('36.5')
```

##### `validatePernapasan(String? value)`
Validasi frekuensi pernapasan (10-40 x/menit).

```dart
controller.validatePernapasan('18')
```

##### `validateBeratBadan(String? value)`
Validasi berat badan (1-300 kg).

```dart
controller.validateBeratBadan('55')
```

##### `validateTinggiBadan(String? value)`
Validasi tinggi badan (50-250 cm).

```dart
controller.validateTinggiBadan('160')
```

#### `getStatusIMT()`
Mendapatkan kategori IMT.

```dart
String status = controller.getStatusIMT();
// Return: 'Berat Kurang' | 'Normal' | 'Berat Lebih' | 'Obesitas'
```

#### `getStatusIMTColor()`
Mendapatkan warna untuk status IMT.

```dart
Color color = controller.getStatusIMTColor();
// Return: Colors.red | Colors.green | Colors.orange
```

#### `simpanRekamMedis()`
Simpan rekam medis ke database.

```dart
await controller.simpanRekamMedis();
```

#### `resetForm()`
Reset semua field form.

```dart
controller.resetForm();
```

---

## 🔧 Cara Penggunaan

### 1. Register Binding di Routes

```dart
// app_pages.dart
GetPage(
  name: _Paths.perawatRekamMedis,
  page: () => const RekamMedisView(),
  binding: RekamMedisBinding(),
),
GetPage(
  name: _Paths.perawatFormRekamMedis,
  page: () => const FormRekamMedisView(),
  binding: FormRekamMedisBinding(),
),
```

### 2. Gunakan di View (List)

```dart
class RekamMedisView extends GetView<RekamMedisController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: controller.filteredAntrianList.length,
          itemBuilder: (context, index) {
            final antrian = controller.filteredAntrianList[index];
            return ListTile(
              title: Text(antrian['namaLengkap']),
              subtitle: Text(antrian['queueNumber']),
              onTap: () {
                // Navigate ke form
                Get.to(() => FormRekamMedisView(
                  pasienData: antrian,
                ));
              },
            );
          },
        );
      }),
    );
  }
}
```

### 3. Gunakan di View (Form)

```dart
class FormRekamMedisView extends GetView<FormRekamMedisController> {
  final Map<String, dynamic> pasienData;
  
  const FormRekamMedisView({required this.pasienData});
  
  @override
  Widget build(BuildContext context) {
    // Initialize dengan data pasien
    controller.initializePasienData(pasienData);
    
    return Scaffold(
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // Tekanan Darah Sistolik
            TextFormField(
              controller: controller.tekananDarahSistolikController,
              validator: (value) => 
                controller.validateTekananDarah(value, 'sistolik'),
              decoration: InputDecoration(
                labelText: 'Tekanan Darah Sistolik',
                hintText: '120',
              ),
            ),
            
            // Berat Badan
            TextFormField(
              controller: controller.beratBadanController,
              validator: controller.validateBeratBadan,
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
              ),
            ),
            
            // IMT (Auto-calculated, read-only)
            Obx(() => Text(
              'IMT: ${controller.imtController.text} - ${controller.getStatusIMT()}',
              style: TextStyle(
                color: controller.getStatusIMTColor(),
              ),
            )),
            
            // Button Simpan
            ElevatedButton(
              onPressed: controller.simpanRekamMedis,
              child: Obx(() => controller.isLoading.value
                ? CircularProgressIndicator()
                : Text('Simpan Rekam Medis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 Data Flow

```
1. Pasien Daftar
   ↓
2. Perawat Verifikasi
   ↓ (Status: menunggu_dokter)
3. RekamMedisController.loadAntrianTerverifikasi()
   ↓
4. Tampilkan List Pasien
   ↓
5. Perawat Pilih Pasien
   ↓
6. Navigate ke FormRekamMedisView
   ↓
7. FormRekamMedisController.initializePasienData()
   ↓
8. Load Existing Data (jika ada)
   ↓
9. Perawat Input Tanda Vital & Antropometri
   ↓
10. Auto-calculate IMT
   ↓
11. Validasi Form
   ↓
12. controller.simpanRekamMedis()
   ↓
13. Save to PemeriksaanService
   ↓
14. Success → Back to List
```

---

## ✅ Validasi Range Normal

| Field | Range Normal | Satuan |
|-------|-------------|--------|
| Tekanan Darah Sistolik | 70 - 250 | mmHg |
| Tekanan Darah Diastolik | 40 - 150 | mmHg |
| Nadi | 40 - 180 | bpm |
| Suhu | 35 - 42 | °C |
| Pernapasan | 10 - 40 | x/menit |
| Berat Badan | 1 - 300 | kg |
| Tinggi Badan | 50 - 250 | cm |

### Kategori IMT:
- **< 18.5** = Berat Kurang (Red)
- **18.5 - 24.9** = Normal (Green)
- **25 - 29.9** = Berat Lebih (Orange)
- **≥ 30** = Obesitas (Red)

---

## 🎨 Features

### ✅ Auto-Calculation
- IMT otomatis terhitung saat input berat & tinggi badan
- Status IMT otomatis update dengan warna sesuai kategori

### ✅ Data Persistence
- Load existing rekam medis jika sudah pernah diinput
- Auto-fill form dengan data sebelumnya

### ✅ Comprehensive Validation
- Range validation untuk vital signs
- Required field validation
- Number format validation

### ✅ User Feedback
- Loading state saat simpan data
- Success/error snackbar
- Auto-navigate setelah sukses

---

## 🔐 Security & Session

Data perawat yang menyimpan:
```dart
{
  'perawatId': 'PER001',
  'perawatName': 'Mukarram Luthfi',
  'inputBy': 'perawat',
  'timestamp': '2025-12-09T...',
}
```

---

## 🚀 Testing

### Unit Test Example:
```dart
test('Calculate IMT correctly', () {
  controller.beratBadanController.text = '55';
  controller.tinggiBadanController.text = '160';
  
  expect(controller.imtController.text, '21.5');
  expect(controller.getStatusIMT(), 'Normal');
});

test('Validate tekanan darah', () {
  final result = controller.validateTekananDarah('120', 'sistolik');
  expect(result, null);
  
  final invalid = controller.validateTekananDarah('300', 'sistolik');
  expect(invalid, isNotNull);
});
```

---

## 📝 Notes

1. **Controller terpisah** untuk list dan form agar lebih modular
2. **Validasi ketat** untuk memastikan data vital signs akurat
3. **Auto-calculate IMT** untuk kemudahan perawat
4. **Load existing data** agar tidak perlu input ulang
5. **Session tracking** untuk audit trail

---

**Created by:** AI Assistant  
**Date:** December 9, 2025  
**Module:** Perawat - Rekam Medis
