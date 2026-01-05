import 'package:cloud_firestore/cloud_firestore.dart';

class ObatModel {
  final String id;
  final String namaObat;
  final String jenisObat; // Tablet, Kapsul, Sirup, Salep, Injeksi, dll
  final String kategori; // Antibiotik, Analgesik, Vitamin, Antipiretik, dll
  final int stok;
  final String satuan; // tablet, kapsul, botol, tube, ampul, dll
  final int hargaSatuan;
  final String? keterangan;
  final DateTime? tanggalKadaluarsa;
  final DateTime createdAt;
  final DateTime updatedAt;

  ObatModel({
    required this.id,
    required this.namaObat,
    required this.jenisObat,
    required this.kategori,
    required this.stok,
    required this.satuan,
    required this.hargaSatuan,
    this.keterangan,
    this.tanggalKadaluarsa,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory ObatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ObatModel(
      id: doc.id,
      namaObat: data['namaObat'] ?? '',
      jenisObat: data['jenisObat'] ?? '',
      kategori: data['kategori'] ?? '',
      stok: data['stok'] ?? 0,
      satuan: data['satuan'] ?? '',
      hargaSatuan: data['hargaSatuan'] ?? 0,
      keterangan: data['keterangan'],
      tanggalKadaluarsa: (data['tanggalKadaluarsa'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'namaObat': namaObat,
      'jenisObat': jenisObat,
      'kategori': kategori,
      'stok': stok,
      'satuan': satuan,
      'hargaSatuan': hargaSatuan,
      'keterangan': keterangan,
      'tanggalKadaluarsa': tanggalKadaluarsa != null ? Timestamp.fromDate(tanggalKadaluarsa!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  ObatModel copyWith({
    String? id,
    String? namaObat,
    String? jenisObat,
    String? kategori,
    int? stok,
    String? satuan,
    int? hargaSatuan,
    String? keterangan,
    DateTime? tanggalKadaluarsa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ObatModel(
      id: id ?? this.id,
      namaObat: namaObat ?? this.namaObat,
      jenisObat: jenisObat ?? this.jenisObat,
      kategori: kategori ?? this.kategori,
      stok: stok ?? this.stok,
      satuan: satuan ?? this.satuan,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      keterangan: keterangan ?? this.keterangan,
      tanggalKadaluarsa: tanggalKadaluarsa ?? this.tanggalKadaluarsa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper untuk check stok
  bool get isStokKritis => stok <= 10;
  bool get isStokHampirHabis => stok > 10 && stok <= 30;
  bool get isStokAman => stok > 30;

  // Helper untuk status stok
  String get statusStok {
    if (stok == 0) return 'Habis';
    if (isStokKritis) return 'Kritis';
    if (isStokHampirHabis) return 'Hampir Habis';
    return 'Aman';
  }
}
