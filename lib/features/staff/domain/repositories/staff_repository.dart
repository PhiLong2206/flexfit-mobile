import '../../../catalog/domain/entities/fitness_class.dart';
import '../entities/staff_dashboard_summary.dart';
import '../entities/staff_booking.dart';
import '../entities/staff_check_in_log.dart';
import '../entities/staff_review.dart';

abstract class StaffRepository {
  Future<StaffDashboardSummary> getDashboardSummary({DateTime? now});
  Future<List<StaffBooking>> getCheckInCandidates();
  Future<List<StaffCheckInLog>> getManagerCheckInLogs();
  Future<StaffCheckInLog> checkInGym(StaffBooking booking);
  Future<StaffCheckInLog> checkInClass(StaffBooking booking);
  Future<List<FitnessClass>> getStaffSchedule();
  Future<List<StaffReview>> getStaffReviews();
}
