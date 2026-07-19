import 'package:flutter/foundation.dart';

import '../../domain/entities/staff_booking.dart';
import '../../domain/entities/staff_check_in_log.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffCheckInProvider extends ChangeNotifier {
  StaffCheckInProvider({required StaffRepository repository})
    : _repository = repository;

  final StaffRepository _repository;

  List<StaffBooking> _candidates = const [];
  List<StaffCheckInLog> _todayLogs = const [];
  StaffBooking? _selectedBooking;
  bool _isLoading = false;
  bool _isCheckingIn = false;
  String? _errorMessage;
  String? _successMessage;

  List<StaffBooking> get candidates => List.unmodifiable(_candidates);
  List<StaffCheckInLog> get todayLogs => List.unmodifiable(_todayLogs);
  StaffBooking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadCandidates() async {
    _setLoading(true);
    try {
      _candidates = await _repository.getCheckInCandidates();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayLogs() async {
    _setLoading(true);
    try {
      final logs = await _repository.getManagerCheckInLogs();
      _todayLogs = _filterTodaySuccessful(logs);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void lookupBooking(String code) {
    final normalized = code.trim().toLowerCase();
    _selectedBooking = null;
    _successMessage = null;
    if (normalized.isEmpty) {
      _errorMessage = 'Vui lòng nhập mã đặt lịch.';
      notifyListeners();
      return;
    }

    for (final booking in _candidates) {
      final matchesBookingCode =
          booking.bookingCode.trim().toLowerCase() == normalized;
      final matchesQrToken =
          booking.qrToken?.trim().toLowerCase() == normalized;
      if (matchesBookingCode || matchesQrToken) {
        _selectedBooking = booking;
        _errorMessage = null;
        notifyListeners();
        return;
      }
    }
    _errorMessage = 'Không tìm thấy mã đặt lịch tại chi nhánh được phân công.';
    notifyListeners();
  }

  Future<bool> checkInSelectedBooking() async {
    final booking = _selectedBooking;
    if (booking == null || _isCheckingIn) return false;
    if (booking.isCheckedIn) {
      _errorMessage = 'Lịch đặt này đã được check-in.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _isCheckingIn = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      if (booking.isClassBooking) {
        await _repository.checkInClass(booking);
      } else {
        await _repository.checkInGym(booking);
      }
      _successMessage = 'Check-in khách hàng thành công.';
      await refresh(preserveMessage: true);
      _selectedBooking = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isCheckingIn = false;
      notifyListeners();
    }
  }

  Future<void> refresh({bool preserveMessage = false}) async {
    _setLoading(true);
    if (!preserveMessage) {
      _successMessage = null;
      _errorMessage = null;
    }
    try {
      final candidatesFuture = _repository.getCheckInCandidates();
      final logsFuture = _repository.getManagerCheckInLogs();
      _candidates = await candidatesFuture;
      _todayLogs = _filterTodaySuccessful(await logsFuture);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearLookup() {
    _selectedBooking = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  List<StaffCheckInLog> _filterTodaySuccessful(Iterable<StaffCheckInLog> logs) {
    final now = DateTime.now();
    final result =
        logs.where((log) {
          final isToday =
              log.scannedAt.year == now.year &&
              log.scannedAt.month == now.month &&
              log.scannedAt.day == now.day;
          return isToday && log.status.trim().toLowerCase() == 'success';
        }).toList()..sort(
          (first, second) => second.scannedAt.compareTo(first.scannedAt),
        );
    return result;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
