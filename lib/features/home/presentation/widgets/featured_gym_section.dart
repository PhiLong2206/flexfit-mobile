import 'package:flutter/material.dart';

import 'gym_card.dart';

class FeaturedGymSection extends StatelessWidget {
  const FeaturedGymSection({super.key});

  static const List<_FeaturedGym> _gyms = [
    _FeaturedGym(
      imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f',
      name: 'FlexFit Elite Center',
      location: 'Quận 1, TP. Hồ Chí Minh',
      rating: 4.9,
      credits: 18,
    ),
    _FeaturedGym(
      imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f',
      name: 'Peak Performance Studio',
      location: 'Cầu Giấy, Hà Nội',
      rating: 4.8,
      credits: 16,
    ),
    _FeaturedGym(
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd',
      name: 'Urban Strength Club',
      location: 'Hải Châu, Đà Nẵng',
      rating: 4.7,
      credits: 14,
    ),
  ];

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
              onPressed: () {},
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
          child: ListView.separated(
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _gyms.length,
            separatorBuilder: (_, separatorIndex) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final gym = _gyms[index];

              return GymCard(
                imageUrl: gym.imageUrl,
                name: gym.name,
                location: gym.location,
                rating: gym.rating,
                credits: gym.credits,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedGym {
  const _FeaturedGym({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.credits,
  });

  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final int credits;
}
