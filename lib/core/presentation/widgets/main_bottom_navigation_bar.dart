import 'package:flutter/material.dart';

import '../../../features/home/presentation/screens/home_page.dart';
import '../../../features/home/presentation/screens/overview_page.dart';
import '../../../features/gym/presentation/screens/explore_page.dart';
import '../../../features/booking/presentation/screens/my_bookings_page.dart';
import '../../../features/membership/presentation/screens/membership_page.dart';
import '../../../features/profile/presentation/screens/profile_page.dart';

class MainBottomNavigationBar extends StatelessWidget {
  const MainBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;
  static const Color _cardColor = Color(0xFF111827);

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const OverviewPage();
        break;
      case 2:
        page = const ExplorePage();
        break;
      case 3:
        page = const MyBookingsPage();
        break;
      case 4:
        page = const MembershipPage();
        break;
      case 5:
        page = const ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: _cardColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If screen is very narrow, we might need to hide labels to avoid overflow
            final bool isSmallScreen = constraints.maxWidth < 360;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Trang chủ',
                  isActive: currentIndex == 0,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 0),
                ),
                _BottomNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Tổng quan',
                  isActive: currentIndex == 1,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 1),
                ),
                _BottomNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Khám phá',
                  isActive: currentIndex == 2,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 2),
                ),
                _BottomNavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Đặt lịch',
                  isActive: currentIndex == 3,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 3),
                ),
                _BottomNavItem(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Thành viên',
                  isActive: currentIndex == 4,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 4),
                ),
                _BottomNavItem(
                  icon: Icons.person_rounded,
                  label: 'Hồ sơ',
                  isActive: currentIndex == 5,
                  showLabel: !isSmallScreen,
                  onTap: () => _onTabTapped(context, 5),
                ),
              ],
            );
          },
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
    this.showLabel = true,
    this.onTap,
  });

  static const Color _primaryOrange = Color(0xFFFF6B16);

  final IconData icon;
  final String label;
  final bool isActive;
  final bool showLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _primaryOrange : Colors.white54;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 28,
              width: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? _primaryOrange.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
