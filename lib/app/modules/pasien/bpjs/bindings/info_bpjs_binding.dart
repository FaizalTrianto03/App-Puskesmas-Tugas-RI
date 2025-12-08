import 'package:get/get.dart';

import '../controllers/info_bpjs_controller.dart';

class InfoBpjsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InfoBpjsController>(
      () => InfoBpjsController(),
    );
  }
}
