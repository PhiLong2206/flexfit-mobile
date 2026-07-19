class ChartPointModel {
  final String name;
  final double value;

  const ChartPointModel({required this.name, required this.value});

  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
    return ChartPointModel(
      name: (json['month'] ?? json['Month'] ?? json['time'] ?? json['Time'] ?? '').toString(),
      value: double.tryParse((json['value'] ?? json['Value'] ?? json['count'] ?? json['Count'] ?? 0).toString()) ?? 0.0,
    );
  }
}

class PartnerDashboardStatsModel {
  final int revenue;
  final int newCustomers;
  final int totalBookings;
  final double occupancyRate;
  final List<ChartPointModel> revenueData;
  final List<ChartPointModel> attendanceData;

  const PartnerDashboardStatsModel({
    required this.revenue,
    required this.newCustomers,
    required this.totalBookings,
    required this.occupancyRate,
    required this.revenueData,
    required this.attendanceData,
  });

  factory PartnerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final rawOccupancy = double.tryParse((json['occupancyRate'] ?? json['OccupancyRate'] ?? 0).toString()) ?? 0.0;
    // If occupancyRate is <= 1 (e.g. 0.85), convert to percentage (85%)
    final occupancyRate = rawOccupancy <= 1.0 ? rawOccupancy * 100.0 : rawOccupancy;

    final revenueChartRaw = json['revenueChart'] ?? json['RevenueChart'];
    final List<ChartPointModel> revenueData = [];
    if (revenueChartRaw is List) {
      for (final item in revenueChartRaw) {
        if (item is Map<String, dynamic>) {
          revenueData.add(ChartPointModel.fromJson(item));
        }
      }
    }

    final bookingChartRaw = json['bookingChart'] ?? json['BookingChart'];
    final List<ChartPointModel> attendanceData = [];
    if (bookingChartRaw is List) {
      for (final item in bookingChartRaw) {
        if (item is Map<String, dynamic>) {
          attendanceData.add(ChartPointModel.fromJson(item));
        }
      }
    }

    return PartnerDashboardStatsModel(
      revenue: int.tryParse((json['revenueThisMonth'] ?? json['RevenueThisMonth'] ?? 0).toString()) ?? 0,
      newCustomers: int.tryParse((json['newCustomersThisMonth'] ?? json['NewCustomersThisMonth'] ?? 0).toString()) ?? 0,
      totalBookings: int.tryParse((json['bookingsThisMonth'] ?? json['BookingsThisMonth'] ?? 0).toString()) ?? 0,
      occupancyRate: occupancyRate,
      revenueData: revenueData,
      attendanceData: attendanceData,
    );
  }
}
