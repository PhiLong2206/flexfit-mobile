import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class StaffSettingsPage extends StatelessWidget {
  const StaffSettingsPage({super.key, required this.onLogout});

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
    final profile = profileProvider.profile;
    return RefreshIndicator(
      onRefresh: profileProvider.fetchProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          Text(
            'Cài đặt',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thông tin tài khoản và bảo mật dành cho nhân viên.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          if (profileProvider.isLoading && profile == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (profileProvider.error != null && profile == null)
            _ProfileError(
              message: profileProvider.error!,
              onRetry: profileProvider.fetchProfile,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _ProfileCard(
                    fullName: profile?.fullName ?? '',
                    email: profile?.email ?? '',
                    phone: profile?.phoneNumber,
                  ),
                  _SecurityCard(onLogout: onLogout),
                ];
                if (constraints.maxWidth < 850) {
                  return Column(
                    children: [
                      cards.first,
                      const SizedBox(height: 18),
                      cards.last,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards.first),
                    const SizedBox(width: 18),
                    Expanded(child: cards.last),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String fullName;
  final String email;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hồ sơ nhân viên',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFF163322),
            child: Icon(
              Icons.badge_rounded,
              size: 34,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 18),
          _ProfileRow('Họ tên', fullName),
          _ProfileRow('Email', email),
          _ProfileRow('Vai trò', 'Staff'),
          _ProfileRow('Số điện thoại', phone ?? '', isLast: true),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bảo mật',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý mật khẩu và phiên đăng nhập.',
            style: TextStyle(color: Color(0xFF94A3B8)),
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
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
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
                    style: const TextStyle(color: Colors.redAccent),
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
              child: const Text('Huỷ'),
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.label, this.value, {this.isLast = false});

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
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? 'Chưa có dữ liệu' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263244)),
      ),
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 42,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
