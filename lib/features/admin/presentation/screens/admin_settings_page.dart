import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/admin_settings_provider.dart';
import '../widgets/admin_ui.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<AuthProvider>(),
      child: _SettingsView(onLogout: onLogout),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final settingsProvider = context.watch<AdminSettingsProvider>();
    final profile = profileProvider.profile;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          profileProvider.fetchProfile(),
          settingsProvider.refresh(),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          const AdminPageHeader(
            title: 'Cài đặt hệ thống',
            subtitle: 'Thông tin tài khoản Admin và nhật ký hệ thống.',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final profileCard = AdminPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSectionTitle('Hồ sơ Admin', Icons.badge_rounded),
                    const SizedBox(height: 18),
                    if (profileProvider.isLoading && profile == null)
                      const AdminInlineLoadingState(rows: 3)
                    else if (profileProvider.error != null && profile == null)
                      Text(
                        profileProvider.error!,
                        style: const TextStyle(color: AdminColors.danger),
                      )
                    else ...[
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFF331D12),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AdminColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _InfoRow('Họ tên', profile?.fullName ?? ''),
                      _InfoRow('Email', profile?.email ?? ''),
                      _InfoRow('Số điện thoại', profile?.phoneNumber ?? ''),
                      const _InfoRow('Vai trò', 'Admin', isLast: true),
                    ],
                  ],
                ),
              );
              final securityCard = AdminPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AdminSectionTitle('Bảo mật', Icons.security_rounded),
                    const SizedBox(height: 10),
                    const Text(
                      'Quản lý mật khẩu và phiên đăng nhập.',
                      style: TextStyle(color: AdminColors.muted),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => _showChangePassword(context),
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: const Text('Đổi mật khẩu'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Đăng xuất'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.danger,
                      ),
                    ),
                  ],
                ),
              );
              if (constraints.maxWidth < 860) {
                return Column(
                  children: [
                    profileCard,
                    const SizedBox(height: 20),
                    securityCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: profileCard),
                  const SizedBox(width: 20),
                  Expanded(child: securityCard),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: AdminSectionTitle(
                        'Nhật ký hệ thống',
                        Icons.list_alt_rounded,
                      ),
                    ),
                    AdminStatusPill(
                      label:
                          '${settingsProvider.logsPage?.totalCount ?? 0} logs',
                      color: AdminColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (settingsProvider.isLoading &&
                    settingsProvider.logsPage == null)
                  const AdminInlineLoadingState(rows: 4)
                else if (settingsProvider.errorMessage != null &&
                    settingsProvider.logsPage == null)
                  Text(
                    settingsProvider.errorMessage!,
                    style: const TextStyle(color: AdminColors.danger),
                  )
                else if (settingsProvider.logsPage?.logs.isEmpty ?? true)
                  const Text(
                    'Chưa có nhật ký hệ thống.',
                    style: TextStyle(color: AdminColors.muted),
                  )
                else
                  ...settingsProvider.logsPage!.logs
                      .take(10)
                      .map(
                        (log) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                color: AdminColors.subtle,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.action.isEmpty
                                          ? 'Hoạt động'
                                          : log.action,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      log.description,
                                      style: const TextStyle(
                                        color: AdminColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatDateTime(log.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.subtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePassword(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? validationError;
    final authProvider = context.read<AuthProvider>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                  ),
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    validationError!,
                    style: const TextStyle(color: AdminColors.danger),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: authProvider.isChangingPassword
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: authProvider.isChangingPassword
                  ? null
                  : () async {
                      final current = currentController.text;
                      final next = newController.text;
                      if (current.isEmpty || next.isEmpty) {
                        setState(
                          () => validationError =
                              'Vui lòng nhập đầy đủ mật khẩu.',
                        );
                        return;
                      }
                      if (next.length < 6) {
                        setState(
                          () => validationError =
                              'Mật khẩu mới phải có ít nhất 6 ký tự.',
                        );
                        return;
                      }
                      if (next != confirmController.text) {
                        setState(
                          () =>
                              validationError = 'Mật khẩu xác nhận không khớp.',
                        );
                        return;
                      }
                      try {
                        await authProvider.changePassword(
                          currentPassword: current,
                          newPassword: next,
                        );
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đổi mật khẩu thành công.'),
                          ),
                        );
                      } catch (error) {
                        setState(() => validationError = error.toString());
                      }
                    },
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AdminColors.subtle),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? 'Chưa có dữ liệu' : value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
