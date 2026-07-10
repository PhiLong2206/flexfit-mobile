import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../membership/data/models/credit_package_model.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    required this.isEmailVerified,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    required this.roles,
    this.assignedGymName,
    this.assignedBranchName,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? dateOfBirth;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final List<String> roles;
  final String? assignedGymName;
  final String? assignedBranchName;

  String get displayName => fullName.trim().isEmpty ? email : fullName;
  bool get isGymPartner => roles.any(
    (role) => role.toLowerCase().replaceAll(' ', '') == 'gympartner',
  );
}

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.totalUsers,
    required this.totalGyms,
    required this.totalGymPartners,
    required this.totalBranches,
    required this.pendingGyms,
    required this.revenueToday,
    required this.revenueThisMonth,
    required this.successfulPaymentCount,
    required this.monthlyRevenue,
    required this.recentPayments,
  });

  final int totalUsers;
  final int totalGyms;
  final int totalGymPartners;
  final int totalBranches;
  final int pendingGyms;
  final double revenueToday;
  final double revenueThisMonth;
  final int successfulPaymentCount;
  final List<AdminMonthlyRevenue> monthlyRevenue;
  final List<AdminPaymentHistory> recentPayments;
}

class AdminRevenueSummary {
  const AdminRevenueSummary({
    required this.totalRevenueThisMonth,
    required this.successfulPaymentCount,
    required this.totalCreditsPaid,
    required this.revenueToday,
    required this.monthlyRevenue,
    required this.packageSales,
  });

  final double totalRevenueThisMonth;
  final int successfulPaymentCount;
  final int totalCreditsPaid;
  final double revenueToday;
  final List<AdminMonthlyRevenue> monthlyRevenue;
  final List<AdminPackageSales> packageSales;
}

class AdminMonthlyRevenue {
  const AdminMonthlyRevenue({required this.month, required this.revenue});

  final String month;
  final double revenue;
}

class AdminPackageSales {
  const AdminPackageSales({
    required this.packageName,
    required this.count,
    required this.revenue,
  });

  final String packageName;
  final int count;
  final double revenue;
}

class AdminPaymentHistory {
  const AdminPaymentHistory({
    required this.paymentId,
    required this.userId,
    this.userFullName,
    this.userEmail,
    required this.packageId,
    this.packageName,
    required this.amount,
    this.paymentMethod,
    this.providerTransactionCode,
    required this.status,
    this.paidAt,
    this.createdAt,
  });

  final String paymentId;
  final String userId;
  final String? userFullName;
  final String? userEmail;
  final String packageId;
  final String? packageName;
  final double amount;
  final String? paymentMethod;
  final String? providerTransactionCode;
  final String status;
  final DateTime? paidAt;
  final DateTime? createdAt;
}

class AdminSystemLog {
  const AdminSystemLog({
    required this.id,
    this.userId,
    this.userEmail,
    this.userFullName,
    required this.action,
    required this.description,
    this.ipAddress,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String? userEmail;
  final String? userFullName;
  final String action;
  final String description;
  final String? ipAddress;
  final DateTime? createdAt;
}

class AdminSystemLogsPage {
  const AdminSystemLogsPage({
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.logs,
  });

  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final List<AdminSystemLog> logs;
}

class AdminUtilityData {
  const AdminUtilityData({
    required this.categories,
    required this.creditPackages,
  });

  final List<Category> categories;
  final List<CreditPackageModel> creditPackages;
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.users,
    required this.gyms,
    required this.branches,
    required this.revenue,
    required this.payments,
  });

  final List<AdminUser> users;
  final List<Gym> gyms;
  final List<Branch> branches;
  final AdminRevenueSummary? revenue;
  final List<AdminPaymentHistory> payments;

  AdminDashboardSummary toSummary() {
    return AdminDashboardSummary(
      totalUsers: users.length,
      totalGyms: gyms.length,
      totalGymPartners: users.where((user) => user.isGymPartner).length,
      totalBranches: branches.length,
      pendingGyms: gyms.where((gym) => _isPending(gym.status)).length,
      revenueToday: revenue?.revenueToday ?? 0,
      revenueThisMonth: revenue?.totalRevenueThisMonth ?? 0,
      successfulPaymentCount: revenue?.successfulPaymentCount ?? 0,
      monthlyRevenue: revenue?.monthlyRevenue ?? const [],
      recentPayments: payments.take(5).toList(growable: false),
    );
  }

  bool _isPending(String status) => status.trim().toLowerCase() == 'pending';
}
