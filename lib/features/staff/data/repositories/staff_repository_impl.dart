import '../../../catalog/domain/entities/fitness_class.dart';
import '../../domain/entities/staff_dashboard_summary.dart';
import '../../domain/entities/staff_booking.dart';
import '../../domain/entities/staff_check_in_log.dart';
import '../../domain/entities/staff_review.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl({required StaffRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final StaffRemoteDataSource _remoteDataSource;

  @override
  Future<List<FitnessClass>> getStaffSchedule() {
    return _remoteDataSource.getStaffSchedule();
  }

  @override
  Future<List<StaffReview>> getStaffReviews() async {
    final bookingsFuture = _remoteDataSource.getCheckInCandidates();
    final classesFuture = _remoteDataSource.getStaffSchedule();
    final bookings = await bookingsFuture;
    final classes = await classesFuture;

    final branchIds = <String>{
      ...bookings.map((booking) => booking.branchId),
      ...classes.map((item) => item.branchId),
    }..removeWhere((id) => id.trim().isEmpty);

    final gymIds = <String>{};
    final gymResults = await Future.wait(
      branchIds.map(_remoteDataSource.getGymIdForBranch),
    );
    gymIds.addAll(gymResults.whereType<String>());

    final reviewGroups = await Future.wait(
      gymIds.map(_remoteDataSource.getGymReviews),
    );
    final reviewsById = <String, StaffReview>{};
    for (final reviews in reviewGroups) {
      for (final review in reviews) {
        reviewsById[review.reviewId] = review;
      }
    }

    final reviews = reviewsById.values.toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return List.unmodifiable(reviews);
  }

  @override
  Future<List<StaffBooking>> getCheckInCandidates() {
    return _remoteDataSource.getCheckInCandidates();
  }

  @override
  Future<List<StaffCheckInLog>> getManagerCheckInLogs() {
    return _remoteDataSource.getManagedCheckInLogs();
  }

  @override
  Future<StaffCheckInLog> checkInGym(StaffBooking booking) {
    return _remoteDataSource.checkInGym(bookingCode: booking.bookingCode);
  }

  @override
  Future<StaffCheckInLog> checkInClass(StaffBooking booking) {
    return _remoteDataSource.checkInClass(
      userId: booking.userId,
      classBookingId: booking.bookingId,
    );
  }

  @override
  Future<StaffDashboardSummary> getDashboardSummary({DateTime? now}) async {
    final bookingsFuture = _remoteDataSource.getCheckInCandidates();
    final logsFuture = _remoteDataSource.getManagedCheckInLogs();
    final classesFuture = _remoteDataSource.getStaffSchedule();
    final bookings = await bookingsFuture;
    final logs = await logsFuture;
    final classes = await classesFuture;
    final today = now ?? DateTime.now();

    final todayLogs = logs
        .where((log) => _isSameDay(log.scannedAt, today))
        .toList();
    final todayClasses =
        classes.where((item) => _isSameDay(item.startTime, today)).toList()
          ..sort(
            (first, second) => first.startTime.compareTo(second.startTime),
          );
    final recentLogs = [...logs]
      ..sort((first, second) => second.scannedAt.compareTo(first.scannedAt));
    final customerIds = bookings
        .map((booking) => booking.userId.toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    return StaffDashboardSummary(
      todayCheckInCount: todayLogs.length,
      relatedCustomerCount: customerIds.length,
      todayClassCount: todayClasses.length,
      membersInGym: null,
      recentCheckIns: recentLogs.take(5).toList(growable: false),
      todayClasses: todayClasses,
    );
  }

  bool _isSameDay(DateTime value, DateTime date) {
    return value.year == date.year &&
        value.month == date.month &&
        value.day == date.day;
  }
}
