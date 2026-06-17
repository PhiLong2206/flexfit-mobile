import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/booking_theme.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({
    super.key,
    this.gymName = 'Phòng gym FlexFit',
    this.address = 'Chưa chọn chi nhánh',
    required this.branchName,
    this.rating = 0,
    this.creditCost = 0,
    required this.branchId,
    required this.startTime,
    required this.endTime,
  });

  final String gymName;
  final String address;
  final String branchName;
  final double rating;
  final int creditCost;
  final String? branchId;
  final DateTime startTime;
  final DateTime endTime;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: _BookingConfirmationView(
        gymName: gymName,
        address: address,
        branchName: branchName,
        rating: rating,
        creditCost: creditCost,
        branchId: branchId,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }
}

class _BookingConfirmationView extends StatelessWidget {
  const _BookingConfirmationView({
    required this.gymName,
    required this.address,
    required this.branchName,
    required this.rating,
    required this.creditCost,
    required this.branchId,
    required this.startTime,
    required this.endTime,
  });

  final String gymName;
  final String address;
  final String branchName;
  final double rating;
  final int creditCost;
  final String? branchId;
  final DateTime startTime;
  final DateTime endTime;

  Future<void> _confirmBooking(BuildContext context) async {
    final resolvedBranchId = branchId?.trim();
    if (resolvedBranchId == null || resolvedBranchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy chi nhánh hợp lệ để đặt lịch.'),
        ),
      );
      return;
    }
    try {
      await context.read<BookingProvider>().createGymBooking(
        branchId: resolvedBranchId,
        sessionName: gymName,
        startTime: startTime,
        endTime: endTime,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt lịch thành công.')));
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == HomePage.routeName,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<BookingProvider>().isLoading;
    final hasValidBranchId = branchId != null && branchId!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: BookingTheme.background,
      bottomNavigationBar: BookingBottomBar(
        creditCost: creditCost,
        buttonText: 'Xác nhận đặt lịch',
        isLoading: isLoading,
        onPressed: hasValidBranchId ? () => _confirmBooking(context) : null,
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
                gymName: gymName,
                address: address,
                branchName: branchName,
                rating: rating,
                creditCost: creditCost,
              ),
              if (!hasValidBranchId) ...[
                const SizedBox(height: 16),
                const _BranchIdWarning(),
              ],
              const SizedBox(height: 24),
              _SelectedTimeCard(startTime: startTime, endTime: endTime),
              const SizedBox(height: 24),
              BookingSummaryCard(creditCost: creditCost),
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
    required this.branchName,
    required this.rating,
    required this.creditCost,
  });

  final String gymName;
  final String address;
  final String branchName;
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
          _InfoLine(icon: Icons.apartment_rounded, text: branchName),
          const SizedBox(height: 8),
          _InfoLine(icon: Icons.location_on_outlined, text: address),
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

class _SelectedTimeCard extends StatelessWidget {
  const _SelectedTimeCard({required this.startTime, required this.endTime});

  final DateTime startTime;
  final DateTime endTime;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: BookingTheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BookingTheme.primary.withValues(alpha: 0.24),
              ),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: BookingTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khung giờ đã chọn',
                  style: TextStyle(
                    color: BookingTheme.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(startTime),
                  style: const TextStyle(
                    color: BookingTheme.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: const TextStyle(
                    color: BookingTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _BranchIdWarning extends StatelessWidget {
  const _BranchIdWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Không tìm thấy chi nhánh hợp lệ cho phòng gym này. Vui lòng quay lại và chọn phòng gym khác.',
              style: TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BookingTheme.secondaryText, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: BookingTheme.secondaryText,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
