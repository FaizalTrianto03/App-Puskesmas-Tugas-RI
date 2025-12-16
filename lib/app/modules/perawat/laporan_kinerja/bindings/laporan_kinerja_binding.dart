import 'package:get/get.dart';
import '../controllers/laporan_kinerja_controller.dart';

class LaporanKinerjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaporanKinerjaController>(
      () => LaporanKinerjaController(),
    );
  }
}
