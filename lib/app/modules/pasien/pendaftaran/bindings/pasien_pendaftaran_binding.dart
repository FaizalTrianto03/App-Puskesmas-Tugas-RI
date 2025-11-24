import 'package:get/get.dart';

import '../controllers/pasien_pendaftaran_controller.dart';

class PasienPendaftaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasienPendaftaranController>(
      () => PasienPendaftaranController(),
    );
  }
}
