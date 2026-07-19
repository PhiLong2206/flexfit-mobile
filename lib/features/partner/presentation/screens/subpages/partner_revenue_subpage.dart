import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/partner_revenue_report_model.dart';
import '../../providers/partner_provider.dart';

class PartnerRevenueSubpage extends StatelessWidget {
  final PartnerProvider provider;

  const PartnerRevenueSubpage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final report = provider.revenueReport;
    final totalRevenue = report?.totalRevenue ?? 0.0;
    final branchesRevenue = report?.revenueByBranch ?? [];
    final classesRevenue = report?.revenueByClass ?? [];

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => provider.fetchRevenue(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo cáo doanh thu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Theo dõi và phân tích doanh thu từ các cơ sở của bạn.',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Total widget
            _buildTotalAmountCard(totalRevenue),

            const SizedBox(height: 24),

            // Branches and Classes Revenue
            if (provider.isLoadingRevenue && report == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppConstants.primaryColor),
                ),
              )
            else ...[
              const Text(
                'Doanh thu theo chi nhánh',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildChartPointsList(branchesRevenue, 'Chưa có dữ liệu chi nhánh'),

              const SizedBox(height: 24),

              const Text(
                'Doanh thu theo lớp học',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildChartPointsList(classesRevenue, 'Chưa có doanh thu từ lớp học'),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppConstants.primaryColor,
            Color(0xFFFF8E43),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG DOANH THU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${total.toStringAsFixed(0)} Credits',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPointsList(List<RevenueChartPoint> items, String emptyMessage) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${item.total.toStringAsFixed(0)} cr',
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
