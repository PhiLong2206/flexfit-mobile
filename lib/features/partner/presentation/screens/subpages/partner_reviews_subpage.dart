import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/partner_review_model.dart';
import '../../providers/partner_provider.dart';

class PartnerReviewsSubpage extends StatelessWidget {
  final PartnerProvider provider;

  const PartnerReviewsSubpage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final reviews = provider.reviews;

    // Calculate average rating
    double averageRating = 0;
    if (reviews.isNotEmpty) {
      final totalStars = reviews.fold<int>(0, (sum, review) => sum + review.rating);
      averageRating = totalStars / reviews.length;
    }

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => provider.fetchReviewsForAllGyms(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá từ hội viên',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Xem ý kiến đóng góp, số sao đánh giá từ khách hàng về các lớp học & cơ sở.',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Average rating widget
            _buildAverageRatingCard(averageRating, reviews.length),

            const SizedBox(height: 24),

            const Text(
              'Nhận xét mới nhất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildReviewsList(reviews, provider.isLoadingReviews),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRatingCard(double avg, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ĐÁNH GIÁ TRUNG BÌNH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      avg == 0 ? '0.0' : avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                  ],
                ),
              ],
            ),
          ),
          const VerticalDivider(color: AppConstants.borderColor, width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG SỐ ĐÁNH GIÁ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count nhận xét',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<PartnerReviewModel> reviews, bool isLoading) {
    if (isLoading && reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }
    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.rate_review, color: AppConstants.textSecondary, size: 40),
            SizedBox(height: 12),
            Text(
              'Chưa có lượt đánh giá nào.',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(review.createdAt);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name, Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                        radius: 16,
                        child: Text(
                          review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : 'H',
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        review.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Comment
              Text(
                review.comment.isEmpty ? '(Không để lại nhận xét)' : review.comment,
                style: TextStyle(
                  fontSize: 13,
                  color: review.comment.isEmpty ? Colors.grey : Colors.white,
                  fontStyle: review.comment.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 10),

              // Footer: Date & Target Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${review.gymName} ${review.className.isNotEmpty ? "• Lớp: ${review.className}" : ""}',
                      style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
