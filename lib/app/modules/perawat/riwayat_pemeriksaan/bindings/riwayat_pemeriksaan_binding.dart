import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';

class RiwayatPemeriksaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatPemeriksaanController>(
      () => RiwayatPemeriksaanController(),
    );
  }
}
