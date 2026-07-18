import 'package:flutter/material.dart';

import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../partner/data/models/partner_review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_theme.dart';
import '../widgets/gym_image_slider.dart';
import '../widgets/gym_info_card.dart';
import '../widgets/gym_time_slot_sheet.dart';
import 'booking_confirmation_page.dart';

class GymDetailPage extends StatefulWidget {
  const GymDetailPage({super.key, this.gymId});

  final String? gymId;

  @override
  State<GymDetailPage> createState() => _GymDetailPageState();
}

class _GymDetailPageState extends State<GymDetailPage> {
  static const _fallbackImages = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
  ];

  final _repository = CatalogRepository();
  final _reviewRepository = ReviewRepository();
  Future<_GymDetailData>? _future;

  @override
  void initState() {
    super.initState();
    final id = widget.gymId;
    if (id != null) {
      _future = _load(id);
    }
  }

  Future<_GymDetailData> _load(String gymId) async {
    final gym = await _repository.getGymById(gymId);
    final branches = await _repository.getBranches();
    final reviews = await _reviewRepository.getReviewsForGym(gymId);
    return _GymDetailData(gym: gym, branches: branches, reviews: reviews);
  }

  void _reload() {
    final id = widget.gymId;
    if (id != null) {
      setState(() {
        _future = _load(id);
      });
    }
  }

  Future<void> _selectTimeAndContinue(Gym gym, Branch branch) async {
    final selection = await showGymTimeSlotSheet(
      context: context,
      gymName: gym.name,
      branch: branch,
    );
    if (!mounted || selection == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingConfirmationPage(
          gymName: gym.name,
          address: selection.branch.displayAddress,
          branchName: selection.branch.name,
          rating: gym.ratingAverage,
          creditCost: selection.branch.creditCost,
          branchId: selection.branch.id,
          startTime: selection.startTime,
          endTime: selection.endTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) {
      return const _GymDetailScaffold(
        child: _StateMessage(
          title: 'Thiếu mã phòng gym',
          message: 'Hãy mở trang này từ thẻ phòng gym để tải chi tiết.',
        ),
      );
    }

    return FutureBuilder<_GymDetailData>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _GymDetailScaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _GymDetailScaffold(
            child: _StateMessage(
              title: 'Không tải được phòng gym',
              message: snapshot.error.toString(),
              onRetry: _reload,
            ),
          );
        }

        final data = snapshot.data!;
        final gym = data.gym;
        final branch = data.primaryBranch;
        final reviews = data.reviews;
        final images = [
          if (branch?.thumbnailUrl != null) branch!.thumbnailUrl!,
          if (gym.thumbnailUrl != null) gym.thumbnailUrl!,
          ..._fallbackImages,
        ];

        return Scaffold(
          backgroundColor: BookingTheme.background,
          bottomNavigationBar: BookingBottomBar(
            creditCost: branch?.creditCost ?? 0,
            onPressed: branch == null
                ? null
                : () => _selectTimeAndContinue(gym, branch),
          ),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: GymImageSlider(images: images)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      sliver: SliverToBoxAdapter(
                        child: GymInfoCard(
                          name: gym.name,
                          address:
                              branch?.displayAddress ??
                              gym.description ??
                              gym.email ??
                              gym.status,
                          rating: gym.ratingAverage,
                          creditCost: branch?.creditCost ?? 0,
                          openingHours: _openingHoursLabel(branch),
                          duration: '60 phút',
                          description: gym.description ?? 'Chưa có mô tả.',
                          amenities: [
                            if (branch != null) branch.name,
                            if (gym.phoneNumber != null) gym.phoneNumber!,
                            if (gym.email != null) gym.email!,
                            '${gym.totalReviews} đánh giá',
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverToBoxAdapter(
                        child: _ReviewsSection(reviews: reviews),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 12,
                  left: 16,
                  child: _FloatingBackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GymDetailData {
  const _GymDetailData({required this.gym, required this.branches, required this.reviews});

  final Gym gym;
  final List<Branch> branches;
  final List<PartnerReviewModel> reviews;

  Branch? get primaryBranch {
    return CatalogRepository().resolveBranchForGym(gym, branches);
  }
}

class _GymDetailScaffold extends StatelessWidget {
  const _GymDetailScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      appBar: AppBar(backgroundColor: BookingTheme.background, elevation: 0),
      body: child,
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.reviews});

  final List<PartnerReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BookingTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BookingTheme.border),
        ),
        child: const Center(
          child: Text(
            'Chưa có đánh giá nào cho phòng tập này.',
            style: TextStyle(color: BookingTheme.secondaryText, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BookingTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BookingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đánh giá từ hội viên',
                style: TextStyle(
                  color: BookingTheme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${reviews.length} đánh giá',
                style: const TextStyle(
                  color: BookingTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => Divider(color: BookingTheme.border, height: 24),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final dateStr = '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(
                          color: BookingTheme.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: BookingTheme.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: starIdx < review.rating ? const Color(0xFFFFC857) : Colors.white24,
                      );
                    }),
                  ),
                  if (review.comment.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      style: const TextStyle(
                        color: BookingTheme.secondaryText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: BookingTheme.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BookingTheme.secondaryText),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ],
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(125),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
        color: BookingTheme.text,
        tooltip: 'Quay lại',
      ),
    );
  }
}

String _openingHoursLabel(Branch? branch) {
  final open = _formatApiTime(branch?.openTime) ?? '05:00';
  final close = _formatApiTime(branch?.closeTime) ?? '22:00';
  return '$open - $close';
}

String? _formatApiTime(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final parts = value.split(':');
  if (parts.length < 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
