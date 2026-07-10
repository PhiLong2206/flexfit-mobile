import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/local_storage.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/staff_dashboard_provider.dart';
import 'staff_check_in_page.dart';
import 'staff_customers_page.dart';
import 'staff_overview_page.dart';
import 'staff_schedule_page.dart';
import 'staff_settings_page.dart';
import 'staff_support_page.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<StaffDashboardProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ProfileProvider>()..fetchProfile(),
        ),
      ],
      child: const _StaffShell(),
    );
  }
}

class _StaffShell extends StatefulWidget {
  const _StaffShell();

  @override
  State<_StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<_StaffShell> {
  static const _background = Color(0xFF070B14);
  static const _destinations = [
    _StaffDestination('Tổng quan', Icons.dashboard_rounded),
    _StaffDestination('Check-in khách hàng', Icons.qr_code_scanner_rounded),
    _StaffDestination('Lịch học & lớp học', Icons.calendar_month_rounded),
    _StaffDestination('Khách hàng', Icons.groups_rounded),
    _StaffDestination('Hỗ trợ & Đánh giá', Icons.reviews_rounded),
    _StaffDestination('Cài đặt', Icons.settings_rounded),
  ];
  int _selectedIndex = 0;

  void _select(int index, {bool closeDrawer = false}) {
    setState(() => _selectedIndex = index);
    if (closeDrawer) Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi FlexFit không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await LocalStorage.removeToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= 860;
        final pages = [
          StaffOverviewPage(onOpenCheckIn: () => _select(1)),
          const StaffCheckInPage(),
          const StaffSchedulePage(),
          const StaffCustomersPage(),
          const StaffSupportPage(),
          StaffSettingsPage(onLogout: _logout),
        ];
        final navigation = _StaffNavigation(
          selectedIndex: _selectedIndex,
          onSelect: (index) => _select(index, closeDrawer: !useSidebar),
          onLogout: _logout,
        );
        return Scaffold(
          backgroundColor: _background,
          appBar: useSidebar
              ? null
              : AppBar(
                  title: Text(_destinations[_selectedIndex].label),
                  backgroundColor: const Color(0xFF0B1220),
                ),
          drawer: useSidebar
              ? null
              : Drawer(
                  backgroundColor: const Color(0xFF0B1220),
                  child: navigation,
                ),
          body: SafeArea(
            top: useSidebar,
            child: Row(
              children: [
                if (useSidebar) SizedBox(width: 270, child: navigation),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StaffNavigation extends StatelessWidget {
  const _StaffNavigation({
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1220),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 22, 22, 16),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF22C55E),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FlexFit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'STAFF PORTAL',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.3,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: _StaffShellState._destinations.length,
                itemBuilder: (context, index) {
                  final item = _StaffShellState._destinations[index];
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ListTile(
                      selected: selected,
                      selectedColor: Colors.white,
                      textColor: const Color(0xFF94A3B8),
                      iconColor: selected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF64748B),
                      selectedTileColor: const Color(0xFF16251F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(item.icon),
                      title: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () => onSelect(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout_rounded),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffDestination {
  const _StaffDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
