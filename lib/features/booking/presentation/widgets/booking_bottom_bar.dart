import 'package:flutter/material.dart';

import 'booking_theme.dart';

class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    super.key,
    required this.creditCost,
    required this.onPressed,
    this.buttonText = 'Đặt lịch ngay',
    this.isLoading = false,
  });

  final int creditCost;
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: BookingTheme.card,
        border: Border(top: BorderSide(color: BookingTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi phí',
                    style: TextStyle(
                      color: BookingTheme.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$creditCost Credit',
                    style: const TextStyle(
                      color: BookingTheme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: BookingTheme.primary,
                  foregroundColor: BookingTheme.text,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(isLoading ? 'Vui lòng chờ...' : buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
