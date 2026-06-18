import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/workout_notifier.dart';

class WorkoutStatisticsPage extends StatefulWidget {
  const WorkoutStatisticsPage({super.key});

  @override
  State<WorkoutStatisticsPage> createState() => _WorkoutStatisticsPageState();
}

class _WorkoutStatisticsPageState extends State<WorkoutStatisticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutNotifier>().fetchStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<WorkoutNotifier>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Thống Kê Thể Chất',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _buildContent(notifier),
      ),
    );
  }

  Widget _buildContent(WorkoutNotifier notifier) {
    if (notifier.isLoading && notifier.statistics == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (notifier.error != null && notifier.statistics == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.cancelled, size: 48),
              const SizedBox(height: 12),
              Text(
                'Lỗi: ${notifier.error}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => notifier.fetchStatistics(),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = notifier.statistics;
    if (stats == null) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu thống kê.',
          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchStatistics(),
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Tổng số buổi',
                    value: stats.totalWorkouts.toString(),
                    icon: Icons.fitness_center_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    title: 'Tổng thời gian',
                    value: '${stats.totalMinutes}ph',
                    icon: Icons.timer_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _StatCard(
              title: 'Lượng calo tiêu thụ',
              value: '${stats.totalCalories.toStringAsFixed(0)} kcal',
              icon: Icons.local_fire_department_outlined,
              color: AppColors.primary,
              fullWidth: true,
            ),
            const SizedBox(height: 28),
            // Weekly completion rate indicator
            const Text(
              'Tỷ lệ hoàn thành tuần này',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CircularProgressIndicator(
                          value: stats.weeklyCompletionRate / 100.0,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${stats.weeklyCompletionRate.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mục tiêu tuần',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stats.weeklyCompletionRate >= 100
                              ? 'Tuyệt vời! Bạn đã hoàn thành 100% mục tiêu tập luyện tuần này!'
                              : 'Cố lên! Bạn đã đạt ${stats.weeklyCompletionRate.toStringAsFixed(0)}% chỉ tiêu tập luyện. Hãy giữ vững phong độ!',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Weekly progress visual tracker
            const Text(
              'Tiến độ mục tiêu hàng tuần',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  _ProgressBarRow(label: 'Tập luyện (Buổi)', completed: stats.totalWorkouts, target: 5, color: Colors.blue),
                  const SizedBox(height: 18),
                  _ProgressBarRow(label: 'Thời gian (Phút)', completed: stats.totalMinutes, target: 200, color: Colors.green),
                  const SizedBox(height: 18),
                  _ProgressBarRow(label: 'Năng lượng (Calo)', completed: stats.totalCalories.round(), target: 1500, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBarRow extends StatelessWidget {
  final String label;
  final int completed;
  final int target;
  final Color color;

  const _ProgressBarRow({
    required this.label,
    required this.completed,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$completed / $target',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            color: color,
          ),
        ),
      ],
    );
  }
}
