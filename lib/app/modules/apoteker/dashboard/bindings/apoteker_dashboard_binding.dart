import 'package:get/get.dart';

import '../controllers/apoteker_dashboard_controller.dart';

class ApotekerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApotekerDashboardController>(
      () => ApotekerDashboardController(),
    );
  }
}
