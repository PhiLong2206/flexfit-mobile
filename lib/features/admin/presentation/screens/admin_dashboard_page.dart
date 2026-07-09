import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/local_storage.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/admin_gyms_provider.dart';
import '../providers/admin_revenue_provider.dart';
import '../providers/admin_settings_provider.dart';
import '../providers/admin_users_provider.dart';
import '../providers/admin_utilities_provider.dart';
import '../widgets/admin_ui.dart';
import 'admin_approvals_page.dart';
import 'admin_gym_partners_page.dart';
import 'admin_overview_page.dart';
import 'admin_revenue_page.dart';
import 'admin_settings_page.dart';
import 'admin_users_page.dart';
import 'admin_utilities_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<AdminDashboardProvider>()..load(),
        ),
        ChangeNotifierProvider(create: (_) => sl<AdminUsersProvider>()..load()),
        ChangeNotifierProvider(create: (_) => sl<AdminGymsProvider>()..load()),
        ChangeNotifierProvider(
          create: (_) => sl<AdminUtilitiesProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<AdminRevenueProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<AdminSettingsProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ProfileProvider>()..fetchProfile(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final base = Theme.of(context);
          return Theme(
            data: base.copyWith(
              colorScheme: base.colorScheme.copyWith(
                primary: AdminColors.primary,
                secondary: AdminColors.info,
                surface: AdminColors.panel,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: const Color(0xFF04130A),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                  side: const BorderSide(color: AdminColors.border),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AdminColors.panel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AdminColors.panelAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AdminColors.primary),
                ),
              ),
            ),
            child: const _AdminShell(),
          );
        },
      ),
    );
  }
}

class _AdminShell extends StatefulWidget {
  const _AdminShell();

  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell> {
  static const _destinations = [
    _AdminDestination('Tổng quan', Icons.dashboard_rounded),
    _AdminDestination('Người dùng', Icons.people_alt_rounded),
    _AdminDestination('Đối tác Gym', Icons.business_rounded),
    _AdminDestination('Tiện ích', Icons.extension_rounded),
    _AdminDestination('Doanh thu', Icons.payments_rounded),
    _AdminDestination('Phê duyệt', Icons.verified_user_rounded),
    _AdminDestination('Cài đặt hệ thống', Icons.settings_rounded),
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
            child: const Text('Hủy'),
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
          const AdminOverviewPage(),
          const AdminUsersPage(),
          const AdminGymPartnersPage(),
          const AdminUtilitiesPage(),
          const AdminRevenuePage(),
          const AdminApprovalsPage(),
          AdminSettingsPage(onLogout: _logout),
        ];
        final navigation = _AdminNavigation(
          selectedIndex: _selectedIndex,
          onSelect: (index) => _select(index, closeDrawer: !useSidebar),
          onLogout: _logout,
        );

        return Scaffold(
          backgroundColor: AdminColors.background,
          appBar: useSidebar
              ? null
              : AppBar(
                  title: Text(_destinations[_selectedIndex].label),
                  backgroundColor: AdminColors.sidebar,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                ),
          drawer: useSidebar
              ? null
              : Drawer(backgroundColor: AdminColors.sidebar, child: navigation),
          body: SafeArea(
            top: useSidebar,
            child: Row(
              children: [
                if (useSidebar) SizedBox(width: 288, child: navigation),
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

class _AdminNavigation extends StatelessWidget {
  const _AdminNavigation({
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminColors.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AdminColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFF04130A),
                      ),
                    ),
                  ),
                  SizedBox(width: 13),
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
                        'ADMIN PORTAL',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.3,
                          color: AdminColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                itemCount: _AdminShellState._destinations.length,
                itemBuilder: (context, index) {
                  final item = _AdminShellState._destinations[index];
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: ListTile(
                      minLeadingWidth: 28,
                      minVerticalPadding: 13,
                      selected: selected,
                      selectedColor: Colors.white,
                      textColor: AdminColors.muted,
                      iconColor: selected
                          ? AdminColors.primary
                          : AdminColors.subtle,
                      selectedTileColor: const Color(0xFF10251B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: ListTile(
                minLeadingWidth: 28,
                textColor: AdminColors.danger,
                iconColor: AdminColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout_rounded),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.w800),
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

class _AdminDestination {
  const _AdminDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
