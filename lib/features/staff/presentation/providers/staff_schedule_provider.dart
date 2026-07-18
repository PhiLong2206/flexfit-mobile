import 'package:flutter/foundation.dart';

import '../../../catalog/domain/entities/fitness_class.dart';
import '../../domain/repositories/staff_repository.dart';

enum StaffScheduleFilter { today, upcoming, all }

class StaffScheduleProvider extends ChangeNotifier {
  StaffScheduleProvider({required StaffRepository repository})
    : _repository = repository;

  final StaffRepository _repository;

  List<FitnessClass> _classes = const [];
  StaffScheduleFilter _filter = StaffScheduleFilter.today;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  StaffScheduleFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FitnessClass> get visibleClasses {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final normalizedQuery = _query.trim().toLowerCase();

    final result =
        _classes.where((item) {
          final matchesSearch =
              normalizedQuery.isEmpty ||
              item.name.toLowerCase().contains(normalizedQuery);
          if (!matchesSearch) return false;

          switch (_filter) {
            case StaffScheduleFilter.today:
              return !item.startTime.isBefore(startOfToday) &&
                  item.startTime.isBefore(startOfTomorrow);
            case StaffScheduleFilter.upcoming:
              return !item.startTime.isBefore(startOfTomorrow);
            case StaffScheduleFilter.all:
              return true;
          }
        }).toList()..sort(
          (first, second) => first.startTime.compareTo(second.startTime),
        );
    return List.unmodifiable(result);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _classes = await _repository.getStaffSchedule();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  void setFilter(StaffScheduleFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}
