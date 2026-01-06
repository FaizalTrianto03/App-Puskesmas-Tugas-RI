import 'package:get/get.dart';
import '../controllers/riwayat_penyiapan_controller.dart';

class RiwayatPenyiapanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatPenyiapanController>(
      () => RiwayatPenyiapanController(),
    );
  }
}
