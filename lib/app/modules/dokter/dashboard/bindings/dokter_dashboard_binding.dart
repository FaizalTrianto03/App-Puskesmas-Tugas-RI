import 'package:get/get.dart';

import '../controllers/dokter_dashboard_controller.dart';

class DokterDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterDashboardController>(
      () => DokterDashboardController(),
    );
  }
}
