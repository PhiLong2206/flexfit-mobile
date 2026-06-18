import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../review/data/review_notifier.dart';
import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_theme.dart';
import '../widgets/gym_image_slider.dart';
import '../widgets/gym_info_card.dart';
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
  Future<Gym>? _future;

  @override
  void initState() {
    super.initState();
    final id = widget.gymId;
    if (id != null) {
      _future = _repository.getGymById(id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReviewNotifier>().fetchGymReviews(id);
      });
    }
  }

  void _reload() {
    final id = widget.gymId;
    if (id != null) {
      setState(() => _future = _repository.getGymById(id));
    }
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

    return FutureBuilder<Gym>(
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

        final gym = snapshot.data!;
        final images = [
          if (gym.thumbnailUrl != null) gym.thumbnailUrl!,
          ..._fallbackImages,
        ];

        return Scaffold(
          backgroundColor: BookingTheme.background,
          bottomNavigationBar: BookingBottomBar(
            creditCost: 0,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookingConfirmationPage(
                    gymName: gym.name,
                    address: gym.description ?? gym.status,
                    rating: gym.ratingAverage,
                    creditCost: 0,
                    // TODO: Pass a real BranchId once the mobile flow exposes
                    // branches. POST /api/bookings/gym requires BranchId, but
                    // GET /api/gyms and GET /api/gyms/{id} only return GymDto.
                    branchId: null,
                  ),
                ),
              );
            },
          ),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: GymImageSlider(images: images)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverToBoxAdapter(
                        child: GymInfoCard(
                          name: gym.name,
                          address: gym.description ?? gym.status,
                          rating: gym.ratingAverage,
                          creditCost: 0,
                          openingHours: 'Xem lịch chi nhánh',
                          duration: '60 phút',
                          description: gym.description ?? 'Chưa có mô tả.',
                          amenities: [
                            if (gym.phoneNumber != null) gym.phoneNumber!,
                            if (gym.email != null) gym.email!,
                            '${gym.totalReviews} đánh giá',
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverToBoxAdapter(
                        child: Consumer<ReviewNotifier>(
                          builder: (context, reviewNotifier, child) {
                            if (reviewNotifier.isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(color: BookingTheme.primary),
                                ),
                              );
                            }
                            final list = reviewNotifier.reviews;
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
                                  const Text(
                                    'Đánh giá từ hội viên',
                                    style: TextStyle(
                                      color: BookingTheme.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (list.isEmpty)
                                    const Text(
                                      'Chưa có đánh giá nào cho phòng tập này.',
                                      style: TextStyle(
                                        color: BookingTheme.secondaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: list.length,
                                      separatorBuilder: (_, __) => Divider(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        height: 24,
                                      ),
                                      itemBuilder: (context, idx) {
                                        final rev = list[idx];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 32,
                                                  width: 32,
                                                  decoration: BoxDecoration(
                                                    color: BookingTheme.primary.withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    rev.userFullName.isNotEmpty ? rev.userFullName[0].toUpperCase() : 'F',
                                                    style: const TextStyle(
                                                      color: BookingTheme.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        rev.userFullName,
                                                        style: const TextStyle(
                                                          color: BookingTheme.text,
                                                          fontWeight: FontWeight.w800,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${rev.createdAt.day}/${rev.createdAt.month}/${rev.createdAt.year}',
                                                        style: const TextStyle(
                                                          color: BookingTheme.secondaryText,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: List.generate(5, (sIdx) {
                                                    return Icon(
                                                      sIdx < rev.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                                      color: const Color(0xFFFFC857),
                                                      size: 14,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 42),
                                              child: Text(
                                                rev.comment,
                                                style: const TextStyle(
                                                  color: BookingTheme.text,
                                                  fontSize: 13,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
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

class _GymDetailScaffold extends StatelessWidget {
  const _GymDetailScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      appBar: AppBar(backgroundColor: BookingTheme.background),
      body: child,
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
