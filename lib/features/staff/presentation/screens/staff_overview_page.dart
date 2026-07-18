import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/staff_dashboard_summary.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/staff_dashboard_provider.dart';

class StaffOverviewPage extends StatelessWidget {
  const StaffOverviewPage({super.key, required this.onOpenCheckIn});

  final VoidCallback onOpenCheckIn;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffDashboardProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    if (provider.isLoading && provider.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.summary == null) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final summary = provider.summary;
    if (summary == null) return const SizedBox.shrink();
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile?.fullName.trim().isNotEmpty == true
                      ? 'Xin chào, ${profile!.fullName}'
                      : 'Xin chào, nhân viên FlexFit',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const _ShiftPill(),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Tổng quan',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dữ liệu hoạt động tại các chi nhánh bạn được phân công.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          _MetricsGrid(summary: summary),
          const SizedBox(height: 24),
          _QuickCheckInCard(onTap: onOpenCheckIn),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final recent = _RecentCheckIns(summary: summary);
              final classes = _TodayClasses(summary: summary);
              if (!wide) {
                return Column(
                  children: [recent, const SizedBox(height: 20), classes],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: recent),
                  const SizedBox(width: 20),
                  Expanded(child: classes),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShiftPill extends StatelessWidget {
  const _ShiftPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF263244)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Ca làm: Chưa có dữ liệu',
          style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B)),
        ),
      ),
    );
  }
}

class _QuickCheckInCard extends StatelessWidget {
  const _QuickCheckInCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF163322),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-in nhanh',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 3),
                Text(
                  'Tra cứu mã booking thực tế.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final StaffDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricData(
        'Lượt check-in hôm nay',
        '${summary.todayCheckInCount}',
        Icons.how_to_reg_rounded,
        const Color(0xFF22C55E),
      ),
      _MetricData(
        'Khách hàng liên quan',
        '${summary.relatedCustomerCount}',
        Icons.groups_rounded,
        const Color(0xFF3B82F6),
      ),
      _MetricData(
        'Lớp học hôm nay',
        '${summary.todayClassCount}',
        Icons.event_available_rounded,
        const Color(0xFFF59E0B),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards
              .map((data) => SizedBox(width: width, child: _MetricCard(data)))
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.data);

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(data.icon, color: data.color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 7),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCheckIns extends StatelessWidget {
  const _RecentCheckIns({required this.summary});

  final StaffDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Check-in gần nhất', Icons.history_rounded),
          const SizedBox(height: 14),
          if (summary.recentCheckIns.isEmpty)
            const _EmptyState('Chưa có lượt check-in nào.')
          else
            ...summary.recentCheckIns.map(
              (log) => _ListRow(
                title: log.memberName.isEmpty ? 'Khách hàng' : log.memberName,
                subtitle: log.className ?? log.memberEmail,
                trailing: _dateTime(log.scannedAt),
                icon: Icons.check_circle_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayClasses extends StatelessWidget {
  const _TodayClasses({required this.summary});

  final StaffDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Lớp học hôm nay', Icons.calendar_today_rounded),
          const SizedBox(height: 14),
          if (summary.todayClasses.isEmpty)
            const _EmptyState('Hôm nay chưa có lớp học được phân công.')
          else
            ...summary.todayClasses.map(
              (item) => _ListRow(
                title: item.name,
                subtitle:
                    '${item.branchName} • ${item.coachName ?? 'Chưa có HLV'}',
                trailing: '${_time(item.startTime)}–${_time(item.endTime)}',
                icon: Icons.fitness_center_rounded,
              ),
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
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF22C55E)),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF64748B))),
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
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không thể tải tổng quan',
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

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _dateTime(DateTime value) =>
    '${_time(value)} ${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
