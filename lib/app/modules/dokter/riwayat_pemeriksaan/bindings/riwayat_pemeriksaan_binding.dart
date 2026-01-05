import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';

class DokterRiwayatPemeriksaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterRiwayatPemeriksaanController>(
      () => DokterRiwayatPemeriksaanController(),
    );
  }
}
