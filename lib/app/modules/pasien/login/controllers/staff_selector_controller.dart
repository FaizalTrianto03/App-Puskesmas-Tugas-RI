import 'package:get/get.dart';

class StaffSelectorController extends GetxController {
  final hoveredIndex = Rxn<int>();
  final pressedIndex = Rxn<int>();

  void setHoveredIndex(int? index) => hoveredIndex.value = index;
  void setPressedIndex(int? index) => pressedIndex.value = index;
}
