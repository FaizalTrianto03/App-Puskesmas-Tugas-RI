import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/notifikasi_list_controller.dart';
import 'detail_notifikasi_view.dart';

class NotifikasiListView extends GetView<NotifikasiListController> {
  NotifikasiListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(NotifikasiListController());
    return _buildScaffold(context);
  }

  final List<String> filterOptions = [
    'Semua',
    'Pengingat Obat',
    'Jadwal Kontrol',
    'Info Puskesmas',
  ];

  IconData _getIconForType(String type) {
    if (type.contains('Obat')) return Icons.medication;
    if (type.contains('Kontrol') || type.contains('Jadwal')) return Icons.event_note;
    if (type.contains('Info')) return Icons.info;
    return Icons.notifications;
  }

  Color _getColorForType(String type) {
    if (type.contains('Obat')) return const Color(0xFFFF4242);
    if (type.contains('Kontrol') || type.contains('Jadwal')) return const Color(0xFF4CAF50);
    if (type.contains('Info')) return const Color(0xFF02B1BA);
    return const Color(0xFF02B1BA);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Obx(() {
      final notifList = controller.filteredNotifikasi;

      return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.unreadCount.value;
            if (unreadCount > 0) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4242),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filter = entry.value;
                    return Obx(() {
                      final isSelected = controller.selectedFilter.value == filter;
                      final isHovered = controller.hoveredFilterIndex.value == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) {
                            controller.setHoveredFilterIndex(index);
                          },
                          onExit: (_) {
                            controller.setHoveredFilterIndex(null);
                          },
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              controller.setSelectedFilter(filter);
                            },
                          backgroundColor: isHovered ? const Color(0xFFE0E0E0) : Colors.white,
                          selectedColor: isSelected 
                              ? (isHovered ? const Color(0xFF00959F) : const Color(0xFF02B1BA).withOpacity(0.2))
                              : (isHovered ? const Color(0xFFE0E0E0) : Colors.white),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF02B1BA)
                                : const Color(0xFF64748B),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF02B1BA)
                                : (isHovered ? Colors.grey.shade400 : const Color(0xFFE2E8F0)),
                            width: isHovered ? 1.5 : 1,
                          ),
                        ),
                      ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ),

            Expanded(
              child: notifList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada notifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifList.length,
                      itemBuilder: (context, index) {
                        final notif = notifList[index];
                        return _buildNotificationCard(notif, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      );
    });
  }

  Widget _buildNotificationCard(notif, int index) {
    final icon = _getIconForType(notif.type);
    final color = _getColorForType(notif.type);
    final timeAgo = _getTimeAgo(notif.createdAt);
    
    return Obx(() {
      final isHovered = controller.hoveredIndex.value == index;
      final isPressed = controller.pressedIndex.value == index;
      
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          controller.setHoveredIndex(index);
        },
        onExit: (_) {
          controller.setHoveredIndex(null);
        },
        child: GestureDetector(
          onTapDown: (_) {
            controller.setPressedIndex(index);
          },
          onTapUp: (_) {
            controller.setPressedIndex(null);
          },
          onTapCancel: () {
            controller.setPressedIndex(null);
          },
          onTap: () {
            if (!notif.isRead) {
              controller.markAsRead(notif.id!);
            }
            Get.to(() => const DetailNotifikasiView(), arguments: notif);
          },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPressed
                ? (notif.isRead ? const Color(0xFFF0F0F0) : const Color(0xFF84F3EE).withOpacity(0.4))
                : (isHovered 
                    ? (notif.isRead ? const Color(0xFFE0E0E0) : const Color(0xFF84F3EE).withOpacity(0.35))
                    : (notif.isRead ? Colors.white : const Color(0xFF84F3EE).withOpacity(0.15))),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPressed
                  ? (notif.isRead ? Colors.grey.shade300 : const Color(0xFF02B1BA).withOpacity(0.7))
                  : (isHovered
                      ? (notif.isRead ? Colors.grey.shade300 : const Color(0xFF02B1BA).withOpacity(0.6))
                      : (notif.isRead
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF02B1BA).withOpacity(0.5))),
              width: (isPressed || isHovered) ? 2 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF02B1BA),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notif.type,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      );
    });
  }
}
