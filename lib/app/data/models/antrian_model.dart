import 'package:cloud_firestore/cloud_firestore.dart';

class AntrianModel {
  final String? id;
  final String pasienId;
  final String email;
  final String namaLengkap;
  final String noRekamMedis;
  final String jenisLayanan;
  final String keluhan;
  final String? nomorBPJS;
  final String queueNumber;
  // contoh status: 'menunggu', 'menunggu_verifikasi', 'menunggu_dokter',
  // 'sedang_dilayani', 'dilayani_dokter', 'selesai_diperiksa',
  // 'siap_ambil_obat', 'menunggu_apoteker', 'dilayani_apoteker',
  // 'selesai', 'dibatalkan'
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? dokterNama;
  final String? diagnosis;
  final String? tindakan;
  final String tanggal;
  final String? tanggalLahir;

  // Data perawat (verifikasi & vital signs)
  // Format: {
  //   'perawatId': String,
  //   'perawatNama': String,
  //   'tekananDarah': String (e.g., "120/80"),
  //   'nadi': int (bpm),
  //   'suhu': double (°C),
  //   'beratBadan': double (kg),
  //   'tinggiBadan': double (cm),
  //   'catatan': String,
  //   'waktuVerifikasi': Timestamp
  // }
  final Map<String, dynamic>? perawatData;

  // Data dokter (pemeriksaan lanjutan)
  // Format: {
  //   'dokterId': String,
  //   'dokterNama': String,
  //   'anamnesis': String,
  //   'diagnosis': String,
  //   'tindakan': String,
  //   'waktuPemeriksaan': Timestamp
  // }
  final Map<String, dynamic>? dokterData;

  // List resep obat dari dokter
  // Format: [
  //   {
  //     'idObat': String,
  //     'namaObat': String,
  //     'dosis': String (e.g., "500mg"),
  //     'jumlah': int,
  //     'satuan': String,
  //     'aturanPakai': String (e.g., "3x1 sehari sesudah makan"),
  //     'hargaSatuan': int,
  //     'totalHarga': int
  //   }
  // ]
  final List<Map<String, dynamic>>? resepObat;

  // Data apoteker (penyiapan obat)
  // Format: {
  //   'apotekerId': String,
  //   'apotekerNama': String,
  //   'waktuSiap': Timestamp,
  //   'catatan': String
  // }
  final Map<String, dynamic>? apotekerData;

  // Data pembayaran
  // Format: {
  //   'totalBiaya': int,
  //   'biayaLayanan': int,
  //   'biayaObat': int,
  //   'metodePembayaran': String ('tunai', 'bpjs', 'transfer'),
  //   'statusPembayaran': String ('belum_bayar', 'sudah_bayar'),
  //   'waktuPembayaran': Timestamp?
  // }
  final Map<String, dynamic>? pembayaranData;

  // Informasi ruangan pelayanan
  final String? ruanganId;
  final String? ruanganNama;

  // Data pembatalan
  final String? alasanPembatalan;
  final DateTime? waktuPembatalan;
  final String? dibatalkanOleh; // 'pasien' atau 'perawat'
  final String? dibatalkanOlehNama; // Nama perawat yang batalkan (jika by perawat)
  final String? dibatalkanOlehId; // ID perawat yang batalkan (jika by perawat)
  
  // Data dilewati (skip)
  final DateTime? dilewatiAt;
  final String? dilewatiOleh; // 'perawat'
  final String? dilewatiOlehNama; // Nama perawat yang lewati
  final String? dilewatiOlehId; // ID perawat yang lewati
  
  // Indikasi rawat inap
  final bool? perluRawatInap;

