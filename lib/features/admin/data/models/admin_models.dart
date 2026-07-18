import '../../../catalog/data/models/branch_model.dart';
import '../../../catalog/data/models/category_model.dart';
import '../../../catalog/data/models/gym_model.dart';
import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../membership/data/models/credit_package_model.dart';
import '../../domain/entities/admin_entities.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.dateOfBirth,
    required super.isEmailVerified,
    required super.isActive,
    super.lastLoginAt,
    super.createdAt,
    required super.roles,
    super.assignedGymName,
    super.assignedBranchName,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: _string(json, 'userId') ?? '',
      fullName: _string(json, 'fullName') ?? '',
      email: _string(json, 'email') ?? '',
      phoneNumber: _string(json, 'phoneNumber'),
      avatarUrl: _string(json, 'avatarUrl'),
      dateOfBirth: _string(json, 'dateOfBirth'),
      isEmailVerified: _bool(json, 'isEmailVerified'),
      isActive: _bool(json, 'isActive', fallback: true),
      lastLoginAt: _date(json, 'lastLoginAt'),
      createdAt: _date(json, 'createdAt'),
      roles: _stringList(json, 'roles'),
      assignedGymName: _string(json, 'assignedGymName'),
      assignedBranchName: _string(json, 'assignedBranchName'),
    );
  }
}

class AdminRevenueSummaryModel extends AdminRevenueSummary {
  const AdminRevenueSummaryModel({
    required super.totalRevenueThisMonth,
    required super.successfulPaymentCount,
    required super.totalCreditsPaid,
    required super.revenueToday,
    required super.monthlyRevenue,
    required super.packageSales,
  });

  factory AdminRevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminRevenueSummaryModel(
      totalRevenueThisMonth: _double(json, 'totalRevenueThisMonth'),
      successfulPaymentCount: _int(json, 'successfulPaymentCount'),
      totalCreditsPaid: _int(json, 'totalCreditsPaid'),
      revenueToday: _double(json, 'revenueToday'),
      monthlyRevenue: _list(
        json,
        'monthlyRevenue',
      ).map(AdminMonthlyRevenueModel.fromJson).toList(growable: false),
      packageSales: _list(
        json,
        'packageSales',
      ).map(AdminPackageSalesModel.fromJson).toList(growable: false),
    );
  }
}

class AdminMonthlyRevenueModel extends AdminMonthlyRevenue {
  const AdminMonthlyRevenueModel({
    required super.month,
    required super.revenue,
  });

  factory AdminMonthlyRevenueModel.fromJson(Map<String, dynamic> json) {
    return AdminMonthlyRevenueModel(
      month: _string(json, 'month') ?? '',
      revenue: _double(json, 'revenue'),
    );
  }
}

class AdminPackageSalesModel extends AdminPackageSales {
  const AdminPackageSalesModel({
    required super.packageName,
    required super.count,
    required super.revenue,
  });

  factory AdminPackageSalesModel.fromJson(Map<String, dynamic> json) {
    return AdminPackageSalesModel(
      packageName: _string(json, 'packageName') ?? 'Gói Credit',
      count: _int(json, 'count'),
      revenue: _double(json, 'revenue'),
    );
  }
}

class AdminPaymentHistoryModel extends AdminPaymentHistory {
  const AdminPaymentHistoryModel({
    required super.paymentId,
    required super.userId,
    super.userFullName,
    super.userEmail,
    required super.packageId,
    super.packageName,
    required super.amount,
    super.paymentMethod,
    super.providerTransactionCode,
    required super.status,
    super.paidAt,
    super.createdAt,
  });

  factory AdminPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return AdminPaymentHistoryModel(
      paymentId: _string(json, 'paymentId') ?? '',
      userId: _string(json, 'userId') ?? '',
      userFullName: _string(json, 'userFullName'),
      userEmail: _string(json, 'userEmail'),
      packageId: _string(json, 'packageId') ?? '',
      packageName: _string(json, 'packageName'),
      amount: _double(json, 'amount'),
      paymentMethod: _string(json, 'paymentMethod'),
      providerTransactionCode: _string(json, 'providerTransactionCode'),
      status: _string(json, 'status') ?? 'Pending',
      paidAt: _date(json, 'paidAt'),
      createdAt: _date(json, 'createdAt'),
    );
  }
}

