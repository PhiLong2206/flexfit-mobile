import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/admin_entities.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_ui.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    if (provider.isLoading && provider.summary == null) {
      return const AdminLoadingState(rows: 5);
    }
    if (provider.errorMessage != null && provider.summary == null) {
      return AdminErrorState(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final summary = provider.summary;
    if (summary == null) {
      return const AdminEmptyState(
        icon: Icons.dashboard_outlined,
        message: 'Chưa có dữ liệu tổng quan.',
      );
    }

    final monthlyMax = summary.monthlyRevenue.fold<double>(
      0,
      (max, item) => item.revenue > max ? item.revenue : max,
    );

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          const AdminPageHeader(
            title: 'Tổng quan',
            subtitle:
                'Theo dõi nhanh người dùng, đối tác, phê duyệt và doanh thu.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 4
                  : constraints.maxWidth >= 680
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 14) / columns;
              final cards = [
                AdminMetricCard(
                  label: 'Người dùng',
                  value: '${summary.totalUsers}',
                  icon: Icons.people_alt_rounded,
                  color: AdminColors.info,
                ),
                AdminMetricCard(
                  label: 'Đối tác Gym',
                  value: '${summary.totalGymPartners}',
                  icon: Icons.business_rounded,
                  color: AdminColors.primary,
                ),
                AdminMetricCard(
                  label: 'Phòng Gym',
                  value: '${summary.totalGyms}',
                  icon: Icons.fitness_center_rounded,
                  color: AdminColors.success,
                ),
                AdminMetricCard(
                  label: 'Chờ phê duyệt',
                  value: '${summary.pendingGyms}',
                  icon: Icons.pending_actions_rounded,
                  color: AdminColors.warning,
                ),
              ];
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: cards
                    .map((card) => SizedBox(width: width, child: card))
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final revenue = AdminPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSectionTitle(
                      'Doanh thu',
                      Icons.payments_rounded,
                    ),
                    const SizedBox(height: 16),
                    _InfoLine(
                      label: 'Hôm nay',
                      value: formatMoney(summary.revenueToday),
                    ),
                    _InfoLine(
                      label: 'Tháng này',
                      value: formatMoney(summary.revenueThisMonth),
                    ),
                    _InfoLine(
                      label: 'Thanh toán thành công',
                      value: '${summary.successfulPaymentCount}',
                    ),
                  ],
                ),
              );
              final chart = AdminPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSectionTitle(
                      '6 tháng gần nhất',
                      Icons.stacked_bar_chart_rounded,
                    ),
                    const SizedBox(height: 12),
                    if (summary.monthlyRevenue.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 26),
                        child: Text(
                          'API chưa trả dữ liệu biểu đồ.',
                          style: TextStyle(color: AdminColors.muted),
                        ),
                      )
                    else
                      ...summary.monthlyRevenue.map(
                        (item) => AdminBarRow(
                          label: item.month,
                          value: item.revenue,
                          maxValue: monthlyMax,
                        ),
                      ),
                  ],
                ),
              );
              if (constraints.maxWidth < 860) {
                return Column(
                  children: [revenue, const SizedBox(height: 20), chart],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: revenue),
                  const SizedBox(width: 20),
                  Expanded(child: chart),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle(
                  'Thanh toán gần đây',
                  Icons.receipt_long_rounded,
                ),
                const SizedBox(height: 14),
                if (summary.recentPayments.isEmpty)
                  const Text(
                    'Chưa có dữ liệu thanh toán gần đây.',
                    style: TextStyle(color: AdminColors.muted),
                  )
                else
                  ...summary.recentPayments.map(
                    (payment) => _RecentPaymentRow(payment: payment),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPaymentRow extends StatelessWidget {
  const _RecentPaymentRow({required this.payment});

  final AdminPaymentHistory payment;

  @override
  Widget build(BuildContext context) {
    final name = payment.userFullName ?? payment.userEmail ?? 'Người dùng';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                payment.packageName ?? formatDateTime(payment.createdAt),
                style: const TextStyle(color: AdminColors.muted, fontSize: 12),
              ),
            ],
          );
          final amount = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(payment.amount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              AdminStatusPill(label: payment.status),
            ],
          );
          if (constraints.maxWidth < 380) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.payments_rounded, color: AdminColors.subtle),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [details, const SizedBox(height: 10), amount],
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              const Icon(Icons.payments_rounded, color: AdminColors.subtle),
              const SizedBox(width: 12),
              Expanded(child: details),
              const SizedBox(width: 12),
              amount,
            ],
          );
        },
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AdminColors.muted),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
