import '../../../catalog/domain/entities/fitness_class.dart';
import 'staff_check_in_log.dart';

class StaffDashboardSummary {
  const StaffDashboardSummary({
    required this.todayCheckInCount,
    required this.relatedCustomerCount,
    required this.todayClassCount,
    required this.recentCheckIns,
    required this.todayClasses,
    this.membersInGym,
  });

  final int todayCheckInCount;
  final int relatedCustomerCount;
  final int todayClassCount;
  final int? membersInGym;
  final List<StaffCheckInLog> recentCheckIns;
  final List<FitnessClass> todayClasses;
}
