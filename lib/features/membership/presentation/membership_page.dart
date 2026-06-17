import 'package:flutter/material.dart';

import '../../home/presentation/pages/home_page.dart';
// TODO API:
// 1. Gọi API lấy số credit hiện tại của user.
// 2. Gọi API lấy danh sách gói nạp credit.
// 3. Gọi API lấy danh sách gói membership.
// 4. Khi bấm "Mua" hoặc "Nâng cấp" thì gọi API tạo đơn mua gói.
//
// NOTE:
// Trang này hiện tại đang dùng data cứng để dựng UI trước.
// Sau này chỉ cần thay data cứng bằng dữ liệu trả về từ API.

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  static const Color bg = Color(0xFF070B14);
  static const Color card = Color(0xFF111827);
  static const Color orange = Color(0xFFFF6B16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            // Giới hạn maxWidth = 430 để khi chạy trên Chrome/Web,
            // giao diện vẫn giống màn hình mobile, không bị kéo quá rộng.
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              // Padding bottom 120 để nội dung cuối không bị thanh navigation che mất.
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: [
                const _MembershipHeader(),
                const SizedBox(height: 20),
                _currentCredit(),
                const SizedBox(height: 24),
                _title('Nạp Credit'),
                const SizedBox(height: 12),
                _creditCard(
                  '10 Credits',
                  '150k',
                  'Tương đương 1 tuần tập thử',
                ),
                _creditCard(
                  '50 Credits',
                  '600k',
                  'Tặng thêm 0 credits bonus',
                ),
                _creditCard(
                  '100 Credits',
                  '1.1M',
                  'Ưu đãi tiết kiệm 20%',
                ),
                const SizedBox(height: 24),
                _title('Gói thành viên'),
                const SizedBox(height: 12),
                _planCard(
                  name: 'BASIC',
                  price: '499k /tháng',
                  benefits: [
                    'Truy cập phòng tập cơ bản',
                    '50 Credits mỗi tháng',
                    'Lịch sử giao dịch',
                  ],
                ),
                _planCard(
                  name: 'PRO',
                  price: '999k /tháng',
                  isPopular: true,
                  benefits: [
                    'Truy cập nhiều phòng gym',
                    '120 Credits mỗi tháng',
                    'AI Coach cơ bản',
                  ],
                ),
                _planCard(
                  name: 'ELITE',
                  price: '1.499k /tháng',
                  benefits: [
                    'Không giới hạn phòng tập',
                    '300 Credits mỗi tháng',
                    'Ưu tiên đặt lịch',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _MembershipBottomNavigationBar(),
    );
  }

  Widget _currentCredit() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF2A1E18)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: orange.withValues(alpha: 0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÓI HIỆN TẠI',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            'ELITE MEMBER',
            style: TextStyle(
              color: orange,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          Text(
            '120 Credits khả dụng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditCard(String credit, String price, String desc) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO API:
        // Sau này khi bấm cả card credit,
        // gọi API mua/nạp credit theo gói đang chọn.
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: orange),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFFFFC078),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 78,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // TODO API:
                      // Gọi API tạo giao dịch mua credit.
                      // Sau khi mua thành công thì reload lại số credit hiện tại.
                    },
                    child: const Text(
                      'Mua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard({
    required String name,
    required String price,
    required List<String> benefits,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? orange : Colors.white12,
          width: isPopular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PHỔ BIẾN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFFFC078),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          // benefits là danh sách quyền lợi của từng gói.
          // Dùng spread operator "..." để chuyển từng item trong list
          // thành nhiều widget Row hiển thị trên UI.
          ...benefits.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? orange : Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(color: orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: Text(isPopular ? 'Mua gói này' : 'Nâng cấp'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _MembershipHeader extends StatelessWidget {
  const _MembershipHeader();

  static const Color orange = Color(0xFFFF6B16);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: orange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              'FF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'FLEXFIT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
        ),
        const CircleAvatar(
          backgroundColor: Color(0xFF111827),
          child: Text(
            'DR',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _MembershipBottomNavigationBar extends StatelessWidget {
  const _MembershipBottomNavigationBar();

  static const Color cardColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            const _BottomNavItem(
              icon: Icons.explore_rounded,
              label: 'Explore',
            ),
            const _BottomNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Booking',
            ),
            const _BottomNavItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Membership',
              isActive: true,
            ),
            const _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  static const Color orange = Color(0xFFFF6B16);

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? orange : Colors.white54;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? orange.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}