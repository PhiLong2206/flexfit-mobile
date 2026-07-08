import 'package:flutter/material.dart';

import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/category.dart' as catalog;

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final _repository = CatalogRepository();
  late Future<List<catalog.Category>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getCategories();
  }

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
          child: FutureBuilder<List<catalog.Category>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? const <catalog.Category>[];
              if (snapshot.hasError || categories.isEmpty) {
                return const _CategoryCard(
                  category: _CategoryItem(
                    icon: Icons.fitness_center_rounded,
                    title: 'FlexFit',
                    subtitle: 'Không có danh mục',
                  ),
                );
              }
              return ListView.separated(
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    category: _CategoryItem(
                      icon: _iconFor(category.name),
                      title: category.name,
                      subtitle: category.description ?? 'Danh mục lớp học',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('yoga')) return Icons.self_improvement_rounded;
    if (lower.contains('box')) return Icons.sports_mma_rounded;
    if (lower.contains('swim') || lower.contains('boi')) {
      return Icons.pool_rounded;
    }
    return Icons.fitness_center_rounded;
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
