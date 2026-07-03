import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/main_bottom_navigation_bar.dart';

import '../../../gym/presentation/screens/explore_page.dart';
import '../../../ai/presentation/widgets/ai_coach_popup.dart';
import '../../../ai/presentation/widgets/ai_suggestion_card.dart';
import '../widgets/upcoming_schedule_widget.dart';
import '../widgets/home_quick_stats_row.dart'; // We can reuse stats or build custom credit summary

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const String routeName = '/overview';
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
              const _OverviewHeader(),
              const SizedBox(height: 24),
              const HomeQuickStatsRow(), // Giữ nguyên HomeQuickStatsRow cho Credit Summary và Số lớp
              const SizedBox(height: 28),
              const UpcomingScheduleWidget(),
              const SizedBox(height: 28),
              const AiSuggestionCard(),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(currentIndex: 1),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chào Adam, sẵn sàng tập luyện chưa?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFF111827),
              child: Text('AD', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B16).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFFFF6B16),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFF6B16)),
                  ),
                ),
                onPressed: () {
                  AiCoachPopup.show(context);
                },
                icon: const Icon(Icons.smart_toy_rounded, size: 20),
                label: const Text('AI Coach', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B16),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExplorePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 20),
                label: const Text('Đặt lịch ngay', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
