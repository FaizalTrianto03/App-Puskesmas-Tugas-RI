import 'package:flutter/material.dart';

import '../../data/models/user_notification_model.dart';
import '../../data/services/notification/user_notification_service.dart';

/// Main notification page with tabs for Unread/Read notifications
/// Now uses unified user_notifications collection - 1 document per user
/// All notifications are stored in single document, no more miss notifications
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF02B1BA),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF02B1BA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF02B1BA),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            onSelected: (value) async {
              if (value == 'read_all') {
                await _markAllAsRead();
              } else if (value == 'delete_all') {
                await _showDeleteAllConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Color(0xFF02B1BA), size: 20),
                    SizedBox(width: 12),
                    Text('Tandai semua dibaca'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Hapus semua', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF02B1BA),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF02B1BA),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                StreamBuilder<int>(
                  stream: UserNotificationService.to.watchUnreadCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Belum Dibaca'),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4242),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const Tab(text: 'Sudah Dibaca'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(isRead: false),
          _buildNotificationList(isRead: true),
        ],
      ),
    );
  }

  Widget _buildNotificationList({required bool isRead}) {
    return StreamBuilder<UserNotificationModel?>(
      stream: UserNotificationService.to.watchUserNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF02B1BA),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat notifikasi',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final userNotif = snapshot.data;
        if (userNotif == null) {
          return _buildEmptyState(isRead);
        }

        // Get filtered notifications based on isRead status
        final filteredNotifications = isRead
            ? userNotif.readNotifications
            : userNotif.unreadNotifications;

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState(isRead);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: const Color(0xFF02B1BA),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredNotifications.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _NotificationItemTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () => _deleteNotification(notification),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isRead) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRead ? Icons.mark_email_read_outlined : Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isRead
                ? 'Tidak ada notifikasi yang sudah dibaca'
                : 'Tidak ada notifikasi baru',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRead
                ? 'Notifikasi yang sudah Anda baca akan muncul di sini'
                : 'Notifikasi baru akan muncul di sini',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read if not already
    if (!notification.isRead) {
      UserNotificationService.to.markAsRead(notification.id);
    }
    
    // Show detail modal
    _showDetailModal(notification);
  }

  void _showDetailModal(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationDetailModal(notification: notification),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await UserNotificationService.to.markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi ditandai sudah dibaca'),
            backgroundColor: Color(0xFF02B1BA),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menandai notifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAllConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text(
          'Semua notifikasi akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteAllNotifications();
    }
  }

  Future<void> _deleteAllNotifications() async {
    try {
      await UserNotificationService.to.deleteAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi telah dihapus'),
            backgroundColor: Color(0xFF02B1BA),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus notifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      await UserNotificationService.to.deleteNotification(notification.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus notifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// A single notification item tile
class _NotificationItemTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const _NotificationItemTile({
    required this.notification,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: onDismiss != null 
          ? DismissDirection.endToStart 
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : const Color(0xFF02B1BA).withOpacity(0.05),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with type color
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
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
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
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

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'antrian':
      case 'antrian_verified':
      case 'antrian_called':
      case 'antrian_created':
      case 'new_patient':
        return Icons.confirmation_number_outlined;
      case 'antrian_cancelled':
      case 'dibatalkan':
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
      case 'status_update':
        return Icons.medical_services_outlined;
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
      case 'medicine_ready':
        return Icons.medication_outlined;
      case 'stok':
      case 'stock_alert':
      case 'stok_menipis':
        return Icons.inventory_2_outlined;
      case 'info':
      case 'pengumuman':
        return Icons.info_outline;
      case 'warning':
      case 'peringatan':
        return Icons.warning_amber_outlined;
      case 'jadwal':
      case 'reminder':
        return Icons.schedule_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'antrian':
      case 'antrian_verified':
      case 'antrian_called':
      case 'antrian_created':
      case 'new_patient':
        return const Color(0xFF02B1BA);
      case 'antrian_cancelled':
      case 'dibatalkan':
      case 'cancelled':
        return const Color(0xFFFF4242);
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
      case 'status_update':
        return const Color(0xFF4CAF50);
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
      case 'medicine_ready':
        return const Color(0xFF9C27B0);
      case 'stok':
      case 'stock_alert':
      case 'stok_menipis':
        return const Color(0xFFFFA726);
      case 'warning':
      case 'peringatan':
        return const Color(0xFFFF4242);
      case 'info':
      case 'pengumuman':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF02B1BA);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Detail modal shown when notification is tapped
class _NotificationDetailModal extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationDetailModal({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(notification.type),
                        color: _getTypeColor(notification.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTypeLabel(notification.type),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getTypeColor(notification.type),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      // Show metadata if available
                      if (notification.data != null && notification.data!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildMetadataSection(notification.data!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic> data) {
    final items = <Widget>[];
    
    // Common metadata fields to display
    final displayFields = {
      'nomorAntrian': 'Nomor Antrian',
      'namaLengkap': 'Nama Pasien',
      'status': 'Status',
      'keluhan': 'Keluhan',
      'namaObat': 'Nama Obat',
      'stokSaatIni': 'Stok Saat Ini',
    };
    
    for (final entry in displayFields.entries) {
      if (data.containsKey(entry.key) && data[entry.key] != null) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    data[entry.key].toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'antrian':
      case 'antrian_verified':
      case 'antrian_called':
      case 'antrian_created':
      case 'new_patient':
        return Icons.confirmation_number_outlined;
      case 'antrian_cancelled':
      case 'dibatalkan':
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
      case 'status_update':
        return Icons.medical_services_outlined;
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
      case 'medicine_ready':
        return Icons.medication_outlined;
      case 'stok':
      case 'stock_alert':
      case 'stok_menipis':
        return Icons.inventory_2_outlined;
      case 'info':
      case 'pengumuman':
        return Icons.info_outline;
      case 'warning':
      case 'peringatan':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'antrian':
      case 'antrian_verified':
      case 'antrian_called':
      case 'antrian_created':
      case 'new_patient':
        return const Color(0xFF02B1BA);
      case 'antrian_cancelled':
      case 'dibatalkan':
      case 'cancelled':
        return const Color(0xFFFF4242);
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
      case 'status_update':
        return const Color(0xFF4CAF50);
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
      case 'medicine_ready':
        return const Color(0xFF9C27B0);
      case 'stok':
      case 'stock_alert':
      case 'stok_menipis':
        return const Color(0xFFFFA726);
      case 'warning':
      case 'peringatan':
        return const Color(0xFFFF4242);
      case 'info':
      case 'pengumuman':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF02B1BA);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'antrian':
      case 'antrian_verified':
      case 'antrian_called':
      case 'antrian_created':
      case 'new_patient':
        return 'ANTRIAN';
      case 'antrian_cancelled':
      case 'dibatalkan':
      case 'cancelled':
        return 'PEMBATALAN';
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
      case 'status_update':
        return 'PEMERIKSAAN';
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
      case 'medicine_ready':
        return 'OBAT';
      case 'stok':
      case 'stock_alert':
      case 'stok_menipis':
        return 'STOK';
      case 'warning':
      case 'peringatan':
        return 'PERINGATAN';
      case 'info':
      case 'pengumuman':
        return 'INFORMASI';
      default:
        return type.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (notifDate == today) {
      dateStr = 'Hari ini';
    } else if (notifDate == yesterday) {
      dateStr = 'Kemarin';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr, $hour:$minute';
  }
}
