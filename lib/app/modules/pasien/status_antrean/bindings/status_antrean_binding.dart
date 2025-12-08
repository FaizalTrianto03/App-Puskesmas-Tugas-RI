import 'package:get/get.dart';

import '../controllers/status_antrean_controller.dart';

class StatusAntreanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatusAntreanController>(
      () => StatusAntreanController(),
    );
  }
}
