import 'package:flutter/material.dart';

class GymDetailPage extends StatelessWidget {
  const GymDetailPage({super.key});

  // Hàm hiển thị Dialog xác nhận đặt lịch giống thiết kế của ông
  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E202C), // Nền dark đồng bộ
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Xác Nhận Đặt Lịch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn đặt lịch tại FlexFit Premium Club?',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 12),
              Text(
                'Hệ thống sẽ trừ 15 Credits trong tài khoản của bạn.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Chuyển sang màn hình chi tiết vé đặt chỗ kèm mã code giả lập
                Navigator.pushNamed(context, '/booking-detail', arguments: 'GYM-BK-8831');
              },
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng Gym'),
        backgroundColor: const Color(0xFF0F111A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Nhấn back thì quay lại trang lịch sử hoặc trang trước đó
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Khu vực ảnh Slide / Banner phòng Gym (PageView)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey[800],
              child: PageView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.white30),
                  );
                },
              ),
            ),
          ),

          // Khu vực thông tin chi tiết phòng Gym
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: const Color(0xFF0F111A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FlexFit Premium Club',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '123 Đường ABC, Quận 1, TP. Hồ Chí Minh',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chi phí: 15 Credits / buổi',
                    style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Nút Đặt Lịch Ngay cố định ở dưới cùng
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showBookingDialog(context),
                child: const Text(
                  'Đặt Lịch Ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}