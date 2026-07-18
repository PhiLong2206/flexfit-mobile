import 'package:flutter/material.dart';

import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const _cardColor = Color(0xFF111827);
  static const _primaryOrange = Color(0xFFFF6B16);
  static const _textSecondary = Color(0xFF9CA3AF);

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final accentColor = isUnread ? _primaryOrange : _textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? _cardColor : _cardColor.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? _primaryOrange.withValues(alpha: 0.36)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isUnread ? 0.16 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconFor(notification.type), color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: _primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: isUnread ? 0.78 : 0.52,
                        ),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaPill(
                          label: _typeLabel(notification.type),
                          color: accentColor,
                        ),
                        Text(
                          _relativeTime(notification.createdAt),
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

  static IconData _iconFor(String? type) {
    final value = type?.toLowerCase() ?? '';
    if (value.contains('booking') || value.contains('reminder')) {
      return Icons.calendar_month_rounded;
    }
    if (value.contains('payment')) {
      return Icons.payments_rounded;
    }
    if (value.contains('promotion') || value.contains('promo')) {
      return Icons.local_offer_rounded;
    }
    if (value.contains('system')) {
      return Icons.settings_suggest_rounded;
    }
    return Icons.notifications_rounded;
  }

  static String _typeLabel(String? type) {
    final value = type?.trim();
    if (value == null || value.isEmpty) {
      return 'System';
    }
    return value;
  }

  static String _relativeTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