  AntrianModel({
    this.id,
    required this.pasienId,
    required this.email,
    required this.namaLengkap,
    required this.noRekamMedis,
    required this.jenisLayanan,
    required this.keluhan,
    this.nomorBPJS,
    required this.queueNumber,
    this.status = 'menunggu',
    required this.createdAt,
    this.updatedAt,
    this.dokterNama,
    this.diagnosis,
    this.tindakan,
    required this.tanggal,
    this.tanggalLahir,
    this.perawatData,
    this.dokterData,
    this.resepObat,
    this.apotekerData,
    this.pembayaranData,
    this.ruanganId,
    this.ruanganNama,
    this.alasanPembatalan,
    this.waktuPembatalan,
    this.dibatalkanOleh,
    this.dibatalkanOlehNama,
    this.dibatalkanOlehId,
    this.dilewatiAt,
    this.dilewatiOleh,
    this.dilewatiOlehNama,
    this.dilewatiOlehId,
    this.perluRawatInap,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'pasienId': pasienId,
      'email': email,
      'namaLengkap': namaLengkap,
      'noRekamMedis': noRekamMedis,
      'jenisLayanan': jenisLayanan,
      'keluhan': keluhan,
      'nomorBPJS': nomorBPJS,
      'queueNumber': queueNumber,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'dokterNama': dokterNama,
      'diagnosis': diagnosis,
      'tindakan': tindakan,
      'tanggal': tanggal,
      'tanggalLahir': tanggalLahir,
      'perawatData': perawatData,
      'dokterData': dokterData,
      'resepObat': resepObat,
      'apotekerData': apotekerData,
      'pembayaranData': pembayaranData,
      'ruanganId': ruanganId,
      'ruanganNama': ruanganNama,
      'alasanPembatalan': alasanPembatalan,
      'waktuPembatalan': waktuPembatalan != null ? Timestamp.fromDate(waktuPembatalan!) : null,
      'dibatalkanOleh': dibatalkanOleh,
      'dibatalkanOlehNama': dibatalkanOlehNama,
      'dibatalkanOlehId': dibatalkanOlehId,
      'dilewatiAt': dilewatiAt != null ? Timestamp.fromDate(dilewatiAt!) : null,
      'dilewatiOleh': dilewatiOleh,
      'dilewatiOlehNama': dilewatiOlehNama,
      'dilewatiOlehId': dilewatiOlehId,
      'perluRawatInap': perluRawatInap,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory AntrianModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AntrianModel(
      id: doc.id,
      pasienId: data['pasienId'] ?? '',
      email: data['email'] ?? '',
      namaLengkap: data['namaLengkap'] ?? '',
      noRekamMedis: data['noRekamMedis'] ?? '',
      jenisLayanan: data['jenisLayanan'] ?? '',
      keluhan: data['keluhan'] ?? '',
      nomorBPJS: data['nomorBPJS'],
      queueNumber: data['queueNumber'] ?? '',
      status: data['status'] ?? 'menunggu',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      dokterNama: data['dokterNama'],
      diagnosis: data['diagnosis'],
      tindakan: data['tindakan'],
      tanggal: data['tanggal'] ?? '',
      tanggalLahir: data['tanggalLahir'],
      perawatData: data['perawatData'] != null
          ? Map<String, dynamic>.from(data['perawatData'] as Map)
          : null,
      dokterData: data['dokterData'] != null
          ? Map<String, dynamic>.from(data['dokterData'] as Map)
          : null,
      resepObat: (data['resepObat'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      apotekerData: data['apotekerData'] != null
          ? Map<String, dynamic>.from(data['apotekerData'] as Map)
          : null,
      pembayaranData: data['pembayaranData'] != null
          ? Map<String, dynamic>.from(data['pembayaranData'] as Map)
          : null,
      ruanganId: data['ruanganId'],
      ruanganNama: data['ruanganNama'] ?? '-',
      alasanPembatalan: data['alasanPembatalan'],
      waktuPembatalan: data['waktuPembatalan'] != null
          ? (data['waktuPembatalan'] as Timestamp).toDate()
          : null,
      dibatalkanOleh: data['dibatalkanOleh'],
      dibatalkanOlehNama: data['dibatalkanOlehNama'],
      dibatalkanOlehId: data['dibatalkanOlehId'],
      dilewatiAt: data['dilewatiAt'] != null
          ? (data['dilewatiAt'] as Timestamp).toDate()
          : null,
      dilewatiOleh: data['dilewatiOleh'],
      dilewatiOlehNama: data['dilewatiOlehNama'],
      dilewatiOlehId: data['dilewatiOlehId'],
      perluRawatInap: data['perluRawatInap'] as bool?,
    );
  }

  // Create from Map
  factory AntrianModel.fromMap(Map<String, dynamic> map) {
    return AntrianModel(
      id: map['id'],
      pasienId: map['pasienId'] ?? '',
      email: map['email'] ?? '',
      namaLengkap: map['namaLengkap'] ?? '',
      noRekamMedis: map['noRekamMedis'] ?? '',
      jenisLayanan: map['jenisLayanan'] ?? '',
      keluhan: map['keluhan'] ?? '',
      nomorBPJS: map['nomorBPJS'],
      queueNumber: map['queueNumber'] ?? '',
      status: map['status'] ?? 'menunggu',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : null,
      dokterNama: map['dokterNama'],
      diagnosis: map['diagnosis'],
      tindakan: map['tindakan'],
      tanggal: map['tanggal'] ?? '',
      tanggalLahir: map['tanggalLahir'],
      perawatData: map['perawatData'] != null
          ? Map<String, dynamic>.from(map['perawatData'] as Map)
          : null,
      dokterData: map['dokterData'] != null
          ? Map<String, dynamic>.from(map['dokterData'] as Map)
          : null,
      resepObat: (map['resepObat'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      apotekerData: map['apotekerData'] != null
          ? Map<String, dynamic>.from(map['apotekerData'] as Map)
          : null,
      pembayaranData: map['pembayaranData'] != null
          ? Map<String, dynamic>.from(map['pembayaranData'] as Map)
          : null,
      ruanganId: map['ruanganId'],
      ruanganNama: map['ruanganNama'] ?? '-',
      alasanPembatalan: map['alasanPembatalan'],
      waktuPembatalan: map['waktuPembatalan'] != null
          ? (map['waktuPembatalan'] is Timestamp
              ? (map['waktuPembatalan'] as Timestamp).toDate()
              : DateTime.parse(map['waktuPembatalan']))
          : null,
      dibatalkanOleh: map['dibatalkanOleh'],
      dibatalkanOlehNama: map['dibatalkanOlehNama'],
      dibatalkanOlehId: map['dibatalkanOlehId'],
      dilewatiAt: map['dilewatiAt'] != null
          ? (map['dilewatiAt'] is Timestamp
              ? (map['dilewatiAt'] as Timestamp).toDate()
              : DateTime.parse(map['dilewatiAt']))
          : null,
      dilewatiOleh: map['dilewatiOleh'],
      dilewatiOlehNama: map['dilewatiOlehNama'],
      dilewatiOlehId: map['dilewatiOlehId'],
      perluRawatInap: map['perluRawatInap'] as bool?,
    );
  }

  // Copy with method for updates
  AntrianModel copyWith({
    String? id,
    String? pasienId,
    String? email,
    String? namaLengkap,
    String? noRekamMedis,
    String? jenisLayanan,
    String? keluhan,
    String? nomorBPJS,
    String? queueNumber,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dokterNama,
    String? diagnosis,
    String? tindakan,
    String? tanggal,
    String? tanggalLahir,
    Map<String, dynamic>? perawatData,
    Map<String, dynamic>? dokterData,
    List<Map<String, dynamic>>? resepObat,
    Map<String, dynamic>? apotekerData,
    Map<String, dynamic>? pembayaranData,
    String? ruanganId,
    String? ruanganNama,
    String? alasanPembatalan,
    DateTime? waktuPembatalan,
    DateTime? dilewatiAt,
    String? dilewatiOleh,
    String? dilewatiOlehNama,
    String? dilewatiOlehId,
    bool? perluRawatInap,
  }) {
    return AntrianModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      email: email ?? this.email,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noRekamMedis: noRekamMedis ?? this.noRekamMedis,
      jenisLayanan: jenisLayanan ?? this.jenisLayanan,
      keluhan: keluhan ?? this.keluhan,
      nomorBPJS: nomorBPJS ?? this.nomorBPJS,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dokterNama: dokterNama ?? this.dokterNama,
      diagnosis: diagnosis ?? this.diagnosis,
      tindakan: tindakan ?? this.tindakan,
      tanggal: tanggal ?? this.tanggal,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      perawatData: perawatData ?? this.perawatData,
      dokterData: dokterData ?? this.dokterData,
      resepObat: resepObat ?? this.resepObat,
      apotekerData: apotekerData ?? this.apotekerData,
      pembayaranData: pembayaranData ?? this.pembayaranData,
      ruanganId: ruanganId ?? this.ruanganId,
      ruanganNama: ruanganNama ?? this.ruanganNama,
      alasanPembatalan: alasanPembatalan ?? this.alasanPembatalan,
      waktuPembatalan: waktuPembatalan ?? this.waktuPembatalan,
      dibatalkanOleh: this.dibatalkanOleh,
      dibatalkanOlehNama: this.dibatalkanOlehNama,
      dibatalkanOlehId: this.dibatalkanOlehId,
      dilewatiAt: dilewatiAt ?? this.dilewatiAt,
      dilewatiOleh: dilewatiOleh ?? this.dilewatiOleh,
      dilewatiOlehNama: dilewatiOlehNama ?? this.dilewatiOlehNama,
      dilewatiOlehId: dilewatiOlehId ?? this.dilewatiOlehId,
      perluRawatInap: perluRawatInap ?? this.perluRawatInap,
    );
  }

  // Helper methods
  bool get sudahDiverifikasiPerawat => perawatData != null && perawatData!.isNotEmpty;
  bool get sudahDiperiksaDokter => dokterData != null && dokterData!.isNotEmpty;
  bool get adaResepObat => resepObat != null && resepObat!.isNotEmpty;
  bool get sudahDisiapkanApoteker => apotekerData != null && apotekerData!.isNotEmpty;
  bool get sudahDibayar => pembayaranData != null && 
                           pembayaranData!['statusPembayaran'] == 'sudah_bayar';
  bool get isDilewati => status == 'dilewati';

  // Get total biaya obat
  int get totalBiayaObat {
    if (resepObat == null || resepObat!.isEmpty) return 0;
    return resepObat!.fold<int>(
      0,
      (sum, item) => sum + (item['totalHarga'] as int? ?? 0),
    );
  }

  // Get total biaya keseluruhan
  int get totalBiaya {
    return pembayaranData?['totalBiaya'] as int? ?? 0;
  }

  // Status helpers
  bool get isMenunggu => status == 'menunggu';
  bool get isMenungguVerifikasi => status == 'menunggu_verifikasi';
  bool get isMenungguDokter => status == 'menunggu_dokter';
  bool get isSedangDilayani => status == 'sedang_dilayani';
  bool get isSelesaiDiperiksa => status == 'selesai_diperiksa';
  bool get isSiapAmbilObat => status == 'siap_ambil_obat';
  bool get isSelesai => status == 'selesai';
  bool get isDibatalkan => status == 'dibatalkan';
}
