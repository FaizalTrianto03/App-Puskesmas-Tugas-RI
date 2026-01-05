import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/notification/user_notification_service.dart';
import 'notification_page.dart';

/// A reusable notification bell button with badge for AppBar
/// Now uses unified user_notifications collection
/// Works for all roles - just import and use in any dashboard
class NotificationButton extends StatelessWidget {
  final Color iconColor;
  final Color badgeColor;
  final double iconSize;

  const NotificationButton({
    super.key,
    this.iconColor = const Color(0xFF02B1BA),
    this.badgeColor = const Color(0xFFFF4242),
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: UserNotificationService.to.watchUnreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0 
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: () => _openNotificationPage(),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
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
      },
    );
  }

  void _openNotificationPage() {
    Get.to(
      () => const NotificationPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
