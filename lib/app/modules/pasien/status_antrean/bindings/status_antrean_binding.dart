import 'package:get/get.dart';

import '../controllers/status_antrean_controller.dart';

class StatusAntreanBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan put() bukan lazyPut() agar controller langsung diinisialisasi
    Get.put<StatusAntreanController>(
      StatusAntreanController(),
    );
  }
}
