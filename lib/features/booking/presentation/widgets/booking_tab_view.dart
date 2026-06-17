import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../gym/presentation/pages/explore_page.dart';
import '../../../profile/data/booking_notifier.dart';
import '../../../profile/data/models/booking_item.dart';
import 'booking_card.dart';

class BookingTabView extends StatefulWidget {
  final BookingStatus status;

  const BookingTabView({super.key, required this.status});

  @override
  State<BookingTabView> createState() => _BookingTabViewState();
}

class _BookingTabViewState extends State<BookingTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingNotifier>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bookingNotifier = context.watch<BookingNotifier>();

    if (bookingNotifier.isLoading && bookingNotifier.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final filteredBookings = bookingNotifier.getBookingsByStatus(widget.status);

    if (filteredBookings.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Không có buổi tập nào',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy đặt lớp học đầu tiên của bạn',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExplorePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Khám phá ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: filteredBookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return BookingCard(booking: filteredBookings[index]);
      },
    );
  }
}
