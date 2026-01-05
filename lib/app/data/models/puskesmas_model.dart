import 'package:cloud_firestore/cloud_firestore.dart';

class PuskesmasModel {
  final String? id;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final String? telepon;
  final String? email;
  final String? website;
  final Map<String, String> jamOperasional; // Format: {"Senin - Kamis": "07:30 - 12:00 WIB", ...}
  final DateTime createdAt;
  final DateTime? updatedAt;

  PuskesmasModel({
    this.id,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.telepon,
    this.email,
    this.website,
    required this.jamOperasional,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore
  factory PuskesmasModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PuskesmasModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      alamat: data['alamat'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      telepon: data['telepon'],
      email: data['email'],
      website: data['website'],
      jamOperasional: Map<String, String>.from(data['jamOperasional'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'telepon': telepon,
      'email': email,
      'website': website,
      'jamOperasional': jamOperasional,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // Copy with
  PuskesmasModel copyWith({
    String? id,
    String? nama,
    String? alamat,
    double? latitude,
    double? longitude,
    String? telepon,
    String? email,
    String? website,
    Map<String, String>? jamOperasional,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PuskesmasModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
      website: website ?? this.website,
      jamOperasional: jamOperasional ?? this.jamOperasional,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
