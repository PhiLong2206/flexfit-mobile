import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/notification_notifier.dart';
import '../../data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationNotifier>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<NotificationNotifier>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Thông Báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (notifier.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, color: AppColors.primary, size: 18),
              label: const Text(
                'Đọc tất cả',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _buildContent(notifier),
      ),
    );
  }

  Widget _buildContent(NotificationNotifier notifier) {
    if (notifier.isLoading && notifier.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (notifier.error != null && notifier.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.cancelled, size: 48),
              const SizedBox(height: 12),
              Text(
                'Lỗi: ${notifier.error}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => notifier.fetchNotifications(),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final list = notifier.notifications;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chưa có thông báo nào',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chúng tôi sẽ thông báo cho bạn khi có tin tức mới hoặc nhắc nhở lịch tập.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchNotifications(),
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          return _NotificationCard(
            notification: item,
            onTap: () => notifier.markAsRead(item.id),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  IconData _getIcon() {
    final t = notification.type?.toLowerCase() ?? '';
    if (t.contains('booking') || t.contains('schedule')) {
      return Icons.calendar_month_rounded;
    }
    if (t.contains('alert') || t.contains('warning')) {
      return Icons.warning_amber_rounded;
    }
    if (t.contains('promo') || t.contains('gift')) {
      return Icons.card_membership_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getIconBgColor() {
    final t = notification.type?.toLowerCase() ?? '';
    if (t.contains('booking') || t.contains('schedule')) {
      return Colors.blue.withValues(alpha: 0.12);
    }
    if (t.contains('alert') || t.contains('warning')) {
      return Colors.amber.withValues(alpha: 0.12);
    }
    if (t.contains('promo') || t.contains('gift')) {
      return Colors.purple.withValues(alpha: 0.12);
    }
    return AppColors.primary.withValues(alpha: 0.12);
  }

  Color _getIconColor() {
    final t = notification.type?.toLowerCase() ?? '';
    if (t.contains('booking') || t.contains('schedule')) {
      return Colors.blue;
    }
    if (t.contains('alert') || t.contains('warning')) {
      return Colors.amber;
    }
    if (t.contains('promo') || t.contains('gift')) {
      return Colors.purple;
    }
    return AppColors.primary;
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month lúc $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? Colors.white.withValues(alpha: 0.02)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: _getIconBgColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), color: _getIconColor(), size: 20),
            ),
            const SizedBox(width: 14),
            // Middle text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: unread ? FontWeight.w900 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.content,
                    style: TextStyle(
                      color: unread ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
