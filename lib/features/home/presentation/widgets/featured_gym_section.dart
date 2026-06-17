import 'package:flutter/material.dart';

import '../../../booking/presentation/pages/gym_detail_page.dart';
import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../gym/presentation/pages/explore_page.dart';
import 'gym_card.dart';

class FeaturedGymSection extends StatefulWidget {
  const FeaturedGymSection({super.key});

  @override
  State<FeaturedGymSection> createState() => _FeaturedGymSectionState();
}

class _FeaturedGymSectionState extends State<FeaturedGymSection> {
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48';

  final _repository = CatalogRepository();
  late Future<List<Gym>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getGyms();
  }

  void _reload() {
    setState(() => _future = _repository.getGyms());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Địa điểm nổi bật',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExplorePage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B16),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: FutureBuilder<List<Gym>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _InlineState(
                  title: 'Không tải được phòng tập',
                  actionLabel: 'Thử lại',
                  onPressed: _reload,
                );
              }
              final gyms = (snapshot.data ?? const <Gym>[]).take(6).toList();
              if (gyms.isEmpty) {
                return _InlineState(
                  title: 'Chưa có phòng tập nổi bật',
                  actionLabel: 'Làm mới',
                  onPressed: _reload,
                );
              }

              return ListView.separated(
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: gyms.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final gym = gyms[index];
                  return GymCard(
                    imageUrl: gym.thumbnailUrl ?? _fallbackImage,
                    name: gym.name,
                    location: gym.description ?? gym.status,
                    rating: gym.ratingAverage,
                    credits: 0,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GymDetailPage(gymId: gym.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
