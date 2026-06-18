import 'package:flutter/material.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/pages/my_bookings_page.dart';
import '../../../booking/presentation/pages/booking_history_page.dart';
import '../../../gym/presentation/pages/explore_page.dart';
import '../../../membership/data/repositories/credit_repository.dart';
import '../../../membership/data/models/credit_package_model.dart';
import '../../../membership/presentation/pages/membership_page.dart';
import '../../../../core/services/local_storage.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../ai/data/models/ai_suggestion_model.dart';
import '../../../ai/data/repositories/ai_repository.dart';
import '../../../ai/presentation/pages/ai_chat_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _creditRepository = CreditRepository();
  final _bookingRepository = BookingRepository();
  final _aiRepository = AiRepository();

  late Future<UserCreditModel> _creditFuture;
  late Future<List<BookingModel>> _bookingsFuture;
  late Future<WorkoutSuggestionModel> _workoutSuggestionFuture;
  late Future<ClassSuggestionModel> _classSuggestionFuture;
  String _displayName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _creditFuture = _creditRepository.getMyCredit();
      _bookingsFuture = _bookingRepository.getMyBookings();
      _workoutSuggestionFuture = _aiRepository.getSuggestWorkout();
      _classSuggestionFuture = _aiRepository.getSuggestClasses();
    });
    _loadUserDisplayName();
  }

  Future<void> _loadUserDisplayName() async {
    // Attempt to parse user display name or fallback
    final name = await LocalStorage.getUserIdFromToken();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _displayName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            RefreshIndicator(
              color: const Color(0xFFFF6B16),
              onRefresh: () async {
                _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(textTheme),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 28),
                    _buildUpcomingSchedule(textTheme),
                    const SizedBox(height: 28),
                    _buildAiSuggestionsSection(textTheme),
                  ],
                ),
              ),
            ),
            _buildAiChatFloatingButton(),
          ],
        ),
      ),
      bottomNavigationBar: const _DashboardBottomNavigationBar(),
    );
  }

  Widget _buildTopHeader(TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bảng điều khiển',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chào mừng trở lại, $_displayName. Sẵn sàng tập luyện chưa?',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOutlinedHeaderButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI Coach',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AiChatPage()),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildFilledHeaderButton(
              label: 'Đặt lịch ngay',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExplorePage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlinedHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3647)),
          color: const Color(0xFF111827),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFF6B16), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledHeaderButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B16), Color(0xFFFF8C42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B16).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return FutureBuilder<UserCreditModel>(
      future: _creditFuture,
      builder: (context, creditSnapshot) {
        return FutureBuilder<List<BookingModel>>(
          future: _bookingsFuture,
          builder: (context, bookingsSnapshot) {
            final credit = creditSnapshot.data?.balance ?? 0;
            final hasCreditError = creditSnapshot.hasError;
            
            final totalBookings = bookingsSnapshot.data?.length ?? 0;

            return Row(
              children: [
                Expanded(
                  child: _buildCreditCard(
                    credit: credit,
                    isLoading: creditSnapshot.connectionState == ConnectionState.waiting,
                    hasError: hasCreditError,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildBookedClassesCard(
                    count: totalBookings,
                    isLoading: bookingsSnapshot.connectionState == ConnectionState.waiting,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCreditCard({
    required int credit,
    required bool isLoading,
    required bool hasError,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B263B),
            const Color(0xFF111827).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credit hiện có',
                style: textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFFF6B16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.credit_card_rounded, color: Color(0xFFFF6B16), size: 18),
            ],
          ),
          const Spacer(),
          Text(
            isLoading ? '...' : (hasError ? '---' : '$credit'),
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 34,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gia hạn trong 12 ngày tới',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MembershipPage()),
                  );
                },
                child: Text(
                  'Nạp thêm',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFF6B16),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookedClassesCard({
    required int count,
    required bool isLoading,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lớp đã tham gia',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white38, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            isLoading ? '...' : '$count',
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 34,
            ),
          ),
          const Spacer(),
          Text(
            'Tổng số buổi đã đăng ký',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSchedule(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch trình sắp tới',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.calendar_month_rounded, color: Colors.white38, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<BookingModel>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B16))),
                  ),
                );
              }
              final upcoming = (snapshot.data ?? [])
                  .where((b) => b.startTime.isAfter(DateTime.now()) && b.status.toLowerCase() != 'cancelled')
                  .toList();

              if (upcoming.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Không có lịch trình sắp tới',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white38),
                    ),
                  ),
                );
              }

              // Show the earliest upcoming booking
              final booking = upcoming.first;
              final isGym = booking.type == BookingType.gym;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B16),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.title,
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${booking.startTime.day}/${booking.startTime.month}, ${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')}',
                                  style: textTheme.labelSmall?.copyWith(color: Colors.white38),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on_rounded, color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    booking.subtitle ?? booking.gymName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelSmall?.copyWith(color: Colors.white38),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isGym ? 'Gym' : 'Lớp',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const MyBookingsPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: const Text(
                        'Xem toàn bộ lịch',
                        style: TextStyle(
                          color: Color(0xFFFF6B16),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionsSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF6B16), size: 18),
            const SizedBox(width: 8),
            Text(
              'AI Gợi ý cho bạn',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AiChatPage()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'AI Coach',
                    style: textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFFF6B16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF6B16), size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<WorkoutSuggestionModel>(
          future: _workoutSuggestionFuture,
          builder: (context, workoutSnapshot) {
            return FutureBuilder<ClassSuggestionModel>(
              future: _classSuggestionFuture,
              builder: (context, classSnapshot) {
                final workoutSuggestion = workoutSnapshot.data;
                final classSuggestion = classSnapshot.data;

                final isWorkoutLoading = workoutSnapshot.connectionState == ConnectionState.waiting;
                final isClassLoading = classSnapshot.connectionState == ConnectionState.waiting;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildAiSuggestionCard(
                        title: workoutSuggestion?.title ?? 'Gợi ý lịch tập hôm nay',
                        icon: Icons.fitness_center_rounded,
                        description: workoutSuggestion?.description ?? '',
                        points: workoutSuggestion?.points ?? [],
                        isLoading: isWorkoutLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAiSuggestionCard(
                        title: classSuggestion?.title ?? 'Hôm nay nên tập gì',
                        icon: Icons.calendar_today_rounded,
                        description: classSuggestion?.description ?? '',
                        points: classSuggestion?.points ?? [],
                        isLoading: isClassLoading,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAiSuggestionCard({
    required String title,
    required IconData icon,
    required String description,
    required List<String> points,
    required bool isLoading,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B16))),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B16).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: const Color(0xFFFF6B16), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'AI GỢI Ý',
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFFF6B16),
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hôm nay',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  if (description.isNotEmpty && points.isNotEmpty) const SizedBox(height: 10),
                  ...points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFFFF6B16), fontSize: 14)),
                          Expanded(
                            child: Text(
                              point,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAiChatFloatingButton() {
    return Positioned(
      bottom: 24,
      right: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AiChatPage()),
          );
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF00C853), // Green theme from mockup
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
              Positioned(
                bottom: -2,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBottomNavigationBar extends StatelessWidget {
  const _DashboardBottomNavigationBar();

  static const Color _cardColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: _cardColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            _DashboardBottomNavItem(
              icon: Icons.home_rounded,
              label: 'Trang chủ',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            const _DashboardBottomNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Bảng điều khiển',
              isActive: true,
            ),
            _DashboardBottomNavItem(
              icon: Icons.explore_rounded,
              label: 'Khám phá',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const ExplorePage()),
                );
              },
            ),
            _DashboardBottomNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Đặt lịch',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const BookingHistoryPage(),
                  ),
                );
              },
            ),
            _DashboardBottomNavItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Thành viên',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const MembershipPage(),
                  ),
                );
              },
            ),
            _DashboardBottomNavItem(
              icon: Icons.person_rounded,
              label: 'Hồ sơ',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBottomNavItem extends StatelessWidget {
  const _DashboardBottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  static const Color _primaryOrange = Color(0xFFFF6B16);

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _primaryOrange : Colors.white54;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? _primaryOrange.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
