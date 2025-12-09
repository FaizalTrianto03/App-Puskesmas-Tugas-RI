import 'package:get/get.dart';

import '../controllers/pasien_dashboard_controller.dart';

class PasienDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PasienDashboardController>(
      PasienDashboardController(),
    );
  }
}
