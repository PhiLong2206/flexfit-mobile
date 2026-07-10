import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalog/domain/entities/gym.dart';
import '../../domain/entities/admin_entities.dart';
import '../providers/admin_gyms_provider.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_ui.dart';

class AdminGymPartnersPage extends StatelessWidget {
  const AdminGymPartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminGymsProvider>();
    if (provider.isLoading && provider.gyms.isEmpty) {
      return const AdminLoadingState(rows: 5);
    }
    if (provider.errorMessage != null && provider.gyms.isEmpty) {
      return AdminErrorState(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final gyms = provider.filteredGyms;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          AdminPageHeader(
            title: 'Đối tác Gym',
            subtitle: 'Tạo gym và cập nhật trạng thái được backend hỗ trợ.',
            trailing: FilledButton.icon(
              onPressed: provider.isMutating
                  ? null
                  : () => _showCreateGymDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo Gym'),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final search = AdminSearchField(
                hintText: 'Tìm theo tên, email hoặc số điện thoại',
                onChanged: provider.setQuery,
              );
              final filter = DropdownButtonFormField<String>(
                initialValue: provider.statusFilter,
                items: provider.statuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) provider.setStatusFilter(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AdminColors.panelAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AdminColors.border),
                  ),
                ),
              );
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [search, const SizedBox(height: 12), filter],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  SizedBox(width: 220, child: filter),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          if (gyms.isEmpty)
            const AdminEmptyState(
              icon: Icons.business_outlined,
              message: 'Không tìm thấy phòng gym phù hợp.',
            )
          else
            ...gyms.map((gym) => _GymTile(gym: gym)),
        ],
      ),
    );
  }
}

class _GymTile extends StatelessWidget {
  const _GymTile({required this.gym});

  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminGymsProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gym.email ??
                            gym.phoneNumber ??
                            'Chưa có thông tin liên hệ',
                        style: const TextStyle(color: AdminColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${gym.totalReviews} đánh giá • ${gym.ratingAverage.toStringAsFixed(1)} sao',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AdminStatusPill(label: gym.status),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusActions(gym.status)
                  .map(
                    (action) => OutlinedButton.icon(
                      onPressed: provider.isMutating
                          ? null
                          : () => _confirmStatusChange(
                              context,
                              gym,
                              action.status,
                            ),
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymStatusAction {
  const _GymStatusAction(this.label, this.status, this.icon);

  final String label;
  final String status;
  final IconData icon;
}

List<_GymStatusAction> _statusActions(String currentStatus) {
  final status = currentStatus.trim().toLowerCase();
  if (status == 'pending') {
    return const [
      _GymStatusAction('Approve', 'Approved', Icons.check_circle_rounded),
      _GymStatusAction('Reject', 'Rejected', Icons.cancel_rounded),
    ];
  }
  if (status == 'approved' || status == 'active') {
    return const [
      _GymStatusAction('Suspend', 'Suspended', Icons.pause_circle_rounded),
    ];
  }
  if (status == 'suspended' || status == 'rejected' || status == 'inactive') {
    return const [
      _GymStatusAction('Activate', 'Active', Icons.play_circle_rounded),
    ];
  }
  return const [
    _GymStatusAction('Activate', 'Active', Icons.play_circle_rounded),
    _GymStatusAction('Suspend', 'Suspended', Icons.pause_circle_rounded),
  ];
}

Future<void> _showCreateGymDialog(BuildContext context) async {
  final users = context.read<AdminUsersProvider>().users;
  final ownerCandidates = users.where((user) => user.id.isNotEmpty).toList();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final thumbnailController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  AdminUser? owner = ownerCandidates.isEmpty ? null : ownerCandidates.first;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Tạo Gym'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AdminUser>(
                initialValue: owner,
                items: ownerCandidates
                    .map(
                      (user) => DropdownMenuItem(
                        value: user,
                        child: Text(user.displayName),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => owner = value),
                decoration: const InputDecoration(labelText: 'Owner'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên Gym'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextField(
                controller: thumbnailController,
                decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
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
              if (owner == null) {
                setState(() => error = 'Vui lòng chọn owner.');
                return;
              }
              if (nameController.text.trim().isEmpty) {
                setState(() => error = 'Tên Gym không được để trống.');
                return;
              }
              try {
                await context.read<AdminGymsProvider>().createGym(
                  ownerId: owner!.id,
                  gymName: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  thumbnailUrl: thumbnailController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  email: emailController.text.trim(),
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(context, 'Đã tạo Gym.');
              } catch (e) {
                setState(() => error = e.toString());
                _showSnack(context, e.toString(), isError: true);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  descriptionController.dispose();
  thumbnailController.dispose();
  phoneController.dispose();
  emailController.dispose();
}

Future<void> _confirmStatusChange(
  BuildContext context,
  Gym gym,
  String status,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Chuyển trạng thái $status?'),
      content: Text('Gym ${gym.name} sẽ được chuyển sang $status.'),
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
    await context.read<AdminGymsProvider>().changeGymStatus(
      gymId: gym.id,
      status: status,
    );
    if (!context.mounted) return;
    _showSnack(context, 'Đã cập nhật trạng thái Gym.');
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
