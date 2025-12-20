import 'package:cloud_firestore/cloud_firestore.dart';

class AntrianModel {
  final String? id;
  final String pasienId;
  final String namaLengkap;
  final String noRekamMedis;
  final String jenisLayanan;
  final String keluhan;
  final String? nomorBPJS;
  final String queueNumber;
  final String status; // 'menunggu', 'dipanggil', 'selesai', 'dibatalkan'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? dokterNama;
  final String? diagnosis;
  final String? tindakan;
  final String tanggal;
  final String? tanggalLahir;  // ✅ Tambahkan field tanggalLahir

  AntrianModel({
    this.id,
    required this.pasienId,
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
    this.tanggalLahir,  // ✅ Tambahkan ke constructor
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'pasienId': pasienId,
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
      'tanggalLahir': tanggalLahir,  // ✅ Tambahkan ke map
    };
  }

  // Create from Firestore DocumentSnapshot
  factory AntrianModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AntrianModel(
      id: doc.id,
      pasienId: data['pasienId'] ?? '',
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
      tanggalLahir: data['tanggalLahir'],  // ✅ Tambahkan
    );
  }

  // Create from Map
  factory AntrianModel.fromMap(Map<String, dynamic> map) {
    return AntrianModel(
      id: map['id'],
      pasienId: map['pasienId'] ?? '',
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
      tanggalLahir: map['tanggalLahir'],  // ✅ Tambahkan
    );
  }

  // Copy with method for updates
  AntrianModel copyWith({
    String? id,
    String? pasienId,
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
    String? tanggalLahir,  // ✅ Tambahkan
  }) {
    return AntrianModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
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
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,  // ✅ Tambahkan
    );
  }
}
