import 'package:flutter/material.dart';

import '../../../notification/presentation/widgets/notification_bell_button.dart';
import '../../../ai/presentation/widgets/ai_coach_popup.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static const Color _primaryOrange = Color(0xFFFF6B16);
  static const Color _cardColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 72,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: _primaryOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryOrange.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'FF',
              style: textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'FLEXFIT',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.smart_toy_rounded, color: Color(0xFFFF6B16)),
            onPressed: () {
              AiCoachPopup.show(context);
            },
          ),
          const SizedBox(width: 4),
          const NotificationBellButton(),
          const SizedBox(width: 10),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            alignment: Alignment.center,
            child: Text(
              'DR',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