class AdminSystemLogModel extends AdminSystemLog {
  const AdminSystemLogModel({
    required super.id,
    super.userId,
    super.userEmail,
    super.userFullName,
    required super.action,
    required super.description,
    super.ipAddress,
    super.createdAt,
  });

  factory AdminSystemLogModel.fromJson(Map<String, dynamic> json) {
    return AdminSystemLogModel(
      id: _string(json, 'logId') ?? '',
      userId: _string(json, 'userId'),
      userEmail: _string(json, 'userEmail'),
      userFullName: _string(json, 'userFullName'),
      action: _string(json, 'action') ?? '',
      description: _string(json, 'description') ?? '',
      ipAddress: _string(json, 'ipAddress'),
      createdAt: _date(json, 'createdAt'),
    );
  }
}

List<AdminUserModel> adminUsersFromResponse(dynamic response) {
  return _readList(response)
      .map(AdminUserModel.fromJson)
      .where((user) => user.id.isNotEmpty)
      .toList(growable: false);
}

List<Gym> adminGymsFromResponse(dynamic response) {
  return _readList(response)
      .map(GymModel.fromJson)
      .where((gym) => gym.id.isNotEmpty)
      .toList(growable: false);
}

List<Branch> adminBranchesFromResponse(dynamic response) {
  return _readList(response)
      .map(BranchModel.fromJson)
      .where((branch) => branch.id.isNotEmpty)
      .toList(growable: false);
}

List<Category> adminCategoriesFromResponse(dynamic response) {
  return _readList(response)
      .map(CategoryModel.fromJson)
      .where((category) => category.id.isNotEmpty)
      .toList(growable: false);
}

List<CreditPackageModel> adminCreditPackagesFromResponse(dynamic response) {
  return _readList(response)
      .map(CreditPackageModel.fromJson)
      .where((package) => package.id.isNotEmpty)
      .toList(growable: false);
}

List<AdminPaymentHistoryModel> adminPaymentsFromResponse(dynamic response) {
  return _readList(response)
      .map(AdminPaymentHistoryModel.fromJson)
      .where((payment) => payment.paymentId.isNotEmpty)
      .toList(growable: false);
}

AdminSystemLogsPage adminLogsFromResponse(dynamic response) {
  if (response is! Map) {
    return const AdminSystemLogsPage(
      totalCount: 0,
      pageNumber: 1,
      pageSize: 20,
      logs: [],
    );
  }
  final map = Map<String, dynamic>.from(response);
  return AdminSystemLogsPage(
    totalCount: _int(map, 'totalCount'),
    pageNumber: _int(map, 'pageNumber', fallback: 1),
    pageSize: _int(map, 'pageSize', fallback: 20),
    logs: _list(
      map,
      'logs',
    ).map(AdminSystemLogModel.fromJson).toList(growable: false),
  );
}

List<Map<String, dynamic>> _readList(dynamic response) {
  final items = response is List
      ? response
      : response is Map
      ? response['data'] ??
            response['Data'] ??
            response['items'] ??
            response['Items'] ??
            response['logs'] ??
            response['Logs']
      : null;
  if (items is! List) return const [];
  return items
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
  final value = _read(json, key);
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final value = _read(json, key);
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _string(Map<String, dynamic> json, String key) {
  final value = _read(json, key)?.toString().trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

bool _bool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final value = _read(json, key);
  if (value is bool) return value;
  return bool.tryParse(value?.toString() ?? '') ?? fallback;
}

int _int(Map<String, dynamic> json, String key, {int fallback = 0}) {
  return int.tryParse(_read(json, key)?.toString() ?? '') ?? fallback;
}

double _double(Map<String, dynamic> json, String key) {
  return double.tryParse(_read(json, key)?.toString() ?? '') ?? 0;
}

DateTime? _date(Map<String, dynamic> json, String key) {
  final value = _string(json, key);
  if (value == null) return null;
  return DateTime.tryParse(value);
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
