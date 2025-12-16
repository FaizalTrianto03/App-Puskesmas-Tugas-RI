import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatKunjunganModel {
  final String? id;
  final String pasienId;
  final String namaLengkap;
  final String noRekamMedis;
  final String poli;
  final String dokter;
  final String keluhan;
  final String diagnosis;
  final String tindakan;
  final List<ObatModel>? resep;
  final DateTime tanggalKunjungan;
  final String noAntrean;
  final String status;
  final DateTime? kontrolDate;
  final VitalSignModel? vitalSign;

  RiwayatKunjunganModel({
    this.id,
    required this.pasienId,
    required this.namaLengkap,
    required this.noRekamMedis,
    required this.poli,
    required this.dokter,
    required this.keluhan,
    required this.diagnosis,
    required this.tindakan,
    this.resep,
    required this.tanggalKunjungan,
    required this.noAntrean,
    this.status = 'Selesai',
    this.kontrolDate,
    this.vitalSign,
  });

  Map<String, dynamic> toMap() {
    return {
      'pasienId': pasienId,
      'namaLengkap': namaLengkap,
      'noRekamMedis': noRekamMedis,
      'poli': poli,
      'dokter': dokter,
      'keluhan': keluhan,
      'diagnosis': diagnosis,
      'tindakan': tindakan,
      'resep': resep?.map((e) => e.toMap()).toList(),
      'tanggalKunjungan': Timestamp.fromDate(tanggalKunjungan),
      'noAntrean': noAntrean,
      'status': status,
      'kontrolDate': kontrolDate != null ? Timestamp.fromDate(kontrolDate!) : null,
      'vitalSign': vitalSign?.toMap(),
    };
  }

  factory RiwayatKunjunganModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RiwayatKunjunganModel(
      id: doc.id,
      pasienId: data['pasienId'] ?? '',
      namaLengkap: data['namaLengkap'] ?? '',
      noRekamMedis: data['noRekamMedis'] ?? '',
      poli: data['poli'] ?? '',
      dokter: data['dokter'] ?? '',
      keluhan: data['keluhan'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      tindakan: data['tindakan'] ?? '',
      resep: data['resep'] != null
          ? (data['resep'] as List).map((e) => ObatModel.fromMap(e)).toList()
          : null,
      tanggalKunjungan: (data['tanggalKunjungan'] as Timestamp).toDate(),
      noAntrean: data['noAntrean'] ?? '',
      status: data['status'] ?? 'Selesai',
      kontrolDate: data['kontrolDate'] != null
          ? (data['kontrolDate'] as Timestamp).toDate()
          : null,
      vitalSign: data['vitalSign'] != null
          ? VitalSignModel.fromMap(data['vitalSign'])
          : null,
    );
  }
}

class ObatModel {
  final String nama;
  final String dosis;
  final String aturan;

  ObatModel({
    required this.nama,
    required this.dosis,
    required this.aturan,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'dosis': dosis,
      'aturan': aturan,
    };
  }

  factory ObatModel.fromMap(Map<String, dynamic> map) {
    return ObatModel(
      nama: map['nama'] ?? '',
      dosis: map['dosis'] ?? '',
      aturan: map['aturan'] ?? '',
    );
  }
}

class VitalSignModel {
  final String tekananDarah;
  final String nadi;
  final String suhuTubuh;
  final String beratBadan;

  VitalSignModel({
    required this.tekananDarah,
    required this.nadi,
    required this.suhuTubuh,
    required this.beratBadan,
  });

  Map<String, dynamic> toMap() {
    return {
      'tekananDarah': tekananDarah,
      'nadi': nadi,
      'suhuTubuh': suhuTubuh,
      'beratBadan': beratBadan,
    };
  }

  factory VitalSignModel.fromMap(Map<String, dynamic> map) {
    return VitalSignModel(
      tekananDarah: map['tekananDarah'] ?? '-',
      nadi: map['nadi'] ?? '-',
      suhuTubuh: map['suhuTubuh'] ?? '-',
      beratBadan: map['beratBadan'] ?? '-',
    );
  }
}
