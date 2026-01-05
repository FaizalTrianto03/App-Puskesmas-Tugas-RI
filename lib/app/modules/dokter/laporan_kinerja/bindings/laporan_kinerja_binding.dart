import 'package:get/get.dart';
import '../controllers/laporan_kinerja_controller.dart';

class DokterLaporanKinerjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterLaporanKinerjaController>(
      () => DokterLaporanKinerjaController(),
    );
  }
}
