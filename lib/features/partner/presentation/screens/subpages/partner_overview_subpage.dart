import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/partner_dashboard_stats_model.dart';
import '../../providers/partner_provider.dart';

class PartnerOverviewSubpage extends StatelessWidget {
  final PartnerProvider provider;

  const PartnerOverviewSubpage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.dashboardStats;

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => provider.fetchAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan doanh thu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hiệu suất kinh doanh tổng hợp các chi nhánh tháng này.',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            _buildStatsGrid(stats),

            const SizedBox(height: 24),

            // Trend Chart
            if (stats != null && (stats.revenueData.isNotEmpty || stats.attendanceData.isNotEmpty))
              _buildChartsSection(stats),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(PartnerDashboardStatsModel? stats) {
    final revenue = stats?.revenue ?? 0;
    final customers = stats?.newCustomers ?? 0;
    final bookings = stats?.totalBookings ?? 0;
    final occupancy = stats?.occupancyRate ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        _buildStatCard(
          title: 'Doanh thu tháng',
          value: '$revenue credits',
          icon: Icons.monetization_on,
          iconColor: AppConstants.primaryColor,
          trend: '+12.5% so với tháng trước',
        ),
        _buildStatCard(
          title: 'Khách hàng mới',
          value: '+$customers',
          icon: Icons.people,
          iconColor: Colors.blueAccent,
          trend: '+4.1% so với tháng trước',
        ),
        _buildStatCard(
          title: 'Lượt đặt chỗ',
          value: '$bookings',
          icon: Icons.calendar_month,
          iconColor: Colors.purpleAccent,
          trend: 'Trong 30 ngày qua',
        ),
        _buildStatCard(
          title: 'Tỷ lệ lấp đầy',
          value: '${occupancy.toStringAsFixed(1)}%',
          icon: Icons.percent,
          iconColor: Colors.amberAccent,
          trend: 'Trung bình các lớp',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trend,
            style: TextStyle(
              fontSize: 10,
              color: trend.contains('+') ? Colors.greenAccent : AppConstants.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(PartnerDashboardStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu xu hướng (6 tháng gần đây)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.revenueData.map((pt) {
                double maxVal = stats.revenueData.map((e) => e.value).fold(1.0, (m, e) => e > m ? e : m);
                if (maxVal == 0) maxVal = 1.0;
                final heightFactor = (pt.value / maxVal).clamp(0.05, 1.0);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        pt.value.toInt().toString(),
                        style: const TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 16,
                        height: 70 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppConstants.primaryColor.withOpacity(0.3),
                              AppConstants.primaryColor,
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pt.name,
                        style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
