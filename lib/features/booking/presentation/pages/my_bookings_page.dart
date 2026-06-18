import 'package:flutter/material.dart';

import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../widgets/booking_theme.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final _repository = BookingRepository();
  late Future<List<BookingModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getMyBookings();
  }

  void _reload() {
    setState(() {
      _future = _repository.getMyBookings();
    });
  }

  Future<void> _cancel(BookingModel booking) async {
    try {
      await _repository.cancelBooking(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã hủy lịch.')));
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      appBar: AppBar(
        title: const Text('Lịch đã đặt'),
        backgroundColor: BookingTheme.background,
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.wifi_off_rounded,
              title: 'Không tải được lịch đã đặt',
              message: snapshot.error.toString(),
              actionLabel: 'Thử lại',
              onAction: _reload,
            );
          }
          final bookings = snapshot.data ?? const <BookingModel>[];
          if (bookings.isEmpty) {
            return _StateMessage(
              icon: Icons.event_busy_rounded,
              title: 'Chưa có lịch sử đặt lịch',
              message: 'Các buổi tập gym và lớp học của bạn sẽ hiển thị ở đây.',
              actionLabel: 'Làm mới',
              onAction: _reload,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingTile(
                booking: booking,
                onCancel: booking.status.toLowerCase() == 'cancelled'
                    ? null
                    : () => _cancel(booking),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking, required this.onCancel});

  final BookingModel booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              TextButton(onPressed: onCancel, child: const Text('Hủy lịch')),
            ],
          ),
        ],
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
