import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../widgets/notification/notification_button.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../layanan_lainnya/views/layanan_lainnya_view.dart';
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
          elevation: 0,
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
            const NotificationButton(),
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
                        Obx(() {
                          if (controller.isLoading.value) {
                            return _buildQueueLoadingSkeleton(context);
                          }
                          return controller.hasActiveQueue.value
                              ? _buildActiveQueuePreview(context)
                              : _buildNoActiveQueueCard(context);
                        }),
                        const SizedBox(height: 16),
                        Obx(() {
                          final hasQueue = controller.hasActiveQueue.value;
                          return _buildMenuButton(
                            context,
                            icon: Icons.add_circle_outline,
                            title: 'Daftar Baru',
                            isHover:
                                hasQueue
                                    ? false
                                    : controller.isHoverDaftarBaru.value,
                            isPressed:
                                hasQueue
                                    ? false
                                    : controller.isPressedDaftarBaru.value,
                            isDisabled: hasQueue,
                            onHoverChange:
                                hasQueue
                                    ? null
                                    : (hover) =>
                                        controller.isHoverDaftarBaru.value =
                                            hover,
                            onPressedChange:
                                hasQueue
                                    ? null
                                    : (pressed) =>
                                        controller.isPressedDaftarBaru.value =
                                            pressed,
                            onTap: () async {
                              if (hasQueue) {
                                controller.showActiveQueueWarning();
                                return;
                              }
                              final result = await Get.toNamed(
                                Routes.pasienPendaftaran,
                              );
                              if (result == true) {
                                controller.checkActiveQueue();
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasQueue = controller.hasActiveQueue.value;
                          return _buildMenuButton(
                            context,
                            icon: Icons.receipt_long,
                            title: 'Status Antrean',
                            isHover:
                                hasQueue
                                    ? controller.isHoverStatusAntrean.value
                                    : false,
                            isPressed:
                                hasQueue
                                    ? controller.isPressedStatusAntrean.value
                                    : false,
                            isDisabled: !hasQueue,
                            onHoverChange:
                                hasQueue
                                    ? (hover) =>
                                        controller.isHoverStatusAntrean.value =
                                            hover
                                    : null,
                            onPressedChange:
                                hasQueue
                                    ? (pressed) =>
                                        controller
                                            .isPressedStatusAntrean
                                            .value = pressed
                                    : null,
                            onTap: () async {
                              if (!hasQueue) {
                                Get.snackbar(
                                  'Belum Ada Antrian',
                                  'Silakan daftar terlebih dahulu untuk melihat status antrian',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.orange.withOpacity(
                                    0.9,
                                  ),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 8,
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                );
                                return;
                              }
                              final result = await Get.toNamed(
                                Routes.pasienStatusAntrean,
                              );
                              if (result == true) {
                                controller.checkActiveQueue();
                              }
                            },
                          );
                        }),
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
                                () =>
                                    Get.to(() => const RiwayatKunjunganView()),
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
                            onTap:
                                () => Get.to(() => const LayananLainnyaView()),
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
                    child: Obx(
                      () => Column(
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
                      ),
                    ),
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

  Widget _buildActiveQueuePreview(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.pasienStatusAntrean),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF02B1BA), Color(0xFF4DD4DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02B1BA).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.pasienStatusAntrean),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB547),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'DETAIL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Queue Number - Centered dan lebih menonjol
          Center(
            child: Obx(
              () => Text(
                controller.queueNumber.value.isEmpty
                    ? '...'
                    : controller.queueNumber.value,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4242),
                  letterSpacing: 4,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Current Timeline Preview - Mini spoiler
          Obx(() {
            final description = controller.currentTimelineDescription.value;
            final stage = controller.currentTimelineStage.value;

            // Icon untuk setiap stage
            IconData stageIcon;
            switch (stage) {
              case 'perawat':
                stageIcon = Icons.health_and_safety_outlined;
                break;
              case 'dokter':
                stageIcon = Icons.medical_services_outlined;
                break;
              case 'apoteker':
                stageIcon = Icons.medication_outlined;
                break;
              case 'pembayaran':
                stageIcon = Icons.payment_outlined;
                break;
              case 'pending':
                stageIcon = Icons.hourglass_empty;
                break;
              case 'dilewati':
                stageIcon = Icons.skip_next_outlined;
                break;
              case 'dipanggil':
                stageIcon = Icons.notifications_active_outlined;
                break;
              default:
                stageIcon = Icons.pending_outlined;
            }

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stageIcon, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description.isNotEmpty
                              ? description
                              : 'Memuat status...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.jenisLayanan.value,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow untuk lihat detail
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            );
          }),
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
                final result = await Get.toNamed(Routes.pasienPendaftaran);
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

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isHover,
    required bool isPressed,
    Function(bool)? onHoverChange,
    Function(bool)? onPressedChange,
    bool isDisabled = false,
  }) {
    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: isDisabled ? null : (_) => onHoverChange?.call(true),
      onExit: isDisabled ? null : (_) => onHoverChange?.call(false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => onPressedChange?.call(true),
        onTapUp: isDisabled ? null : (_) => onPressedChange?.call(false),
        onTapCancel: isDisabled ? null : () => onPressedChange?.call(false),
        onTap: onTap,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Transform.scale(
            scale:
                isDisabled ? 1.0 : (isPressed ? 0.95 : (isHover ? 1.02 : 1.0)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDisabled
                          ? [const Color(0xFFBDBDBD), const Color(0xFFE0E0E0)]
                          : (isHover
                              ? [
                                const Color(0xFF007880),
                                const Color(0xFF00A09A),
                              ]
                              : [
                                const Color(0xFF02B1BA),
                                const Color(0xFF84F3EE),
                              ]),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDisabled
                            ? Colors.black.withOpacity(0.05)
                            : (isHover
                                ? const Color(0xFF02B1BA).withOpacity(0.6)
                                : Colors.black.withOpacity(0.1)),
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
                  if (isDisabled)
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
