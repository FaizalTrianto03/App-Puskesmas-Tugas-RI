import 'package:get/get.dart';

class RiwayatKunjunganController extends GetxController {
  final selectedBulan = 'Semua'.obs;
  final selectedPoli = 'Semua'.obs;

  void setSelectedBulan(String bulan) => selectedBulan.value = bulan;
  void setSelectedPoli(String poli) => selectedPoli.value = poli;
}
