import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/admin_entities.dart';
import '../providers/admin_revenue_provider.dart';
import '../widgets/admin_ui.dart';

class AdminRevenuePage extends StatelessWidget {
  const AdminRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminRevenueProvider>();
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
        icon: Icons.payments_outlined,
        message: 'Chưa có dữ liệu doanh thu.',
      );
    }

    final packageMax = summary.packageSales.fold<double>(
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
            title: 'Doanh thu',
            subtitle: 'Tổng hợp doanh thu và lịch sử thanh toán toàn hệ thống.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 3 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 14) / columns;
              final cards = [
                AdminMetricCard(
                  label: 'Doanh thu tháng',
                  value: formatMoney(summary.totalRevenueThisMonth),
                  icon: Icons.calendar_month_rounded,
                  color: AdminColors.primary,
                ),
                AdminMetricCard(
                  label: 'Doanh thu hôm nay',
                  value: formatMoney(summary.revenueToday),
                  icon: Icons.today_rounded,
                  color: AdminColors.success,
                ),
                AdminMetricCard(
                  label: 'Credit đã bán',
                  value: '${summary.totalCreditsPaid}',
                  icon: Icons.toll_rounded,
                  color: AdminColors.info,
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
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle('Doanh số theo gói', Icons.bar_chart),
                const SizedBox(height: 14),
                if (summary.packageSales.isEmpty)
                  const Text(
                    'Chưa có dữ liệu doanh số theo gói trong tháng.',
                    style: TextStyle(color: AdminColors.muted),
                  )
                else
                  ...summary.packageSales.map(
                    (item) => AdminBarRow(
                      label: item.packageName,
                      value: item.revenue,
                      maxValue: packageMax,
                      trailing:
                          '${item.count} lượt • ${formatMoney(item.revenue)}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminSectionTitle(
                  'Lịch sử thanh toán',
                  Icons.receipt_long_rounded,
                ),
                const SizedBox(height: 14),
                if (provider.payments.isEmpty)
                  const Text(
                    'Chưa có thanh toán nào.',
                    style: TextStyle(color: AdminColors.muted),
                  )
                else
                  ...provider.payments
                      .take(20)
                      .map((payment) => _PaymentRow(payment: payment)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

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
                payment.packageName ?? payment.paymentMethod ?? 'Thanh toán',
                style: const TextStyle(fontSize: 12, color: AdminColors.muted),
              ),
            ],
          );
          final amount = Column(
            crossAxisAlignment: constraints.maxWidth < 380
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
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
