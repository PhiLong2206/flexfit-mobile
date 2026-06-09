import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.flash_on_rounded,
      title: 'Đặt chỗ tức thì',
      subtitle: 'Giữ lịch tập trong vài thao tác.',
    ),
    _FeatureItem(
      icon: Icons.verified_rounded,
      title: 'Bảo đảm chất lượng',
      subtitle: 'Địa điểm được chọn lọc kỹ lưỡng.',
    ),
    _FeatureItem(
      icon: Icons.schedule_rounded,
      title: 'Linh hoạt giờ giấc',
      subtitle: 'Chủ động chọn khung giờ phù hợp.',
    ),
    _FeatureItem(
      icon: Icons.calendar_month_rounded,
      title: 'Theo dõi lịch tập',
      subtitle: 'Quản lý buổi tập và nhắc lịch.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiện ích nổi bật',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 132,
          child: ListView.separated(
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _features.length,
            separatorBuilder: (_, separatorIndex) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final feature = _features[index];

              return _FeatureCard(feature: feature);
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _FeatureItem feature;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 156,
      height: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: _primaryOrange, size: 21),
          ),
          const Spacer(),
          Text(
            feature.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            feature.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
