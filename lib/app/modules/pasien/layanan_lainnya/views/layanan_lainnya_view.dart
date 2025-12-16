import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../../bpjs/views/info_bpjs_view.dart';
import '../../lokasi/views/lokasi_puskesmas_view.dart';
import '../controllers/layanan_lainnya_controller.dart';

class LayananLainnyaView extends GetView<LayananLainnyaController> {
  const LayananLainnyaView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LayananLainnyaController());
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Layanan Lainnya',
          style: TextStyle(
            color: Color(0xFF02B1BA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _buildMenuButton(
                context,
                icon: Icons.location_on,
                title: 'Lokasi Puskesmas',
                isHover: controller.isHoverLokasi.value,
                isPressed: controller.isPressedLokasi.value,
                onHoverChange: controller.setHoverLokasi,
                onPressedChange: controller.setPressedLokasi,
                onTap: () => Get.to(() => const LokasiPuskesmasView()),
              )),
              const SizedBox(height: 12),
              Obx(() => _buildMenuButton(
                context,
                icon: Icons.shield,
                title: 'Info BPJS',
                isHover: controller.isHoverBPJS.value,
                isPressed: controller.isPressedBPJS.value,
                onHoverChange: controller.setHoverBPJS,
                onPressedChange: controller.setPressedBPJS,
                onTap: () => Get.to(() => const InfoBpjsView()),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isHover,
    required bool isPressed,
    required Function(bool) onHoverChange,
    required Function(bool) onPressedChange,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => onPressedChange(true),
        onTapUp: (_) => onPressedChange(false),
        onTapCancel: () => onPressedChange(false),
        onTap: onTap,
        child: Transform.scale(
          scale: isPressed ? 0.95 : (isHover ? 1.02 : 1.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHover
                    ? [const Color(0xFF00959F), const Color(0xFF5FD8D1)]
                    : [const Color(0xFF02B1BA), const Color(0xFF84F3EE)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isHover
                      ? const Color(0xFF02B1BA).withOpacity(0.6)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isHover ? 16 : 4,
                  offset: Offset(0, isHover ? 6 : 2),
                ),
              ],
            ),
            child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isHover ? 0.5 : 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
