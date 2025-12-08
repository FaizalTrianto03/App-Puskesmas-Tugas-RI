import 'package:get/get.dart';

import '../controllers/layanan_lainnya_controller.dart';

class LayananLainnyaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayananLainnyaController>(
      () => LayananLainnyaController(),
    );
  }
}
