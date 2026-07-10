import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/admin_entities.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_ui.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();
    if (provider.isLoading && provider.users.isEmpty) {
      return const AdminLoadingState(rows: 6);
    }
    if (provider.errorMessage != null && provider.users.isEmpty) {
      return AdminErrorState(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final users = provider.filteredUsers;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          AdminPageHeader(
            title: 'Người dùng',
            subtitle: 'Quản lý tài khoản thật từ hệ thống FlexFit.',
            trailing: AdminStatusPill(
              label: provider.isMutating
                  ? 'Đang xử lý'
                  : '${provider.users.length} tài khoản',
            ),
          ),
          const SizedBox(height: 18),
          AdminSearchField(
            hintText: 'Tìm theo tên, email hoặc vai trò',
            onChanged: provider.setQuery,
          ),
          const SizedBox(height: 18),
          if (users.isEmpty)
            const AdminEmptyState(
              icon: Icons.person_search_rounded,
              message: 'Không tìm thấy người dùng phù hợp.',
            )
          else
            ...users.map((user) => _UserTile(user: user)),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final roles = user.roles.isEmpty
        ? 'Chưa có vai trò'
        : user.roles.join(', ');
    final provider = context.watch<AdminUsersProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminPanel(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: user.isActive
                  ? AdminColors.success.withValues(alpha: 0.18)
                  : AdminColors.danger.withValues(alpha: 0.18),
              child: Icon(
                Icons.person_rounded,
                color: user.isActive ? AdminColors.success : AdminColors.danger,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AdminColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AdminStatusPill(label: roles, color: AdminColors.info),
                      AdminStatusPill(
                        label: user.isActive ? 'Đang hoạt động' : 'Bị khóa',
                        color: user.isActive
                            ? AdminColors.success
                            : AdminColors.danger,
                      ),
                      AdminStatusPill(
                        label: 'Login: ${formatDateTime(user.lastLoginAt)}',
                        color: AdminColors.subtle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<_UserAction>(
              enabled: !provider.isMutating,
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) => _handleUserAction(context, action, user),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _UserAction.edit,
                  child: Text('Sửa hồ sơ'),
                ),
                const PopupMenuItem(
                  value: _UserAction.assignRole,
                  child: Text('Gán vai trò'),
                ),
                const PopupMenuItem(
                  value: _UserAction.revokeRole,
                  child: Text('Thu hồi vai trò'),
                ),
                PopupMenuItem(
                  value: _UserAction.toggleStatus,
                  child: Text(user.isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                ),
                const PopupMenuItem(
                  value: _UserAction.delete,
                  child: Text('Xóa người dùng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _UserAction { edit, assignRole, revokeRole, toggleStatus, delete }

Future<void> _handleUserAction(
  BuildContext context,
  _UserAction action,
  AdminUser user,
) async {
  switch (action) {
    case _UserAction.edit:
      await _showEditUserDialog(context, user);
      return;
    case _UserAction.assignRole:
      await _showAssignRoleDialog(context, user);
      return;
    case _UserAction.revokeRole:
      await _showRevokeRoleDialog(context, user);
      return;
    case _UserAction.toggleStatus:
      await _confirmAndRun(
        context,
        title: user.isActive ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?',
        message: user.isActive
            ? 'Tài khoản ${user.displayName} sẽ bị khóa.'
            : 'Tài khoản ${user.displayName} sẽ được mở khóa.',
        successMessage: user.isActive
            ? 'Đã khóa tài khoản.'
            : 'Đã mở khóa tài khoản.',
        action: () => context.read<AdminUsersProvider>().changeUserStatus(
          userId: user.id,
          isActive: !user.isActive,
        ),
      );
      return;
    case _UserAction.delete:
      await _confirmAndRun(
        context,
        title: 'Xóa người dùng?',
        message: 'Người dùng ${user.displayName} sẽ bị xóa khỏi hệ thống.',
        successMessage: 'Đã xóa người dùng.',
        action: () => context.read<AdminUsersProvider>().deleteUser(user.id),
      );
      return;
  }
}

Future<void> _showEditUserDialog(BuildContext context, AdminUser user) async {
  final nameController = TextEditingController(text: user.fullName);
  final phoneController = TextEditingController(text: user.phoneNumber ?? '');
  final avatarController = TextEditingController(text: user.avatarUrl ?? '');
  final dobController = TextEditingController(text: user.dateOfBirth ?? '');
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Sửa hồ sơ người dùng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextField(
                controller: avatarController,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(
                  labelText: 'Ngày sinh (yyyy-MM-dd)',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: AdminColors.danger)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                setState(() => error = 'Họ tên không được để trống.');
                return;
              }
              try {
                await context.read<AdminUsersProvider>().updateUser(
                  userId: user.id,
                  fullName: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  avatarUrl: avatarController.text.trim(),
                  dateOfBirth: dobController.text.trim(),
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(context, 'Đã cập nhật hồ sơ người dùng.');
              } catch (e) {
                setState(() => error = e.toString());
                _showSnack(context, e.toString(), isError: true);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  phoneController.dispose();
  avatarController.dispose();
  dobController.dispose();
}

Future<void> _showAssignRoleDialog(BuildContext context, AdminUser user) async {
  const roles = ['Member', 'Staff', 'GymPartner', 'Admin'];
  var roleName = roles.firstWhere(
    (role) => !user.roles.contains(role),
    orElse: () => roles.first,
  );
  String? gymId;
  String? branchId;
  String? error;
  final provider = context.read<AdminUsersProvider>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Gán vai trò'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: roleName,
                items: roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    roleName = value ?? roleName;
                    gymId = null;
                    branchId = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Vai trò'),
              ),
              if (roleName == 'GymPartner') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: gymId,
                  items: provider.gyms
                      .map(
                        (gym) => DropdownMenuItem(
                          value: gym.id,
                          child: Text(gym.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setState(() => gymId = value),
                  decoration: const InputDecoration(labelText: 'Phòng gym'),
                ),
              ],
              if (roleName == 'Staff') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: branchId,
                  items: provider.branches
                      .map(
                        (branch) => DropdownMenuItem(
                          value: branch.id,
                          child: Text(branch.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setState(() => branchId = value),
                  decoration: const InputDecoration(labelText: 'Chi nhánh'),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: AdminColors.danger)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (roleName == 'GymPartner' && gymId == null) {
                setState(() => error = 'Vui lòng chọn phòng gym.');
                return;
              }
              if (roleName == 'Staff' && branchId == null) {
                setState(() => error = 'Vui lòng chọn chi nhánh.');
                return;
              }
              try {
                await provider.assignRole(
                  userId: user.id,
                  roleName: roleName,
                  gymId: gymId,
                  branchId: branchId,
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(context, 'Đã gán vai trò.');
              } catch (e) {
                setState(() => error = e.toString());
                _showSnack(context, e.toString(), isError: true);
              }
            },
            child: const Text('Gán'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showRevokeRoleDialog(BuildContext context, AdminUser user) async {
  if (user.roles.isEmpty) {
    _showSnack(
      context,
      'Người dùng chưa có vai trò để thu hồi.',
      isError: true,
    );
    return;
  }
  var roleName = user.roles.first;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Thu hồi vai trò'),
      content: StatefulBuilder(
        builder: (context, setState) => DropdownButtonFormField<String>(
          initialValue: roleName,
          items: user.roles
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(growable: false),
          onChanged: (value) => setState(() => roleName = value ?? roleName),
          decoration: const InputDecoration(labelText: 'Vai trò'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await context.read<AdminUsersProvider>().revokeRole(
                userId: user.id,
                roleName: roleName,
              );
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              _showSnack(context, 'Đã thu hồi vai trò.');
            } catch (e) {
              _showSnack(context, e.toString(), isError: true);
            }
          },
          child: const Text('Thu hồi'),
        ),
      ],
    ),
  );
}

Future<void> _confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required String successMessage,
  required Future<void> Function() action,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await action();
    if (!context.mounted) return;
    _showSnack(context, successMessage);
  } catch (e) {
    if (!context.mounted) return;
    _showSnack(context, e.toString(), isError: true);
  }
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AdminColors.danger : AdminColors.success,
    ),
  );
}
