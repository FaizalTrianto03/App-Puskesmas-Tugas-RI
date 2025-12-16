import 'package:get/get.dart';

class NotifikasiListController extends GetxController {
  final selectedFilter = 'Semua'.obs;
  final hoveredIndex = Rxn<int>();
  final pressedIndex = Rxn<int>();
  final hoveredFilterIndex = Rxn<int>();

  void setSelectedFilter(String filter) => selectedFilter.value = filter;
  void setHoveredIndex(int? index) => hoveredIndex.value = index;
  void setPressedIndex(int? index) => pressedIndex.value = index;
  void setHoveredFilterIndex(int? index) => hoveredFilterIndex.value = index;
}
