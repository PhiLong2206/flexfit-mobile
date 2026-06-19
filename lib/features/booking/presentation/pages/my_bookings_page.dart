import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../gym/presentation/pages/explore_page.dart';
import '../../data/models/booking_model.dart';
import '../helpers/booking_group_helper.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_theme.dart';
import '../widgets/review_bottom_sheet.dart';
import 'booking_detail_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider()..fetchBookings(),
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

  Future<void> _cancel(BuildContext context, BookingModel booking) async {
    try {
      await context.read<BookingProvider>().cancelBooking(booking);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã hủy lịch.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: BookingTheme.background,
      appBar: AppBar(
        title: const Text('Lịch đã đặt'),
        backgroundColor: BookingTheme.background,
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, BookingProvider provider) {
    if (provider.isLoading && provider.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.bookings.isEmpty) {
      return _StateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Không tải được lịch đã đặt',
        message: provider.error!,
        actionLabel: 'Thử lại',
        onAction: () =>
            context.read<BookingProvider>().fetchBookings(force: true),
      );
    }
    final bookings = provider.bookings;
    if (bookings.isEmpty) {
      return const _EmptyBookingsState();
    }
    if (bookings.isEmpty) {
      return _StateMessage(
        icon: Icons.event_busy_rounded,
        title: 'Chưa có lịch sử đặt lịch',
        message: 'Các buổi tập gym và lớp học của bạn sẽ hiển thị ở đây.',
        actionLabel: 'Làm mới',
        onAction: () =>
            context.read<BookingProvider>().fetchBookings(force: true),
      );
    }

    final sections = groupBookingsBySchedule(bookings);

    return RefreshIndicator(
      onRefresh: () =>
          context.read<BookingProvider>().fetchBookings(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          for (
            var sectionIndex = 0;
            sectionIndex < sections.length;
            sectionIndex++
          ) ...[
            if (sectionIndex > 0) const SizedBox(height: 22),
            _BookingSection(
              section: sections[sectionIndex],
              onCancel: (booking) => _cancel(context, booking),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingSection extends StatelessWidget {
  const _BookingSection({required this.section, required this.onCancel});

  final BookingSectionGroup section;
  final ValueChanged<BookingModel> onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        for (var index = 0; index < section.bookings.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _BookingTile(
            booking: section.bookings[index],
            onCancel: _canCancel(section.bookings[index])
                ? () => onCancel(section.bookings[index])
                : null,
          ),
        ],
      ],
    );
  }

  bool _canCancel(BookingModel booking) {
    final status = booking.status.toLowerCase();
    return status != 'cancelled' && status != 'canceled';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BookingTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: BookingTheme.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyBookingsState extends StatelessWidget {
  const _EmptyBookingsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_rounded,
              color: BookingTheme.primary,
              size: 46,
            ),
            const SizedBox(height: 14),
            const Text(
              'Bạn chưa có lịch đặt nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExplorePage()),
                );
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Khám phá phòng gym'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking, required this.onCancel});

  final BookingModel booking;
  final VoidCallback? onCancel;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailPage(
          booking: booking,
          onReviewed: () {
            context.read<BookingProvider>().markBookingReviewed(booking);
          },
        ),
      ),
    );
  }

  Future<void> _openReviewSheet(BuildContext context) async {
    if (!booking.canReview) {
      return;
    }
    final result = await showModalBottomSheet<ReviewSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewBottomSheet(booking: booking),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await context.read<BookingProvider>().markBookingReviewed(booking);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == ReviewSheetResult.submitted
              ? 'Cảm ơn bạn! Đánh giá đã được ghi nhận.'
              : 'Lịch này đã được đánh giá trước đó.',
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BookingTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BookingTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  booking.type == BookingType.gym
                      ? Icons.fitness_center_rounded
                      : Icons.self_improvement_rounded,
                  color: BookingTheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BookingTheme.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  _statusLabel(booking.status),
                  style: const TextStyle(
                    color: BookingTheme.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              [
                if (booking.gymName != null) booking.gymName,
                if (booking.subtitle != null) booking.subtitle,
              ].join(' - '),
              style: const TextStyle(
                color: BookingTheme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(booking.startTime)}  ${_formatTime(booking.startTime)}-${_formatTime(booking.endTime)}',
              style: const TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${booking.creditUsed} Credit',
                  style: const TextStyle(
                    color: BookingTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (booking.hasReview || booking.canReview)
                  TextButton.icon(
                    onPressed: booking.hasReview
                        ? null
                        : () => _openReviewSheet(context),
                    icon: Icon(
                      booking.hasReview
                          ? Icons.check_circle_rounded
                          : Icons.rate_review_rounded,
                      size: 16,
                    ),
                    label: Text(booking.hasReview ? 'Đã đánh giá' : 'Đánh giá'),
                  )
                else
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Hủy lịch'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'canceled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Đang chờ';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'booked':
        return 'Đã đặt';
      default:
        return status;
    }
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: BookingTheme.primary, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BookingTheme.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
