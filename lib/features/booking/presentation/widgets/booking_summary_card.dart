import 'package:flutter/material.dart';

import 'booking_theme.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.creditCost});

  final int creditCost;

  @override
  Widget build(BuildContext context) {
    const currentCredits = 960;
    final remainingCredits = currentCredits - creditCost;

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
          _SummaryRow(label: 'Dịch vụ', value: 'Open Gym'),
          const _SummaryRow(label: 'Thời lượng', value: '60 phút'),
          _SummaryRow(label: 'Chi phí', value: '$creditCost Credits'),
          const _SummaryRow(label: 'Số dư hiện tại', value: '960 Credits'),
          _SummaryRow(
            label: 'Còn lại sau đặt',
            value: '$remainingCredits Credits',
            valueColor: BookingTheme.primary,
          ),
        ],
      ),
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
