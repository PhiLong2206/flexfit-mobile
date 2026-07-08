import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/staff_review.dart';
import '../providers/staff_reviews_provider.dart';

class StaffSupportPage extends StatelessWidget {
  const StaffSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StaffReviewsProvider>()..load(),
      child: const _ReviewsView(),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffReviewsProvider>();
    if (provider.isLoading && provider.visibleReviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.visibleReviews.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final reviews = provider.visibleReviews;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hỗ trợ & Đánh giá',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Theo dõi đánh giá từ hội viên',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<StaffReviewFilter>(
                    segments: const [
                      ButtonSegment(
                        value: StaffReviewFilter.all,
                        label: Text('Tất cả đánh giá'),
                        icon: Icon(Icons.reviews_rounded),
                      ),
                      ButtonSegment(
                        value: StaffReviewFilter.attention,
                        label: Text('Chú ý (1-2 sao)'),
                        icon: Icon(Icons.warning_amber_rounded),
                      ),
                    ],
                    selected: {provider.filter},
                    onSelectionChanged: (values) =>
                        provider.setFilter(values.first),
                  ),
                ],
              ),
            ),
          ),
          if (reviews.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 1100
                      ? 3
                      : constraints.crossAxisExtent >= 700
                      ? 2
                      : 1;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ReviewCard(review: reviews[index]),
                      childCount: reviews.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 245,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final StaffReview review;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: review.rating <= 2
              ? const Color(0xFF7F1D1D)
              : const Color(0xFF263244),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF163322),
                  child: Icon(Icons.person_rounded, color: Color(0xFF22C55E)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    review.userFullName.trim().isEmpty
                        ? 'Hội viên'
                        : review.userFullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _date(review.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _RatingStars(rating: review.rating),
            const SizedBox(height: 13),
            Expanded(
              child: Text(
                review.comment?.trim().isNotEmpty == true
                    ? review.comment!
                    : 'Hội viên không để lại nhận xét.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4, color: Color(0xFFCBD5E1)),
              ),
            ),
            const Divider(color: Color(0xFF263244)),
            Text(
              [
                    if (review.gymName?.trim().isNotEmpty == true)
                      review.gymName!,
                    if (review.className?.trim().isNotEmpty == true)
                      review.className!,
                  ].join(' • ').isEmpty
                  ? 'Chưa có thông tin dịch vụ'
                  : [
                      if (review.gymName?.trim().isNotEmpty == true)
                        review.gymName!,
                      if (review.className?.trim().isNotEmpty == true)
                        review.className!,
                    ].join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 20,
          color: const Color(0xFFF59E0B),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 56,
              color: Color(0xFF64748B),
            ),
            SizedBox(height: 14),
            Text(
              'Chưa có đánh giá phù hợp.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Kéo xuống để tải lại đánh giá từ các phòng gym được phân công.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không thể tải đánh giá',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
