import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../catalog/domain/entities/fitness_class.dart';
import '../providers/staff_schedule_provider.dart';

class StaffSchedulePage extends StatelessWidget {
  const StaffSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StaffScheduleProvider>()..load(),
      child: const _StaffScheduleView(),
    );
  }
}

class _StaffScheduleView extends StatelessWidget {
  const _StaffScheduleView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffScheduleProvider>();
    if (provider.isLoading && provider.visibleClasses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.visibleClasses.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final classes = provider.visibleClasses;
          final columns = constraints.maxWidth >= 1250
              ? 3
              : constraints.maxWidth >= 760
              ? 2
              : 1;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch học & lớp học',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Theo dõi các lớp tại chi nhánh bạn được phân công.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 22),
                      _Toolbar(provider: provider),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (classes.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ClassCard(item: classes[index]),
                      childCount: classes.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 278,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.provider});

  final StaffScheduleProvider provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          onChanged: provider.setQuery,
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên lớp học',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(),
          ),
        );
        final filters = SegmentedButton<StaffScheduleFilter>(
          segments: const [
            ButtonSegment(
              value: StaffScheduleFilter.today,
              label: Text('Hôm nay'),
              icon: Icon(Icons.today_rounded),
            ),
            ButtonSegment(
              value: StaffScheduleFilter.upcoming,
              label: Text('Sắp tới'),
              icon: Icon(Icons.upcoming_rounded),
            ),
            ButtonSegment(
              value: StaffScheduleFilter.all,
              label: Text('Tất cả'),
              icon: Icon(Icons.view_list_rounded),
            ),
          ],
          selected: {provider.filter},
          onSelectionChanged: (values) => provider.setFilter(values.first),
        );
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 12), filters],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 16),
            filters,
          ],
        );
      },
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item});

  final FitnessClass item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263244)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(status: item.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.categoryName.isEmpty
                  ? 'Chưa có danh mục'
                  : item.categoryName,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: item.coachName?.trim().isNotEmpty == true
                  ? item.coachName!
                  : 'Chưa có huấn luyện viên',
            ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: item.branchName.isEmpty
                  ? 'Chưa có chi nhánh'
                  : item.branchName,
            ),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label:
                  '${_date(item.startTime)} • ${_time(item.startTime)} – ${_time(item.endTime)}',
            ),
            _InfoRow(
              icon: Icons.groups_2_outlined,
              label: 'Sức chứa: ${item.capacity}',
            ),
            const Spacer(),
            const Divider(color: Color(0xFF263244)),
            const SizedBox(height: 6),
            Text(
              _relativeLabel(item.startTime),
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.trim().isEmpty ? 'Chưa có trạng thái' : status,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 54, color: Color(0xFF64748B)),
            SizedBox(height: 14),
            Text(
              'Không có lớp học phù hợp.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Hãy thử bộ lọc khác hoặc kéo xuống để làm mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không thể tải lịch học',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.contains('active') ||
      normalized.contains('open') ||
      normalized.contains('scheduled')) {
    return const Color(0xFF22C55E);
  }
  if (normalized.contains('cancel')) return Colors.redAccent;
  if (normalized.contains('complete') || normalized.contains('finish')) {
    return const Color(0xFF3B82F6);
  }
  return const Color(0xFFF59E0B);
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _relativeLabel(DateTime startTime) {
  final difference = startTime.difference(DateTime.now());
  if (difference.isNegative) return 'Thời gian bắt đầu đã qua';
  if (difference.inDays > 0) return 'Bắt đầu sau ${difference.inDays} ngày';
  if (difference.inHours > 0) return 'Bắt đầu sau ${difference.inHours} giờ';
  return 'Sắp bắt đầu';
}
