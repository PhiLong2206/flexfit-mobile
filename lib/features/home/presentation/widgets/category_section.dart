import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      icon: Icons.fitness_center_rounded,
      title: 'Gym',
      subtitle: '10 địa điểm',
    ),
    _CategoryItem(
      icon: Icons.sports_tennis_rounded,
      title: 'Cầu lông',
      subtitle: '8 sân',
    ),
    _CategoryItem(
      icon: Icons.sports_tennis_rounded,
      title: 'Tennis',
      subtitle: '5 sân',
    ),
    _CategoryItem(
      icon: Icons.self_improvement_rounded,
      title: 'Yoga',
      subtitle: '6 lớp',
    ),
    _CategoryItem(
      icon: Icons.sports_mma_rounded,
      title: 'Boxing',
      subtitle: '4 lớp',
    ),
    _CategoryItem(
      icon: Icons.pool_rounded,
      title: 'Bơi lội',
      subtitle: '3 hồ bơi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khám phá loại hình',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 112,
          child: ListView.separated(
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, separatorIndex) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _CategoryCard(category: _categories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _CategoryItem category;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 92,
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(category.icon, color: _primaryOrange, size: 19),
          ),
          Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          Text(
            category.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              fontSize: 9.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
