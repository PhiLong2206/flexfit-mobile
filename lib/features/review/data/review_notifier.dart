import 'package:flutter/material.dart';
import 'models/review_model.dart';
import 'repositories/review_repository.dart';

class ReviewNotifier extends ChangeNotifier {
  final _repository = ReviewRepository();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGymReviews(String gymId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _repository.getGymReviews(gymId);
      _reviews = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewModel> submitReview({
    required String gymId,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReview = await _repository.submitReview(
        gymId: gymId,
        rating: rating,
        comment: comment,
      );
      // Insert new review at beginning
      _reviews = [newReview, ..._reviews];
      return newReview;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
