import 'package:get/get.dart';
import '../controllers/riwayat_kunjungan_controller.dart';

class RiwayatKunjunganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatKunjunganController>(
      () => RiwayatKunjunganController(),
    );
  }
}
