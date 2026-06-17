import 'package:flutter/material.dart';

import '../widgets/category_section.dart';
import '../widgets/feature_section.dart';
import '../widgets/featured_gym_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_stats_row.dart';
import '../widgets/hero_banner.dart';
import '../../../booking/presentation/pages/my_bookings_page.dart';
import '../../../gym/presentation/pages/explore_page.dart';
import '../../../membership/presentation/pages/membership_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';
  static const Color _backgroundColor = Color(0xFF070B14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 16),
              const HeroBanner(),
              const SizedBox(height: 24),
              const HomeQuickStatsRow(),
              const SizedBox(height: 28),
              const FeatureSection(),
              const SizedBox(height: 28),
              const CategorySection(),
              const SizedBox(height: 28),
              const FeaturedGymSection(),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _HomeBottomNavigationBar(),
    );
  }
}

class _HomeBottomNavigationBar extends StatelessWidget {
  const _HomeBottomNavigationBar();

  static const Color _cardColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: _cardColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            const _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Trang chủ',
              isActive: true,
            ),
            _BottomNavItem(
              icon: Icons.explore_rounded,
              label: 'Khám phá',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExplorePage()),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Đặt lịch',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MyBookingsPage(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Thành viên',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MembershipPage(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Hồ sơ',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  static const Color _primaryOrange = Color(0xFFFF6B16);

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _primaryOrange : Colors.white54;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? _primaryOrange.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
