import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/booking_qr_widget.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  // Hàm kích hoạt mở Google Map ứng dụng bên ngoài
  Future<void> _openGoogleMap() async {
    const String address = '123 Đường ABC, Quận 1, TP. Hồ Chí Minh';
    final String query = Uri.encodeComponent(address);
    final Uri googleMapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở bản đồ.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nhận bookingId truyền sang, nếu không có lấy mặc định
    final String bookingId = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'BK-FLX-2026';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé Đặt Lịch Của Bạn'),
        backgroundColor: const Color(0xFF0F111A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Gọi cái QR code widget vừa viết ở trên
              BookingQrWidget(bookingId: bookingId),
              const SizedBox(height: 16),
              Text('Mã vé: $bookingId', style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const Divider(height: 32, color: Colors.white24),

              // Nút chức năng Map & Cancel
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: _openGoogleMap,
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text('Chỉ Đường', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hủy lịch thành công! Số credit đã được hoàn lại.')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text('Hủy Lịch', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}