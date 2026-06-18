import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/booking_model.dart';
import '../widgets/booking_theme.dart';
import '../widgets/review_bottom_sheet.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, required this.booking, this.onReviewed});

  final BookingModel booking;
  final VoidCallback? onReviewed;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late bool _hasReview;

  BookingModel get booking => widget.booking;

  @override
  void initState() {
    super.initState();
    _hasReview = booking.hasReview;
  }

  String get _typeLabel {
    return booking.type == BookingType.gym ? 'Gym' : 'Class';
  }

  String get _qrValue {
    final code = booking.bookingCode.trim();
    if (code.isNotEmpty) {
      return code;
    }
    return booking.id;
  }

  String get _displayName {
    if (booking.type == BookingType.classBooking) {
      return booking.title;
    }
    return booking.gymName ?? booking.title;
  }

  String? get _secondaryName {
    if (booking.type == BookingType.classBooking) {
      return booking.gymName;
    }
    return booking.branchName ?? booking.subtitle;
  }

  String? get _location {
    final parts = [
      booking.branchName,
      booking.branchAddress,
    ].where((value) => value != null && value.trim().isNotEmpty).cast<String>();
    final value = parts.join(' - ');
    return value.isEmpty ? null : value;
  }

  String? get _directionsQuery {
    final values = [booking.branchAddress, booking.branchName, booking.gymName];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return BookingTheme.primary;
    }
  }

  String get _statusLabel {
    switch (booking.status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'booked':
        return 'Booked';
      default:
        return booking.status.isEmpty ? 'Unknown' : booking.status;
    }
  }

  bool get _canReview => booking.canReview && !_hasReview;

  Future<void> _openReviewSheet(BuildContext context) async {
    if (!_canReview) {
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
    setState(() => _hasReview = true);
    widget.onReviewed?.call();
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

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _qrValue));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Booking code copied'),
        backgroundColor: BookingTheme.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final query = _directionsQuery;
    if (query == null) {
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cannot open Google Maps'),
        backgroundColor: BookingTheme.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = MediaQuery.sizeOf(context).width >= 720
        ? 640.0
        : double.infinity;

    return Scaffold(
      backgroundColor: BookingTheme.background,
      appBar: AppBar(
        backgroundColor: BookingTheme.background,
        elevation: 0,
        title: const Text(
          'Booking detail',
          style: TextStyle(
            color: BookingTheme.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _HeaderCard(
                  typeLabel: _typeLabel,
                  title: _displayName,
                  subtitle: _secondaryName,
                  location: _location,
                  directionsQuery: _directionsQuery,
                  onDirections: () => _openDirections(context),
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                ),
                const SizedBox(height: 16),
                _QrCard(
                  value: _qrValue,
                  bookingCode: booking.bookingCode.trim(),
                  onCopy: () => _copyCode(context),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  rows: [
                    _DetailRow(
                      icon: Icons.category_rounded,
                      label: 'Booking type',
                      value: _typeLabel,
                    ),
                    _DetailRow(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Start time',
                      value: _formatDateTime(booking.startTime),
                    ),
                    _DetailRow(
                      icon: Icons.stop_circle_outlined,
                      label: 'End time',
                      value: _formatDateTime(booking.endTime),
                    ),
                    _DetailRow(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Credit used',
                      value: '${booking.creditUsed} Credits',
                    ),
                    _DetailRow(
                      icon: Icons.verified_rounded,
                      label: 'Status',
                      value: _statusLabel,
                      valueColor: _statusColor,
                    ),
                    _DetailRow(
                      icon: Icons.confirmation_number_rounded,
                      label: 'Booking ID',
                      value: booking.id,
                    ),
                    if (booking.bookingCode.trim().isNotEmpty)
                      _DetailRow(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Booking code',
                        value: booking.bookingCode.trim(),
                      ),
                  ],
                ),
                if (_hasReview || _canReview) ...[
                  const SizedBox(height: 16),
                  _ReviewActionCard(
                    hasReview: _hasReview,
                    onReview: () => _openReviewSheet(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}

class _ReviewActionCard extends StatelessWidget {
  const _ReviewActionCard({required this.hasReview, required this.onReview});

  final bool hasReview;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: BookingTheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasReview
                  ? Icons.check_circle_rounded
                  : Icons.rate_review_rounded,
              color: hasReview ? const Color(0xFF22C55E) : BookingTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasReview ? 'Bạn đã đánh giá lịch này' : 'Đánh giá buổi tập',
              style: const TextStyle(
                color: BookingTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          FilledButton(
            onPressed: hasReview ? null : onReview,
            child: Text(hasReview ? 'Đã gửi' : 'Đánh giá'),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.typeLabel,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.directionsQuery,
    required this.onDirections,
    required this.statusLabel,
    required this.statusColor,
  });

  final String typeLabel;
  final String title;
  final String? subtitle;
  final String? location;
  final String? directionsQuery;
  final VoidCallback onDirections;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: BookingTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BookingTheme.primary.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  typeLabel == 'Gym'
                      ? Icons.fitness_center_rounded
                      : Icons.self_improvement_rounded,
                  color: BookingTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        color: BookingTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: BookingTheme.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _InlineInfo(icon: Icons.apartment_rounded, text: subtitle!),
          ],
          if (location != null) ...[
            const SizedBox(height: 10),
            _InlineInfo(icon: Icons.location_on_outlined, text: location!),
          ],
          if (directionsQuery != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Chỉ đường'),
              style: OutlinedButton.styleFrom(
                foregroundColor: BookingTheme.primary,
                side: const BorderSide(color: BookingTheme.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.value,
    required this.bookingCode,
    required this.onCopy,
  });

  final String value;
  final String bookingCode;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: value,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bookingCode.isEmpty ? value : bookingCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BookingTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy booking code'),
              style: OutlinedButton.styleFrom(
                foregroundColor: BookingTheme.text,
                side: const BorderSide(color: BookingTheme.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: rows),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = BookingTheme.text,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BookingTheme.secondaryText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BookingTheme.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.text});

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
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: BookingTheme.card,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: BookingTheme.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
