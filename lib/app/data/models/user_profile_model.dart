import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String? id;
  final String namaLengkap;
  final String email;
  final String role;
  final String? nik;
  final String? noRekamMedis;
  final String? noHp;
  final String? alamat;
  final String? jenisKelamin;
  final String? tanggalLahir;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    this.id,
    required this.namaLengkap,
    required this.email,
    this.role = 'pasien',
    this.nik,
    this.noRekamMedis,
    this.noHp,
    this.alamat,
    this.jenisKelamin,
    this.tanggalLahir,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': namaLengkap,
      'email': email,
      'role': role,
      'nik': nik,
      'noRekamMedis': noRekamMedis,
      'noHp': noHp,
      'alamat': alamat,
      'jenisKelamin': jenisKelamin,
      'tanggalLahir': tanggalLahir,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      namaLengkap: data['namaLengkap'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'pasien',
      nik: data['nik'],
      noRekamMedis: data['noRekamMedis'],
      noHp: data['noHp'],
      alamat: data['alamat'],
      jenisKelamin: data['jenisKelamin'],
      tanggalLahir: data['tanggalLahir'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? namaLengkap,
    String? email,
    String? role,
    String? nik,
    String? noRekamMedis,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
    String? tanggalLahir,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      role: role ?? this.role,
      nik: nik ?? this.nik,
      noRekamMedis: noRekamMedis ?? this.noRekamMedis,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
