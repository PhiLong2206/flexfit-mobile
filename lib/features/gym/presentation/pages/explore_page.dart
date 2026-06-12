import 'package:flutter/material.dart';

import '../../../booking/presentation/pages/gym_detail_page.dart';
import '../../../home/presentation/widgets/gym_card.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const Color _backgroundColor = Color(0xFF070B14);
  static const List<_ExploreGym> _gyms = [
    _ExploreGym(
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      name: 'FlexFit Elite Center',
      location: 'Quận 1, TP. Hồ Chí Minh',
      rating: 4.9,
      credits: 18,
    ),
    _ExploreGym(
      imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f',
      name: 'Peak Performance Studio',
      location: 'Cầu Giấy, Hà Nội',
      rating: 4.8,
      credits: 16,
    ),
    _ExploreGym(
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
      name: 'Urban Strength Club',
      location: 'Hải Châu, Đà Nẵng',
      rating: 4.7,
      credits: 14,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: _backgroundColor,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          itemCount: _gyms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final gym = _gyms[index];

            return GymCard(
              imageUrl: gym.imageUrl,
              name: gym.name,
              location: gym.location,
              rating: gym.rating,
              credits: gym.credits,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GymDetailPage(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ExploreGym {
  const _ExploreGym({
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
