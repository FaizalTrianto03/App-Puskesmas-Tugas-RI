import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';

class DokterNotifikasiListView extends StatefulWidget {
  const DokterNotifikasiListView({Key? key}) : super(key: key);

  @override
  State<DokterNotifikasiListView> createState() => _DokterNotifikasiListViewState();
}

class _DokterNotifikasiListViewState extends State<DokterNotifikasiListView> {
  String selectedFilter = 'Semua';
  int? _hoveredIndex;
  int? _pressedIndex;
  int? _hoveredFilterIndex;

  final List<String> filterOptions = [
    'Semua',
    'Antrian',
    'Rekam Medis',
    'Resep',
  ];

  final List<Map<String, dynamic>> allNotifications = [
    {
      'id': 1,
      'type': 'Antrian',
      'title': 'Pasien Baru Menunggu',
      'message': 'Budi Santoso (NIK: 3527011234567890) sudah check-in dan menunggu pemeriksaan.',
      'time': '5 menit yang lalu',
      'isRead': false,
      'icon': Icons.people,
      'color': const Color(0xFF02B1BA),
    },
    {
      'id': 2,
      'type': 'Rekam Medis',
      'title': 'Rekam Medis Perlu Dilengkapi',
      'message': 'Rekam medis Siti Aminah belum lengkap. Harap melengkapi diagnosis dan resep.',
      'time': '1 jam yang lalu',
      'isRead': false,
      'icon': Icons.description,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 4,
      'type': 'Resep',
      'title': 'Resep Telah Diambil',
      'message': 'Resep obat Ahmad Hidayat telah diambil di farmasi pukul 13:30.',
      'time': '2 jam yang lalu',
      'isRead': true,
      'icon': Icons.medication,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 5,
      'type': 'Antrian',
      'title': 'Total Antrian Hari Ini',
      'message': 'Anda memiliki 12 pasien dalam antrian hari ini.',
      'time': '1 hari yang lalu',
      'isRead': true,
      'icon': Icons.people,
      'color': const Color(0xFF02B1BA),
    },
    {
      'id': 6,
      'type': 'Rekam Medis',
      'title': 'Update Rekam Medis',
      'message': '5 rekam medis pasien telah diupdate hari ini.',
      'time': '1 hari yang lalu',
      'isRead': true,
      'icon': Icons.description,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 8,
      'type': 'Resep',
      'title': 'Reminder: Cek Resep',
      'message': '2 resep menunggu verifikasi Anda.',
      'time': '3 hari yang lalu',
      'isRead': true,
      'icon': Icons.medication,
      'color': const Color(0xFF9C27B0),
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'Semua') {
      return allNotifications;
    }
    return allNotifications
        .where((notif) => notif['type'] == selectedFilter)
        .toList();
  }

  int get unreadCount {
    return allNotifications.where((notif) => !notif['isRead']).length;
  }

  @override
  Widget build(BuildContext context) {
    final notifList = filteredNotifications;

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
          'Notifikasi Dokter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount baru',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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
                    final isSelected = selectedFilter == filter;
                    final isHovered = _hoveredFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) {
                          setState(() {
                            _hoveredFilterIndex = index;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _hoveredFilterIndex = null;
                          });
                        },
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
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
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    final isHovered = _hoveredIndex == index;
    final isPressed = _pressedIndex == index;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = null;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _pressedIndex = index;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressedIndex = null;
            notif['isRead'] = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressedIndex = null;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPressed
                ? (notif['isRead'] ? const Color(0xFFF0F0F0) : const Color(0xFF84F3EE).withOpacity(0.4))
                : (isHovered 
                    ? (notif['isRead'] ? const Color(0xFFE0E0E0) : const Color(0xFF84F3EE).withOpacity(0.35))
                    : (notif['isRead'] ? Colors.white : const Color(0xFF84F3EE).withOpacity(0.15))),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPressed
                  ? (notif['isRead'] ? Colors.grey.shade300 : const Color(0xFF02B1BA).withOpacity(0.7))
                  : (isHovered
                      ? (notif['isRead'] ? Colors.grey.shade300 : const Color(0xFF02B1BA).withOpacity(0.6))
                      : (notif['isRead']
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
                  color: (notif['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notif['icon'],
                  color: notif['color'],
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
                            notif['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notif['isRead']
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (!notif['isRead'])
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
                      notif['message'],
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
                          notif['time'],
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
                            color: (notif['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notif['type'],
                            style: TextStyle(
                              fontSize: 11,
                              color: notif['color'],
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
  }
}
