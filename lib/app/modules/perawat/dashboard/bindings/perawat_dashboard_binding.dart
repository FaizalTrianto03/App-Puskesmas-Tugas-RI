import 'package:get/get.dart';

import '../controllers/perawat_dashboard_controller.dart';

class PerawatDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerawatDashboardController>(
      () => PerawatDashboardController(),
    );
  }
}
