import 'package:flutter/foundation.dart';

import '../../domain/entities/staff_review.dart';
import '../../domain/repositories/staff_repository.dart';

enum StaffReviewFilter { all, attention }

class StaffReviewsProvider extends ChangeNotifier {
  StaffReviewsProvider({required StaffRepository repository})
    : _repository = repository;

  final StaffRepository _repository;

  List<StaffReview> _reviews = const [];
  StaffReviewFilter _filter = StaffReviewFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  StaffReviewFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<StaffReview> get visibleReviews {
    if (_filter == StaffReviewFilter.all) return List.unmodifiable(_reviews);
    return List.unmodifiable(
      _reviews.where((review) => review.rating >= 1 && review.rating <= 2),
    );
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _repository.getStaffReviews();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  void setFilter(StaffReviewFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }
}
