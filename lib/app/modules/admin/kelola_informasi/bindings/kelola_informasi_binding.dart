import 'package:get/get.dart';

import '../controllers/kelola_informasi_controller.dart';

class KelolaInformasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaInformasiController>(
      () => KelolaInformasiController(),
    );
  }
}
