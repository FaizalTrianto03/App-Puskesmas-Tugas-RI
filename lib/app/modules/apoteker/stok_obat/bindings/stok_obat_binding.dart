import 'package:get/get.dart';

import '../controllers/stok_obat_controller.dart';

class StokObatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StokObatController>(() => StokObatController());
  }
}
