class RevenueChartPoint {
  final String name;
  final double total;

  const RevenueChartPoint({required this.name, required this.total});

  factory RevenueChartPoint.fromJson(Map<String, dynamic> json) {
    return RevenueChartPoint(
      name: (json['name'] ?? json['Name'] ?? json['month'] ?? json['Month'] ?? '').toString(),
      total: double.tryParse((json['total'] ?? json['Total'] ?? json['value'] ?? json['Value'] ?? 0).toString()) ?? 0.0,
    );
  }
}

class PartnerRevenueReportModel {
  final double totalRevenue;
  final List<RevenueChartPoint> revenueByMonth;
  final List<RevenueChartPoint> revenueByBranch;
  final List<RevenueChartPoint> revenueByClass;

  const PartnerRevenueReportModel({
    required this.totalRevenue,
    required this.revenueByMonth,
    required this.revenueByBranch,
    required this.revenueByClass,
  });

  factory PartnerRevenueReportModel.fromJson(Map<String, dynamic> json) {
    final listMonth = <RevenueChartPoint>[];
    if (json['revenueByMonth'] is List) {
      for (final item in json['revenueByMonth']) {
        listMonth.add(RevenueChartPoint.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    final listBranch = <RevenueChartPoint>[];
    if (json['revenueByBranch'] is List) {
      for (final item in json['revenueByBranch']) {
        listBranch.add(RevenueChartPoint.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    final listClass = <RevenueChartPoint>[];
    if (json['revenueByClass'] is List) {
      for (final item in json['revenueByClass']) {
        listClass.add(RevenueChartPoint.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return PartnerRevenueReportModel(
      totalRevenue: double.tryParse((json['totalRevenue'] ?? json['TotalRevenue'] ?? 0).toString()) ?? 0.0,
      revenueByMonth: listMonth,
      revenueByBranch: listBranch,
      revenueByClass: listClass,
    );
  }
}
