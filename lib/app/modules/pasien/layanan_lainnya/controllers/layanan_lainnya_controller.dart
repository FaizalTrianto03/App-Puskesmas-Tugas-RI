import 'package:get/get.dart';

class LayananLainnyaController extends GetxController {
  // State untuk hover dan press effects
  final isHoverLokasi = false.obs;
  final isHoverBPJS = false.obs;
  final isPressedLokasi = false.obs;
  final isPressedBPJS = false.obs;

  void setHoverLokasi(bool value) => isHoverLokasi.value = value;
  void setHoverBPJS(bool value) => isHoverBPJS.value = value;
  void setPressedLokasi(bool value) => isPressedLokasi.value = value;
  void setPressedBPJS(bool value) => isPressedBPJS.value = value;
}
