import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_storage.dart';
import '../../../booking/presentation/pages/booking_history_page.dart';
import '../../../workout/presentation/pages/workout_history_page.dart';
import '../../../workout/presentation/pages/workout_statistics_page.dart';
import '../../data/profile_notifier.dart';
import '../widgets/health_goal_form.dart';
import '../widgets/personal_info_form.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileNotifier>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // App bar with back button
                    SliverAppBar(
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      pinned: true,
                      floating: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        tooltip: 'Quay lại',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    // Header content that scrolls away
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hồ Sơ & Cài Đặt',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Quản lý thông tin cá nhân và tùy chọn của bạn.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const ProfileHeader(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    // Persistent TabBar header
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        const TabBar(
                          dividerColor: Colors.transparent,
                          indicatorColor: AppColors.primary,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: [
                            Tab(text: 'Cá nhân'),
                            Tab(text: 'Sức khỏe'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 14, bottom: 32),
                      child: Column(
                        children: [
                          const PersonalInfoForm(),
                          const SizedBox(height: 20),
                          _ProfileMenuCard(),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 14, bottom: 32),
                      child: Column(
                        children: [
                          const HealthGoalForm(),
                          const SizedBox(height: 20),
                          _ProfileMenuCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class _ProfileMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: const Text(
              'Lịch sử đặt lịch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BookingHistoryPage(),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: const Text(
              'Lịch sử tập luyện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WorkoutHistoryPage(),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.green,
                size: 20,
              ),
            ),
            title: const Text(
              'Thống kê thể chất',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WorkoutStatisticsPage(),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cancelled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.cancelled,
                size: 20,
              ),
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.cancelled,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              await LocalStorage.removeToken();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
