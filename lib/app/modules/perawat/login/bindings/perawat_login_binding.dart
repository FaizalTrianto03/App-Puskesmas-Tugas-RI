import 'package:get/get.dart';

import '../controllers/perawat_login_controller.dart';

class PerawatLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerawatLoginController>(
      () => PerawatLoginController(),
    );
  }
}
