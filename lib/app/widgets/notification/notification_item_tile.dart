import 'package:flutter/material.dart';

import '../../data/models/notifikasi_model.dart';

/// A single notification item tile for the list
class NotificationItemTile extends StatelessWidget {
  final NotifikasiModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationItemTile({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id ?? DateTime.now().toString()),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeLabel(notification.type),
                            style: TextStyle(
                              color: _getTypeColor(notification.type),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade300,
                size: 20,
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
        return Icons.confirmation_number_outlined;
      case 'antrian_cancelled':
      case 'dibatalkan':
        return Icons.cancel_outlined;
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
        return Icons.medical_services_outlined;
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
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
        return const Color(0xFF02B1BA);
      case 'antrian_cancelled':
      case 'dibatalkan':
        return const Color(0xFFFF4242);
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
        return const Color(0xFF4CAF50);
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
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
        return 'ANTRIAN';
      case 'antrian_cancelled':
      case 'dibatalkan':
        return 'PEMBATALAN';
      case 'pemeriksaan':
      case 'pemeriksaan_selesai':
        return 'PEMERIKSAAN';
      case 'obat':
      case 'obat_siap':
      case 'siap_ambil_obat':
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
        return 'INFO';
      default:
        return type.toUpperCase();
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
