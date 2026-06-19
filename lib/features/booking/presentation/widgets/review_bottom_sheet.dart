import 'package:flutter/material.dart';

import '../../../../core/services/api_client.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/review_repository.dart';
import 'booking_theme.dart';

enum ReviewSheetResult { submitted, alreadyReviewed }

class ReviewBottomSheet extends StatefulWidget {
  const ReviewBottomSheet({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final _repository = ReviewRepository();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await _repository.createReview(
        booking: widget.booking,
        rating: _rating,
        comment: _commentController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(ReviewSheetResult.submitted);
    } catch (error) {
      if (!mounted) return;
      if (_isAlreadyReviewedError(error)) {
        Navigator.of(context).pop(ReviewSheetResult.alreadyReviewed);
        return;
      }
      setState(() => _error = _friendlyReviewError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: BookingTheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Đánh giá buổi tập',
                style: TextStyle(
                  color: BookingTheme.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.booking.gymName ?? widget.booking.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BookingTheme.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 1; index <= 5; index++)
                    IconButton(
                      tooltip: '$index sao',
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() => _rating = index),
                      icon: Icon(
                        index <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFC857),
                        size: 36,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 5,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  color: BookingTheme.text,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn',
                  hintStyle: const TextStyle(color: BookingTheme.secondaryText),
                  filled: true,
                  fillColor: BookingTheme.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BookingTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BookingTheme.primary),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.rate_review_rounded),
                  label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _friendlyReviewError(Object error) {
  final message = error is ApiException ? error.message : error.toString();
  if (_isAlreadyReviewedError(error)) {
    return 'Lịch này đã được đánh giá trước đó.';
  }
  if (_isCheckInRequiredError(error)) {
    return 'Bạn chỉ có thể đánh giá sau khi buổi tập đã hoàn thành.';
  }
  return message;
}

bool _isAlreadyReviewedError(Object error) {
  final message = error is ApiException ? error.message : error.toString();
  final normalized = message.toLowerCase();
  return normalized.contains('đã được') ||
      normalized.contains('danh gia truoc') ||
      normalized.contains('already') ||
      normalized.contains('1 lần');
}

bool _isCheckInRequiredError(Object error) {
  final message = error is ApiException ? error.message : error.toString();
  final normalized = message.toLowerCase();
  return normalized.contains('check') || normalized.contains('completed');
}
