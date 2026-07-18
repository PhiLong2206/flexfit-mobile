import 'package:flutter/material.dart';

import '../../../membership/data/repositories/credit_repository.dart';
import 'booking_theme.dart';

class BookingSummaryCard extends StatefulWidget {
  const BookingSummaryCard({super.key, required this.creditCost});

  final int creditCost;

  @override
  State<BookingSummaryCard> createState() => _BookingSummaryCardState();
}

class _BookingSummaryCardState extends State<BookingSummaryCard> {
  final _creditRepo = CreditRepository();
  late Future<int> _balanceFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = _fetchBalance();
  }

  Future<int> _fetchBalance() async {
    try {
      final credit = await _creditRepo.getMyCredit();
      return credit.balance;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _balanceFuture,
      builder: (context, snapshot) {
        final currentCredits = snapshot.data ?? 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final remaining = currentCredits - widget.creditCost;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: BookingTheme.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: BookingTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tóm tắt đặt lịch',
                style: TextStyle(
                  color: BookingTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _SummaryRow(label: 'Dịch vụ', value: 'Tập tự do'),
              const _SummaryRow(label: 'Thời lượng', value: '60 phút'),
              _SummaryRow(
                label: 'Chi phí',
                value: '${widget.creditCost} Credit',
              ),
              _SummaryRow(
                label: 'Số dư hiện tại',
                value: isLoading ? '...' : '$currentCredits Credit',
              ),
              _SummaryRow(
                label: 'Còn lại sau đặt',
                value: isLoading ? '...' : '$remaining Credit',
                valueColor: remaining >= 0
                    ? BookingTheme.primary
                    : const Color(0xFFEF4444),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = BookingTheme.text,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BookingTheme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
