import 'package:flutter/material.dart';

import '../widgets/category_section.dart';
import '../widgets/feature_section.dart';
import '../widgets/featured_gym_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_stats_row.dart';
import '../widgets/hero_banner.dart';
import '../../../../core/presentation/widgets/main_bottom_navigation_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';
  static const Color _backgroundColor = Color(0xFF070B14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 16),
              const HeroBanner(),
              const SizedBox(height: 24),
              const HomeQuickStatsRow(),
              const SizedBox(height: 24),

              const SizedBox(height: 28),
              const FeatureSection(),
              const SizedBox(height: 28),
              const CategorySection(),
              const SizedBox(height: 28),
              const FeaturedGymSection(),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(currentIndex: 0),
    );
  }
}
