import 'package:cloud_firestore/cloud_firestore.dart';

class JamOperasionalModel {
  final String? id;
  final String hari; // Senin, Selasa, Rabu, dst (per hari individual)
  final String jamBuka; // "07:30" atau "" jika tutup
  final String jamTutup; // "14:00" atau "" jika tutup

  JamOperasionalModel({
    this.id,
    required this.hari,
    required this.jamBuka,
    required this.jamTutup,
  });

  // Convert from Firestore
  factory JamOperasionalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JamOperasionalModel(
      id: doc.id,
      hari: data['hari'] ?? '',
      jamBuka: data['jamBuka'] ?? '',
      jamTutup: data['jamTutup'] ?? '',
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'hari': hari,
      'jamBuka': jamBuka,
      'jamTutup': jamTutup,
    };
  }

  // Status buka/tutup berdasarkan apakah ada jam atau tidak
  bool get isBuka => jamBuka.isNotEmpty && jamTutup.isNotEmpty;

  // Display string untuk UI
  String get displayString {
    if (!isBuka) {
      return '$hari: Tutup';
    }
    return '$hari: $jamBuka - $jamTutup WIB';
  }

  // Jam display dengan WIB
  String get jamDisplay {
    if (!isBuka) return 'Tutup';
    return '$jamBuka - $jamTutup WIB';
  }

  // Status text
  String get statusText => isBuka ? 'Buka' : 'Tutup';
}
