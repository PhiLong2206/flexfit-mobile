import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../presentation/providers/upcoming_schedule_provider.dart';
import '../../../gym/presentation/screens/explore_page.dart';

class UpcomingScheduleWidget extends StatelessWidget {
  const UpcomingScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpcomingScheduleProvider(sl())..fetchUpcomingBookings(),
      child: const _UpcomingScheduleWidgetContent(),
    );
  }
}

class _UpcomingScheduleWidgetContent extends StatelessWidget {
  const _UpcomingScheduleWidgetContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpcomingScheduleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch tập tiếp theo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: _buildContent(provider),
        ),
      ],
    );
  }

  Widget _buildContent(UpcomingScheduleProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFFFF6B16)),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (provider.upcomingBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn chưa có lịch tập sắp tới.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) => FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B16).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFFFF6B16),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (_) => const ExplorePage()),
                  );
                },
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text('Khám phá ngay'),
              ),
            ),
          ],
        ),
      );
    }

    final nextBooking = provider.upcomingBookings.first;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B16).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_month, color: Color(0xFFFF6B16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextBooking.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${timeFormat.format(nextBooking.startTime)} - ${dateFormat.format(nextBooking.startTime)}',
                style: const TextStyle(color: Color(0xFFFF6B16), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              if (nextBooking.branchName != null) ...[
                const SizedBox(height: 4),
                Text(
                  nextBooking.branchName!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

