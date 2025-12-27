import 'package:get/get.dart';

import '../controllers/notifikasi_list_controller.dart';

class NotifikasiListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifikasiListController>(
      () => NotifikasiListController(),
    );
  }
}