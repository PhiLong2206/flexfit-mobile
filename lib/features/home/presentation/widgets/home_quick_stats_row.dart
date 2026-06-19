import 'package:flutter/material.dart';

import '../../../booking/data/booking_refresh_notifier.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../membership/data/credit_refresh_notifier.dart';
import '../../../membership/data/repositories/credit_repository.dart';

class HomeQuickStatsRow extends StatefulWidget {
  const HomeQuickStatsRow({super.key});

  @override
  State<HomeQuickStatsRow> createState() => _HomeQuickStatsRowState();
}

class _HomeQuickStatsRowState extends State<HomeQuickStatsRow>
    with WidgetsBindingObserver {
  final _creditRepository = CreditRepository();
  final _bookingRepository = BookingRepository();
  late Future<_HomeStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statsFuture = _loadStats();
    CreditRefreshNotifier.instance.addListener(_reloadStats);
    BookingRefreshNotifier.instance.addListener(_reloadStats);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CreditRefreshNotifier.instance.removeListener(_reloadStats);
    BookingRefreshNotifier.instance.removeListener(_reloadStats);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadStats();
    }
  }

  Future<_HomeStats> _loadStats() async {
    final creditFuture = _loadCreditStats();
    final upcomingFuture = _loadUpcomingBookingCount();
    final credit = await creditFuture;
    final upcomingBookingCount = await upcomingFuture;

    return _HomeStats(
      creditBalance: credit.balance,
      upcomingBookingCount: upcomingBookingCount,
      hasCreditError: credit.hasError,
    );
  }

  Future<_CreditStats> _loadCreditStats() async {
    try {
      final credit = await _creditRepository.getMyCredit();
      return _CreditStats(balance: credit.balance, hasError: false);
    } catch (_) {
      return const _CreditStats(balance: 0, hasError: true);
    }
  }

  Future<int> _loadUpcomingBookingCount() async {
    try {
      final bookings = await _bookingRepository.getMyBookings();
      return _countUpcomingBookings(bookings);
    } catch (_) {
      return 0;
    }
  }

  int _countUpcomingBookings(List<BookingModel> bookings) {
    final now = DateTime.now();
    return bookings.where((booking) {
      return !_isIgnoredBookingStatus(booking.status) &&
          !booking.startTime.isBefore(now);
    }).length;
  }

  bool _isIgnoredBookingStatus(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '');
    return normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'failed' ||
        normalized == 'error' ||
        normalized == 'rejected';
  }

  void _reloadStats() {
    if (!mounted) {
      return;
    }
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: FutureBuilder<_HomeStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          final statsData = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final stats = [
            _QuickStat(
              icon: Icons.bolt_rounded,
              value: isLoading ? '...' : '${statsData?.creditBalance ?? 0}',
              label: 'Credit hiện có',
              hint: statsData?.hasCreditError ?? false
                  ? 'Cần đăng nhập'
                  : 'Số dư ví',
            ),
            _QuickStat(
              icon: Icons.event_available_rounded,
              value: isLoading
                  ? '...'
                  : '${statsData?.upcomingBookingCount ?? 0}',
              label: 'Lịch sắp tới',
              hint: 'Còn hiệu lực',
            ),
            const _QuickStat(
  icon: Icons.workspace_premium_rounded,
  value: 'Member',
  label: 'FlexFit',
),
          ];

          return Row(
            children: [
              for (var index = 0; index < stats.length; index++) ...[
                Expanded(child: _QuickStatCard(stat: stats[index])),
                if (index != stats.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.stat});

  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _QuickStat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: _primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: _primaryOrange, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.68),
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
              letterSpacing: 0,
            ),
          ),
          if (stat.hint != null) ...[
            const SizedBox(height: 3),
            Text(
              stat.hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.42),
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickStat {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    this.hint,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? hint;
}

class _HomeStats {
  const _HomeStats({
    required this.creditBalance,
    required this.upcomingBookingCount,
    required this.hasCreditError,
  });

  final int creditBalance;
  final int upcomingBookingCount;
  final bool hasCreditError;
}

class _CreditStats {
  const _CreditStats({required this.balance, required this.hasError});

  final int balance;
  final bool hasError;
}
