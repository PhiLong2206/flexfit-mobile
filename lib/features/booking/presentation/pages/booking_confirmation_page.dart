import 'package:flutter/material.dart';

import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/booking_theme.dart';
import '../widgets/booking_time_selector.dart';
import '../../../home/presentation/pages/home_page.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({
    super.key,
    this.gymName = 'FlexFit Elite Gym',
    this.address = '12 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh',
    this.rating = 4.8,
    this.creditCost = 15,
  });

  final String gymName;
  final String address;
  final double rating;
  final int creditCost;

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  String _selectedTime = BookingTimeSelector.options.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      bottomNavigationBar: BookingBottomBar(
        creditCost: widget.creditCost,
        buttonText: 'Xác nhận đặt lịch',
        onPressed: () async {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đặt lịch thành công!')));
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (!context.mounted) {
            return;
          }
          Navigator.of(context).popUntil(
            (route) =>
                route.isFirst || route.settings.name == HomePage.routeName,
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: BookingTheme.text,
                tooltip: 'Quay lại',
              ),
              const SizedBox(height: 12),
              const Text(
                'Xác nhận đặt lịch',
                style: TextStyle(
                  color: BookingTheme.text,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              _SelectedGymCard(
                gymName: widget.gymName,
                address: widget.address,
                rating: widget.rating,
                creditCost: widget.creditCost,
              ),
              const SizedBox(height: 24),
              BookingTimeSelector(
                selectedTime: _selectedTime,
                onSelected: (value) => setState(() => _selectedTime = value),
              ),
              const SizedBox(height: 24),
              BookingSummaryCard(creditCost: widget.creditCost),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedGymCard extends StatelessWidget {
  const _SelectedGymCard({
    required this.gymName,
    required this.address,
    required this.rating,
    required this.creditCost,
  });

  final String gymName;
  final String address;
  final double rating;
  final int creditCost;

  @override
  Widget build(BuildContext context) {
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
          Text(
            gymName,
            style: const TextStyle(
              color: BookingTheme.text,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: BookingTheme.secondaryText,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: BookingTheme.secondaryText,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC857),
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: BookingTheme.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.local_fire_department_outlined,
                color: BookingTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '$creditCost Credits',
                style: const TextStyle(
                  color: BookingTheme.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
