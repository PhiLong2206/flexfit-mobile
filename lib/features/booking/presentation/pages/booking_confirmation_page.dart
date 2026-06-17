import 'package:flutter/material.dart';

import '../../data/repositories/booking_repository.dart';
import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/booking_theme.dart';
import '../widgets/booking_time_selector.dart';
import '../../../home/presentation/pages/home_page.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({
    super.key,
    this.gymName = 'Phòng gym FlexFit',
    this.address = 'Chưa chọn chi nhánh',
    this.rating = 0,
    this.creditCost = 0,
    this.branchId,
  });

  final String gymName;
  final String address;
  final double rating;
  final int creditCost;
  final String? branchId;

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final _repository = BookingRepository();
  String _selectedTime = BookingTimeSelector.options.first;
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    final branchId = widget.branchId;
    if (branchId == null || branchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chưa thể đặt lịch phòng gym này vì hệ thống cần BranchId.',
          ),
        ),
      );
      return;
    }

    final startTime = _startTimeFor(_selectedTime);
    final endTime = startTime.add(const Duration(hours: 1));
    setState(() => _isLoading = true);
    try {
      await _repository.bookGym(
        branchId: branchId,
        sessionName: widget.gymName,
        startTime: startTime,
        endTime: endTime,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt lịch thành công.')));
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == HomePage.routeName,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _startTimeFor(String option) {
    final now = DateTime.now();
    final date = switch (option) {
      'Ngày mai' => now.add(const Duration(days: 1)),
      'Cuối tuần' => now.add(
        Duration(days: (DateTime.saturday - now.weekday) % 7),
      ),
      _ => now,
    };
    return DateTime(date.year, date.month, date.day, 9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      bottomNavigationBar: BookingBottomBar(
        creditCost: widget.creditCost,
        buttonText: 'Xác nhận đặt lịch',
        isLoading: _isLoading,
        onPressed: _confirmBooking,
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
                '$creditCost Credit',
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
