import 'package:flutter/material.dart';

import '../widgets/booking_bottom_bar.dart';
import '../widgets/booking_theme.dart';
import '../widgets/gym_image_slider.dart';
import '../widgets/gym_info_card.dart';
import 'booking_confirmation_page.dart';

class GymDetailPage extends StatelessWidget {
  const GymDetailPage({super.key});

  static const String gymName = 'FlexFit Elite Gym';
  static const String address = '12 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh';
  static const double rating = 4.8;
  static const int creditCost = 15;
  static const String openingHours = '06:00 - 22:00';
  static const String duration = '60 phút';
  static const String description =
      'Không gian tập luyện cao cấp với đầy đủ khu cardio, tạ tự do, máy tập hiện đại và đội ngũ huấn luyện viên luôn sẵn sàng hỗ trợ.';
  static const List<String> amenities = [
    'Máy lạnh',
    'Tủ đồ',
    'PT',
    'Wifi',
    'Phòng tắm',
  ];
  static const List<String> images = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingTheme.background,
      bottomNavigationBar: BookingBottomBar(
        creditCost: creditCost,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BookingConfirmationPage(
                gymName: gymName,
                address: address,
                rating: rating,
                creditCost: creditCost,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: GymImageSlider(images: images)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverToBoxAdapter(
                    child: GymInfoCard(
                      name: gymName,
                      address: address,
                      rating: rating,
                      creditCost: creditCost,
                      openingHours: openingHours,
                      duration: duration,
                      description: description,
                      amenities: amenities,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              child: _FloatingBackButton(
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(125),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
        color: BookingTheme.text,
        tooltip: 'Quay lại',
      ),
    );
  }
}
