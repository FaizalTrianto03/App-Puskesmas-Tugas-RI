import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../layanan_lainnya/views/layanan_lainnya_view.dart';
import '../../pendaftaran/views/pasien_pendaftaran_view.dart';
import '../../riwayat/views/riwayat_kunjungan_view.dart';
import '../controllers/pasien_dashboard_controller.dart';

class PasienDashboardView extends GetView<PasienDashboardController> {
  const PasienDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Dashboard Pasien',
            style: TextStyle(
              color: Color(0xFF02B1BA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF02B1BA),
                    size: 28,
                  ),
                  onPressed: () => Get.toNamed(Routes.pasienNotifikasi),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Obx(() {
                    if (controller.unreadNotificationCount.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          controller.unreadNotificationCount.value > 99 
                            ? '99+' 
                            : controller.unreadNotificationCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: QuarterCircleBackground(
                child: RefreshIndicator(
                  onRefresh: controller.refreshData,
                  color: const Color(0xFF02B1BA),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(context),
                      const SizedBox(height: 16),
                      Obx(
                        () {
                          print('[DashboardView] Building queue card: isLoading=${controller.isLoading.value}, hasActiveQueue=${controller.hasActiveQueue.value}, queueNumber="${controller.queueNumber.value}"');
                          if (controller.isLoading.value) {
                            return _buildQueueLoadingSkeleton(context);
                          }
                          return controller.hasActiveQueue.value
                              ? _buildActiveQueueCard(context)
                              : _buildNoActiveQueueCard(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () {
                          if (controller.isLoading.value) {
                            return _buildMenuLoadingSkeleton(context);
                          }
                          if (controller.hasActiveQueue.value) {
                            return const SizedBox.shrink();
                          }
                          return _buildMenuButton(
                            context,
                            icon: Icons.add_circle_outline,
                            title: 'Daftar Baru',
                            isHover: controller.isHoverDaftarBaru.value,
                            isPressed: controller.isPressedDaftarBaru.value,
                            onHoverChange: (hover) =>
                                controller.isHoverDaftarBaru.value = hover,
                            onPressedChange: (pressed) =>
                                controller.isPressedDaftarBaru.value =
                                    pressed,
                            onTap: () async {
                              final result = await Get.toNamed(
                                Routes.pasienPendaftaran,
                              );
                              if (result == true) {
                                controller.checkActiveQueue();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildMenuButton(
                          context,
                          icon: Icons.receipt_long,
                          title: 'Status Antrean',
                          isHover: controller.isHoverStatusAntrean.value,
                          isPressed: controller.isPressedStatusAntrean.value,
                          onHoverChange:
                              (hover) =>
                                  controller.isHoverStatusAntrean.value = hover,
                          onPressedChange:
                              (pressed) =>
                                  controller.isPressedStatusAntrean.value =
                                      pressed,
                          onTap: () async {
                            final result = await Get.toNamed(
                              Routes.pasienStatusAntrean,
                            );
                            if (result == true) {
                              controller.checkActiveQueue();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildMenuButton(
                          context,
                          icon: Icons.history,
                          title: 'Riwayat Kunjungan',
                          isHover: controller.isHoverRiwayat.value,
                          isPressed: controller.isPressedRiwayat.value,
                          onHoverChange:
                              (hover) =>
                                  controller.isHoverRiwayat.value = hover,
                          onPressedChange:
                              (pressed) =>
                                  controller.isPressedRiwayat.value = pressed,
                          onTap:
                              () => Get.to(() => const RiwayatKunjunganView()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildMenuButton(
                          context,
                          icon: Icons.apps,
                          title: 'Layanan Lainnya',
                          isHover: controller.isHoverLayananLain.value,
                          isPressed: controller.isPressedLayananLain.value,
                          onHoverChange:
                              (hover) =>
                                  controller.isHoverLayananLain.value = hover,
                          onPressedChange:
                              (pressed) =>
                                  controller.isPressedLayananLain.value =
                                      pressed,
                          onTap: () => Get.to(() => const LayananLainnyaView()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Obx(
      () => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => controller.isHoverProfileCard.value = true,
        onExit: (_) => controller.isHoverProfileCard.value = false,
        child: GestureDetector(
          onTapDown: (_) => controller.isPressedProfileCard.value = true,
          onTapUp: (_) => controller.isPressedProfileCard.value = false,
          onTapCancel: () => controller.isPressedProfileCard.value = false,
          onTap: () => Get.toNamed(Routes.pasienProfile),
          child: Transform.scale(
            scale:
                controller.isPressedProfileCard.value
                    ? 0.95
                    : (controller.isHoverProfileCard.value ? 1.02 : 1.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      controller.isHoverProfileCard.value
                          ? [const Color(0xFF007880), const Color(0xFF00A09A)]
                          : [const Color(0xFF02B1BA), const Color(0xFF84F3EE)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        controller.isHoverProfileCard.value
                            ? const Color(0xFF02B1BA).withOpacity(0.6)
                            : Colors.black.withOpacity(0.1),
                    blurRadius: controller.isHoverProfileCard.value ? 16 : 4,
                    offset: Offset(
                      0,
                      controller.isHoverProfileCard.value ? 6 : 2,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFF02B1BA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.userName.value.isEmpty 
                            ? 'Memuat...' 
                            : controller.userName.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQueueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF7DE8E3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Antrean Aktif',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Obx(
                    () {
                      print('[DashboardView] Building queueNumber: "${controller.queueNumber.value}"');
                      return Text(
                        controller.queueNumber.value.isEmpty 
                            ? '...' 
                            : controller.queueNumber.value,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4242),
                          letterSpacing: 4,
                          height: 1,
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      () => Get.toNamed(Routes.pasienStatusAntrean),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB547),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'DETAIL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 12),
            Obx(
              () => Text(
                controller.jenisLayanan.value.isEmpty
                    ? 'Memuat...'
                    : '${controller.jenisLayanan.value} - Estimasi: ${controller.estimatedTime.value}',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveQueueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Belum ada antrean aktif saat ini.\nSilahkan daftar terlebih dahulu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Get.to(
                  () => const PasienPendaftaranView(),
                );
                if (result == true) {
                  controller.checkActiveQueue();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB547),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Daftar Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueLoadingSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuLoadingSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
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
                colors:
                    isHover
                        ? [const Color(0xFF007880), const Color(0xFF00A09A)]
                        : [const Color(0xFF02B1BA), const Color(0xFF84F3EE)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      isHover
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
                  child: Icon(icon, color: Colors.white, size: 28),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
