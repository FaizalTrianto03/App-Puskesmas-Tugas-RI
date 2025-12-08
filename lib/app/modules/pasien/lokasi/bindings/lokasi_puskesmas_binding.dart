import 'package:get/get.dart';

import '../controllers/lokasi_puskesmas_controller.dart';

class LokasiPuskesmasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LokasiPuskesmasController>(
      () => LokasiPuskesmasController(),
    );
  }
}
