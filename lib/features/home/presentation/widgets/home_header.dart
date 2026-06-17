import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/data/profile_notifier.dart';
import '../../../profile/presentation/pages/profile_page.dart';

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
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              alignment: Alignment.center,
              child: Text(
                context.watch<ProfileNotifier>().profile.initials,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  static const Color _cardColor = Color(0xFF111827);

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
