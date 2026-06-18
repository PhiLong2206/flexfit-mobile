import 'package:flutter/material.dart';

class ClassDetailPage extends StatelessWidget {
  const ClassDetailPage({super.key});

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E202C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Xác Nhận Đặt Lớp', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng ký lớp học này không? Hệ thống sẽ trừ credit tương ứng.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Giả lập ID sau khi đặt thành công rồi chuyển qua trang chi tiết vé
                Navigator.pushNamed(context, '/booking-detail', arguments: 'CLASS-BK-9921');
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
        title: const Text('Chi tiết Lớp Học'),
        backgroundColor: const Color(0xFF0F111A),
      ),
      body: Column(
        children: [
          // Banner giả lập hình ảnh lớp học
          Container(
            height: 220,
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.fitness_center, size: 64, color: Colors.white30),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yoga Advanced & Meditation',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text('HLV: Nguyễn Hoàng Minh', style: TextStyle(color: Colors.orange)),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFF1E202C),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Thời gian: 18:30 - 19:30 (Hôm nay)', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.monetization_on_outlined, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Chi phí: 20 Credits / buổi', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _showBookingDialog(context),
                child: const Text('Đăng Ký Học Ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}