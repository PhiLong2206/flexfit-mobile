import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingQrWidget extends StatelessWidget {
  final String bookingId;

  const BookingQrWidget({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // QR code bắt buộc nền sáng để máy quét nhận diện
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: bookingId,
        version: QrVersions.auto,
        size: 180.0,
        gapless: false,
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(30, 30),
        ),
      ),
    );
  }
}