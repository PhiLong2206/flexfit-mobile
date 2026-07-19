import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key, this.useExistingProvider = false});

  final bool useExistingProvider;

  @override
  Widget build(BuildContext context) {
    if (useExistingProvider) {
      return const _NotificationView();
    }
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider()..loadNotifications(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  static const _backgroundColor = Color(0xFF070B14);
  static const _primaryOrange = Color(0xFFFF6B16);

  Future<void> _markAllAsRead(BuildContext context) async {
    try {
      await context.read<NotificationProvider>().markAllAsRead();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _markAsRead(BuildContext context, String id) async {
    try {
      await context.read<NotificationProvider>().markAsRead(id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: provider.unreadCount == 0
                ? null
                : () => _markAllAsRead(context),
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody(context, provider)),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryOrange),
      );
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return _StateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Không tải được thông báo',
        message: provider.errorMessage!,
        actionLabel: 'Thử lại',
        onAction: () =>
            context.read<NotificationProvider>().loadNotifications(force: true),
      );
    }

    if (provider.notifications.isEmpty) {
      return _StateMessage(
        icon: Icons.notifications_none_rounded,
        title: 'Chưa có thông báo',
        message: 'Các cập nhật về lịch tập, thanh toán và ưu đãi sẽ ở đây.',
        actionLabel: 'Làm mới',
        onAction: () =>
            context.read<NotificationProvider>().loadNotifications(force: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationProvider>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _markAsRead(context, notification.id),
          );
        },
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  static const _primaryOrange = Color(0xFFFF6B16);
  static const _textSecondary = Color(0xFF9CA3AF);

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primaryOrange, size: 42),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
