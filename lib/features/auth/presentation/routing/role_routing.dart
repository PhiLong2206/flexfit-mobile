import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../admin/presentation/screens/admin_dashboard_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../partner/presentation/providers/partner_provider.dart';
import '../../../partner/presentation/screens/partner_shell_page.dart';
import '../../../staff/presentation/screens/staff_dashboard_page.dart';
import '../screens/unknown_role_page.dart';

enum AppRole { admin, gymPartner, staff, member, unknown }

class RoleRouting {
  const RoleRouting._();

  static AppRole resolve(Iterable<String> roles) {
    final normalized = roles.map((role) => role.trim().toLowerCase()).toSet();
    if (normalized.contains('admin')) return AppRole.admin;
    if (normalized.contains('gympartner')) return AppRole.gymPartner;
    if (normalized.contains('staff')) return AppRole.staff;
    if (normalized.contains('member')) return AppRole.member;
    return AppRole.unknown;
  }

  static Widget pageFor(Iterable<String> roles) {
    switch (resolve(roles)) {
      case AppRole.admin:
        return const AdminDashboardPage();
      case AppRole.gymPartner:
        return ChangeNotifierProvider(
          create: (_) => sl<PartnerProvider>(),
          child: const PartnerShellPage(),
        );
      case AppRole.staff:
        return const StaffDashboardPage();
      case AppRole.member:
        return const HomePage();
      case AppRole.unknown:
        return const UnknownRolePage();
    }
  }

  static String targetName(Iterable<String> roles) {
    switch (resolve(roles)) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.gymPartner:
        return 'GymPartner';
      case AppRole.staff:
        return 'Staff';
      case AppRole.member:
        return 'Member';
      case AppRole.unknown:
        return 'Unknown';
    }
  }
}
