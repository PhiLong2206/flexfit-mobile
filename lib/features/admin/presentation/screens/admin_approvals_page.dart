import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalog/domain/entities/gym.dart';
import '../providers/admin_gyms_provider.dart';
import '../widgets/admin_ui.dart';

class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminGymsProvider>();
    if (provider.isLoading && provider.gyms.isEmpty) {
      return const AdminLoadingState(rows: 4);
    }
    if (provider.errorMessage != null && provider.gyms.isEmpty) {
      return AdminErrorState(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final pending = provider.pendingGyms;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          AdminPageHeader(
            title: 'Phê duyệt',
            subtitle: 'Duyệt hoặc từ chối gym có trạng thái Pending.',
            trailing: AdminStatusPill(
              label: provider.isMutating
                  ? 'Đang xử lý'
                  : '${pending.length} chờ duyệt',
              color: AdminColors.warning,
            ),
          ),
          const SizedBox(height: 20),
          if (pending.isEmpty)
            const AdminEmptyState(
              icon: Icons.verified_rounded,
              message: 'Không có gym nào đang chờ phê duyệt.',
            )
          else
            ...pending.map((gym) => _PendingGymTile(gym: gym)),
        ],
      ),
    );
  }
}

class _PendingGymTile extends StatelessWidget {
  const _PendingGymTile({required this.gym});

  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminGymsProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminPanel(
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF3A2D12),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    color: AdminColors.warning,
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
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AdminStatusPill(label: gym.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: provider.isMutating
                        ? null
                        : () => _confirmStatus(context, gym, 'Approved'),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isMutating
                        ? null
                        : () => _confirmStatus(context, gym, 'Rejected'),
                    icon: const Icon(Icons.cancel_rounded),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmStatus(
  BuildContext context,
  Gym gym,
  String status,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$status gym?'),
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
