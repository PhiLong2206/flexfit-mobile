import 'package:flutter/material.dart';
// Import custom button có sẵn của dự án
import '../../../../core/widgets/custom_button.dart';

class GymDetailPage extends StatelessWidget {
  const GymDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng Gym'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Slider hình ảnh phòng gym (Sử dụng PageView)
            SizedBox(
              height: 250,
              child: PageView(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                  Container(
                    color: Colors.grey[400],
                    child: const Icon(Icons.fitness_center, size: 50, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 2. Thông tin chi tiết phòng tập
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FlexFit Premium Club',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '123 Đường ABC, Quận 1, TP. Hồ Chí Minh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),
                      Text(
                        'Chi phí: 15 Credits / buổi',
                        style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 3. Nút Đặt Lịch ngay dưới đáy màn hình
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _showBookingConfirmation(context),
          child: const Text('Đặt Lịch Ngay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // 4. Dialog Xác nhận đặt lịch (Booking Confirmation)
  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm nút mới tắt được dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Xác Nhận Đặt Lịch'),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đặt lịch tại FlexFit Premium Club?\n\nHệ thống sẽ trừ 15 Credits trong tài khoản của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Báo đặt thành công nhanh bằng SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Đặt lịch thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}