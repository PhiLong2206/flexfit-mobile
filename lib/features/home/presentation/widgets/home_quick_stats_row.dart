import 'package:flutter/material.dart';

import '../../../membership/data/repositories/credit_repository.dart';

class HomeQuickStatsRow extends StatefulWidget {
  const HomeQuickStatsRow({super.key});

  @override
  State<HomeQuickStatsRow> createState() => _HomeQuickStatsRowState();
}

class _HomeQuickStatsRowState extends State<HomeQuickStatsRow> {
  final _creditRepository = CreditRepository();
  late Future<int> _creditFuture;

  @override
  void initState() {
    super.initState();
    _creditFuture = _creditRepository.getMyCredit().then(
      (credit) => credit.balance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: FutureBuilder<int>(
        future: _creditFuture,
        builder: (context, snapshot) {
          final stats = [
            _QuickStat(
              icon: Icons.bolt_rounded,
              value: snapshot.connectionState == ConnectionState.waiting
                  ? '...'
                  : '${snapshot.data ?? 0}',
              label: 'Credit hiện có',
              hint: snapshot.hasError ? 'Cần đăng nhập' : 'Số dư ví',
            ),
            const _QuickStat(
              icon: Icons.event_available_rounded,
              value: '0',
              label: 'Lịch sắp tới',
              hint: 'Hôm nay',
            ),
            const _QuickStat(
              icon: Icons.workspace_premium_rounded,
              value: 'Thành viên',
              label: 'Hạng thành viên',
              hint: 'FlexFit',
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
          const SizedBox(height: 3),
          Text(
            stat.hint,
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
      ),
    );
  }
}

class _QuickStat {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.hint,
  });

  final IconData icon;
  final String value;
  final String label;
  final String hint;
}
