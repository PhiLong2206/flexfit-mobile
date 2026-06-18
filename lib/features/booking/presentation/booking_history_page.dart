import 'package:flutter/material.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách data từ API về
    final List<Map<String, dynamic>> mockHistory = [
      {'title': 'FlexFit Premium Club', 'type': 'Phòng Gym', 'date': '18/06/2026', 'status': 'Sắp diễn ra', 'color': Colors.green},
      {'title': 'Yoga Advanced', 'type': 'Lớp Học', 'date': '15/06/2026', 'status': 'Đã hoàn thành', 'color': Colors.grey},
      {'title': 'Zumba Dance Fitness', 'type': 'Lớp Học', 'date': '10/06/2026', 'status': 'Đã hủy', 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Đặt Chỗ'),
        backgroundColor: const Color(0xFF0F111A),
      ),
      body: ListView.builder(
        itemCount: mockHistory.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = mockHistory[index];
          return Card(
            color: const Color(0xFF1E202C),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                item['type'] == 'Phòng Gym' ? Icons.fitness_center : Icons.class_,
                color: Colors.orange,
              ),
              title: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${item['type']} - ${item['date']}', style: const TextStyle(color: Colors.white60)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(color: item['color'], fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                // Nhấn vào vé cũ bất kỳ thì bay sang xem chi tiết vé + mã QR luôn
                Navigator.pushNamed(context, '/booking-detail', arguments: 'BK-HIST-${100 + index}');
              },
            ),
          );
        },
      ),
    );
  }
}