import 'package:flutter/material.dart';

// 1. Model local đại diện cho dữ liệu hiển thị (sẵn sàng map với API JSON)
class ExploreGym {
  final String id;
  final String title;
  final String branchName;
  final String address;
  final String openTime;
  final String duration;
  final String category;
  final int credit;
  final int availableGymCount;
  final String imageUrl;

  const ExploreGym({
    required this.id,
    required this.title,
    required this.branchName,
    required this.address,
    required this.openTime,
    required this.duration,
    required this.category,
    required this.credit,
    required this.availableGymCount,
    required this.imageUrl,
  });

  // Factory constructor để phục vụ việc parsing từ API Response sau này
  factory ExploreGym.fromJson(Map<String, dynamic> json) {
    return ExploreGym(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      openTime: json['openTime'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      category: json['category'] as String? ?? '',
      credit: json['credit'] as int? ?? 0,
      availableGymCount: json['availableGymCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'branchName': branchName,
      'address': address,
      'openTime': openTime,
      'duration': duration,
      'category': category,
      'credit': credit,
      'availableGymCount': availableGymCount,
      'imageUrl': imageUrl,
    };
  }
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  // 2. Mock data sử dụng chuẩn model đã định nghĩa
  final List<ExploreGym> _allGyms = const [
    ExploreGym(
      id: '1',
      title: 'Elite Power Lifting',
      branchName: 'FlexFit Elite - Quận 1',
      address: 'Lầu 3, 123 Nguyễn Huệ, Bến Nghé, Quận 1',
      openTime: '06:00 - 22:00',
      duration: '60 phút',
      category: 'Gym',
      credit: 10,
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    ),
    ExploreGym(
      id: '2',
      title: 'Vinyasa Flow Yoga',
      branchName: 'Yoga Zen Center - Bình Thạnh',
      address: '456 Điện Biên Phủ, Phường 22, Bình Thạnh',
      openTime: '07:00 - 21:00',
      duration: '75 phút',
      credit: 12,
      category: 'Yoga',
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&auto=format&fit=crop&q=80',
    ),
    ExploreGym(
      id: '3',
      title: 'Championship Boxing',
      branchName: 'KO Academy - Quận 3',
      address: '789 Nguyễn Đình Chiểu, Phường 6, Quận 3',
      openTime: '08:00 - 21:30',
      duration: '90 phút',
      credit: 12,
      category: 'Boxing',
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=600&auto=format&fit=crop&q=80',
    ),
    ExploreGym(
      id: '4',
      title: 'HIIT Cardio Burnout',
      branchName: 'Power Arena - Phú Nhuận',
      address: '12 Phan Xích Long, Phường 2, Phú Nhuận',
      openTime: '06:30 - 21:00',
      duration: '45 phút',
      credit: 10,
      category: 'HIIT',
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600&auto=format&fit=crop&q=80',
    ),
    ExploreGym(
      id: '5',
      title: 'Zumba Dance Party',
      branchName: 'Dance & Flow Studio - Quận 10',
      address: '101 Ba Tháng Hai, Phường 11, Quận 10',
      openTime: '09:00 - 20:30',
      duration: '60 phút',
      credit: 10,
      category: 'Zumba',
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1524594152303-9fd13543dd6e?w=600&auto=format&fit=crop&q=80',
    ),
    ExploreGym(
      id: '6',
      title: 'Hatha Balance Yoga',
      branchName: 'Yoga Zen Center - Quận 2',
      address: '88 Song Hành, An Phú, Quận 2',
      openTime: '06:00 - 20:00',
      duration: '60 phút',
      credit: 12,
      category: 'Yoga',
      availableGymCount: 0,
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  final List<String> _categories = const [
    'Tất cả',
    'Gym',
    'Yoga',
    'Boxing',
    'HIIT',
    'Zumba',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 4 & 5. Logic lọc dữ liệu (Sử dụng các field trong model)
  List<ExploreGym> get _filteredGyms {
    return _allGyms.where((gym) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = gym.title.toLowerCase().contains(query) ||
          gym.branchName.toLowerCase().contains(query) ||
          gym.address.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'Tất cả' || gym.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // 6. Hàm xử lý riêng khi nhấn "Đặt chỗ ngay"
  void _onBookNow(ExploreGym gym) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đặt chỗ thành công tại ${gym.title}!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFF7A1A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNavLink(String text, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFF7A1A) : const Color(0xFF94A3B8),
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  // 9. Tách phương thức build Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm lớp học, phòng tập...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF7A1A)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Filter màu cam
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bộ lọc nâng cao sẽ được kết nối ở phase sau.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF172033),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 9. Tách phương thức build Category Selector Chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: const Color(0xFFFF7A1A),
              backgroundColor: const Color(0xFF172033),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : const Color(0xFF1E293B),
                ),
              ),
              elevation: 0,
            ),
          );
        },
      ),
    );
  }

  // 9. Tách phương thức build Danh sách Gym
  Widget _buildGymList(List<ExploreGym> filteredList) {
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 54, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'Không tìm thấy lớp học phù hợp',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final gym = filteredList[index];
        return _ExploreGymCard(
          gym: gym,
          onBookTap: () => _onBookNow(gym),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredGyms;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header cho Mobile (Dark theme giống Web)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FLEXFIT',
                    style: TextStyle(
                      color: Color(0xFFFF7A1A),
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Row(
                    children: [
                      _buildNavLink('Tìm Đối Tác', isSelected: true),
                      _buildNavLink('Lớp Học'),
                      _buildNavLink('Gói Tập'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B), thickness: 1),

            // Hero Intro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tìm Đối Tác',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tìm và đặt cho lớp học từ các đối tác cao cấp của chúng tôi.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Button
            _buildSearchBar(),

            // Horizontal Category Selector Chips
            _buildCategoryChips(),

            // Count number of results
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Hiển thị ${filteredList.length} kết quả',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Gym/Class list
            Expanded(
              child: _buildGymList(filteredList),
            ),
          ],
        ),
      ),
    );
  }
}

// 8. Tách widget Card hiển thị Gym riêng biệt sạch sẽ, chỉ nhận model object
class _ExploreGymCard extends StatelessWidget {
  final ExploreGym gym;
  final VoidCallback onBookTap;

  const _ExploreGymCard({
    required this.gym,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF172033),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Overlaid Badges
          Stack(
            children: [
              Image.network(
                gym.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Color(0xFF94A3B8), size: 40),
                    ),
                  );
                },
              ),
              // Top Left Badge: "X gym" (lấy dữ liệu từ model)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_city,
                          color: Color(0xFFFF7A1A), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${gym.availableGymCount} gym',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Top Right Badge: Credits (lấy từ model)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${gym.credit} Credit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thể loại tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF7A1A)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    gym.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFF7A1A),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tên lớp / phòng Gym
                Text(
                  gym.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Tên chi nhánh
                Text(
                  gym.branchName,
                  style: const TextStyle(
                    color: Color(0xFFFF7A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Địa chỉ
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF94A3B8), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        gym.address,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF1E293B)),
                const SizedBox(height: 8),
                // Giờ mở cửa & Thời lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color(0xFF94A3B8), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Giờ mở cửa: ${gym.openTime}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            color: Color(0xFF94A3B8), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          gym.duration,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Button Đặt chỗ
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onBookTap,
                    child: const Text(
                      'Đặt chỗ ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
