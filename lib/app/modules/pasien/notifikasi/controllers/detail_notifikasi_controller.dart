import 'package:get/get.dart';

import '../../../../data/models/notifikasi_model.dart';
import '../../../../data/services/firestore/notifikasi_firestore_service.dart';

class DetailNotifikasiController extends GetxController {
  final NotifikasiFirestoreService _notifikasiService = NotifikasiFirestoreService();
  
  late final NotifikasiModel notifikasi;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get notification data from arguments (support both Model and ID)
    final args = Get.arguments;
    if (args is NotifikasiModel) {
      notifikasi = args;
      _markAsRead();
    } else if (args is String) {
      // If passed as ID, load from Firestore
      loadNotifikasiById(args);
    } else {
      // Fallback for Map (backward compatibility)
      final map = args as Map<String, dynamic>;
      notifikasi = NotifikasiModel.fromFirestore(map as dynamic);
      _markAsRead();
    }
  }
  
  Future<void> loadNotifikasiById(String notifikasiId) async {
    try {
      isLoading.value = true;
      final list = await _notifikasiService.getNotifikasi();
      final found = list.firstWhereOrNull((n) => n.id == notifikasiId);
      if (found != null) {
        notifikasi = found;
        _markAsRead();
      }
    } catch (e) {
      print('Error loading notifikasi: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _markAsRead() async {
    if (!notifikasi.isRead) {
      try {
        await _notifikasiService.markAsRead(notifikasi.id!);
      } catch (e) {
        print('Error marking as read: $e');
      }
    }
  }
  
  // Backward compatibility getter
  Map<String, dynamic> get notification => {
    'title': notifikasi.title,
    'message': notifikasi.message,
    'type': notifikasi.type,
    'timestamp': notifikasi.createdAt,
  };
}
