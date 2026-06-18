import 'package:flutter/material.dart';

// ==========================================
// MODELS (Declared locally for self-containment)
// ==========================================

class ExploreGym {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String categoryName;
  final String imageUrl;
  final bool isFavorite;

  const ExploreGym({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.categoryName,
    required this.imageUrl,
    required this.isFavorite,
  });

  ExploreGym copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    String? distance,
    String? categoryName,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return ExploreGym(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory ExploreGym.fromJson(Map<String, dynamic> json) {
    return ExploreGym(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      distance: json['distance'] as String,
      categoryName: json['categoryName'] as String,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'distance': distance,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }
}

class ExploreClass {
  final String id;
  final String title;
  final String branchId;
  final String branchName;
  final String categoryId;
  final String categoryName;
  final String duration;
  final int credit;
  final String imageUrl;
  final bool isFavorite;

  const ExploreClass({
    required this.id,
    required this.title,
    required this.branchId,
    required this.branchName,
    required this.categoryId,
    required this.categoryName,
    required this.duration,
    required this.credit,
    required this.imageUrl,
    required this.isFavorite,
  });

  ExploreClass copyWith({
    String? id,
    String? title,
    String? branchId,
    String? branchName,
    String? categoryId,
    String? categoryName,
    String? duration,
    int? credit,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return ExploreClass(
      id: id ?? this.id,
      title: title ?? this.title,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      duration: duration ?? this.duration,
      credit: credit ?? this.credit,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory ExploreClass.fromJson(Map<String, dynamic> json) {
    return ExploreClass(
      id: json['id'] as String,
      title: json['title'] as String,
      branchId: json['branchId'] as String,
      branchName: json['branchName'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      duration: json['duration'] as String,
      credit: json['credit'] as int,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'branchId': branchId,
      'branchName': branchName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'duration': duration,
      'credit': credit,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }
}

// ==========================================
// MOCK DATA
// ==========================================

const List<ExploreGym> _mockGyms = [
  ExploreGym(
    id: 'g1',
    name: 'Elite Fitness Xuân Diệu',
    address: '51 Xuân Diệu, Tây Hồ, Hà Nội',
    rating: 4.8,
    distance: '1.2 km',
    categoryName: 'Gym',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600',
    isFavorite: true,
  ),
  ExploreGym(
    id: 'g2',
    name: 'California Fitness & Yoga',
    address: '88 Láng Hạ, Đống Đa, Hà Nội',
    rating: 4.7,
    distance: '2.5 km',
    categoryName: 'Yoga',
    imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=600',
    isFavorite: false,
  ),
  ExploreGym(
    id: 'g3',
    name: 'Saigon Sports Club',
    address: '514 Huỳnh Tấn Phát, Quận 7, TP. HCM',
    rating: 4.9,
    distance: '4.8 km',
    categoryName: 'Boxing',
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600',
    isFavorite: true,
  ),
  ExploreGym(
    id: 'g4',
    name: 'City Gym CityLand',
    address: '18 Phan Văn Trị, Gò Vấp, TP. HCM',
    rating: 4.5,
    distance: '3.1 km',
    categoryName: 'HIIT',
    imageUrl: 'https://images.unsplash.com/photo-1571731979149-75be89323c59?q=80&w=600',
    isFavorite: false,
  ),
  ExploreGym(
    id: 'g5',
    name: 'Zumba Fiesta Studio',
    address: '12 Võ Văn Kiệt, Quận 1, TP. HCM',
    rating: 4.6,
    distance: '0.8 km',
    categoryName: 'Zumba',
    imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600',
    isFavorite: false,
  ),
];

const List<ExploreClass> _mockClasses = [
  ExploreClass(
    id: 'c1',
    title: 'Power Bodybuilding',
    branchId: 'g1',
    branchName: 'Elite Fitness Xuân Diệu',
    categoryId: 'cat_gym',
    categoryName: 'Gym',
    duration: '60 phút',
    credit: 15,
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600',
    isFavorite: true,
  ),
  ExploreClass(
    id: 'c2',
    title: 'Vinyasa Flow Yoga',
    branchId: 'g2',
    branchName: 'California Fitness & Yoga',
    categoryId: 'cat_yoga',
    categoryName: 'Yoga',
    duration: '75 phút',
    credit: 12,
    imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600',
    isFavorite: false,
  ),
  ExploreClass(
    id: 'c3',
    title: 'Kickboxing Fundamentals',
    branchId: 'g3',
    branchName: 'Saigon Sports Club',
    categoryId: 'cat_boxing',
    categoryName: 'Boxing',
    duration: '90 phút',
    credit: 20,
    imageUrl: 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=600',
    isFavorite: true,
  ),
  ExploreClass(
    id: 'c4',
    title: 'HIIT Cardio Burn',
    branchId: 'g4',
    branchName: 'City Gym CityLand',
    categoryId: 'cat_hiit',
    categoryName: 'HIIT',
    duration: '45 phút',
    credit: 10,
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600',
    isFavorite: false,
  ),
  ExploreClass(
    id: 'c5',
    title: 'Zumba Dance Party',
    branchId: 'g5',
    branchName: 'Zumba Fiesta Studio',
    categoryId: 'cat_zumba',
    categoryName: 'Zumba',
    duration: '60 phút',
    credit: 8,
    imageUrl: 'https://images.unsplash.com/photo-1524594152303-9fd13543dd6e?q=80&w=600',
    isFavorite: false,
  ),
  ExploreClass(
    id: 'c6',
    title: 'Ashtanga Yoga Advance',
    branchId: 'g2',
    branchName: 'California Fitness & Yoga',
    categoryId: 'cat_yoga',
    categoryName: 'Yoga',
    duration: '90 phút',
    credit: 18,
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600',
    isFavorite: false,
  ),
];

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // Styles & colors matching FlexFit aesthetics
  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  late final TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedTab = 'Gyms';

  late List<ExploreGym> _gyms;
  late List<ExploreClass> _classes;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // API-Ready Note:
    // Future API mapping can load data here using repositories:
    // _gyms = await _catalogRepository.getGyms();
    // _classes = await _catalogRepository.getClasses();
    _gyms = List.from(_mockGyms);
    _classes = List.from(_mockClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // API INTEGRATION PLACEHOLDERS / CALLBACKS
  // ==========================================

  void _toggleGymFavorite(String gymId) {
    // API-Ready Note:
    // Connect to POST /api/favorite-gyms/toggle/{gymId}
    setState(() {
      _gyms = _gyms.map((gym) {
        if (gym.id == gymId) {
          final updated = gym.copyWith(isFavorite: !gym.isFavorite);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updated.isFavorite
                    ? 'Đã thêm "${gym.name}" vào danh sách yêu thích.'
                    : 'Đã xóa "${gym.name}" khỏi danh sách yêu thích.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return updated;
        }
        return gym;
      }).toList();
    });
  }

  void _toggleClassFavorite(String classId) {
    // API-Ready Note:
    // Connect to POST /api/favorite-classes/toggle/{classId}
    setState(() {
      _classes = _classes.map((cls) {
        if (cls.id == classId) {
          final updated = cls.copyWith(isFavorite: !cls.isFavorite);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updated.isFavorite
                    ? 'Đã thêm "${cls.title}" vào danh sách yêu thích.'
                    : 'Đã xóa "${cls.title}" khỏi danh sách yêu thích.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return updated;
        }
        return cls;
      }).toList();
    });
  }

  void _onViewGym(ExploreGym gym) {
    // API-Ready Note:
    // Navigate to GymDetail or load GET /api/gyms/{id}
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chi tiết phòng tập: ${gym.name} (Demo UI-only)'),
        backgroundColor: _cardColor,
        action: SnackBarAction(
          label: 'Đóng',
          textColor: _primaryOrange,
          onPressed: () {},
        ),
      ),
    );
  }

  void _onBookClass(ExploreClass item) {
    // API-Ready Note:
    // Connect to POST /api/bookings / book class
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đặt chỗ thành công lớp học: ${item.title} (Demo UI-only)'),
        backgroundColor: _cardColor,
        action: SnackBarAction(
          label: 'OK',
          textColor: _primaryOrange,
          onPressed: () {},
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILD SECTIONS
  // ==========================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'FLEXFIT',
              style: TextStyle(
                color: _primaryOrange,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryOrange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Explore',
                style: TextStyle(
                  color: _primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Tìm và đặt chỗ lớp học từ các đối tác cao cấp của chúng tôi.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm phòng tập, lớp học...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white54),
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Gym', 'Yoga', 'Boxing', 'HIIT', 'Zumba'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              }
            },
            selectedColor: _primaryOrange,
            backgroundColor: _cardColor,
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? _primaryOrange : Colors.white.withValues(alpha: 0.08),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final tabs = ['Gyms', 'Classes', 'Favorites'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tab == 'Gyms'
                        ? 'Phòng gym'
                        : tab == 'Classes'
                            ? 'Lớp học'
                            : 'Yêu thích',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImage(String imageUrl, double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            color: const Color(0xFF1F2937),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                color: Colors.white24,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGymCard(ExploreGym gym) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImage(gym.imageUrl, 180),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    // Distance badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, color: _primaryOrange, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            gym.distance,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Rating badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            gym.rating.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      gym.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: gym.isFavorite ? Colors.red : Colors.white,
                      size: 26,
                    ),
                    onPressed: () => _toggleGymFavorite(gym.id),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        gym.categoryName,
                        style: const TextStyle(
                          color: _primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  gym.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gym.address,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _onViewGym(gym),
                    child: const Text(
                      'Chi tiết phòng tập',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildClassCard(ExploreClass item) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImage(item.imageUrl, 180),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    // Credit badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.credit} Credit',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_filled_rounded, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            item.duration,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: item.isFavorite ? Colors.red : Colors.white,
                      size: 26,
                    ),
                    onPressed: () => _toggleClassFavorite(item.id),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.categoryName,
                        style: const TextStyle(
                          color: _primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.branchName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _onBookClass(item),
                    child: const Text(
                      'Đặt chỗ ngay',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _primaryOrange.withValues(alpha: 0.6),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymList(List<ExploreGym> gyms) {
    if (gyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        message: 'Không tìm thấy phòng gym phù hợp.',
      );
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: gyms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildGymCard(gyms[index]);
      },
    );
  }

  Widget _buildClassList(List<ExploreClass> classes) {
    if (classes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        message: 'Không tìm thấy lớp học phù hợp.',
      );
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: classes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildClassCard(classes[index]);
      },
    );
  }

  Widget _buildFavoriteList(List<ExploreGym> favGyms, List<ExploreClass> favClasses) {
    if (favGyms.isEmpty && favClasses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        message: 'Chưa có mục yêu thích nào.\nHãy bấm vào biểu tượng trái tim để lưu lại.',
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (favGyms.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              'Phòng gym yêu thích',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ...favGyms.map((gym) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGymCard(gym),
              )),
        ],
        if (favClasses.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              'Lớp học yêu thích',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ...favClasses.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildClassCard(item),
              )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply search and category filters
    final filteredGyms = _gyms.where((gym) {
      final matchesCategory = _selectedCategory == 'All' ||
          gym.categoryName.toLowerCase() == _selectedCategory.toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          gym.name.toLowerCase().contains(query) ||
          gym.address.toLowerCase().contains(query) ||
          gym.categoryName.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    final filteredClasses = _classes.where((cls) {
      final matchesCategory = _selectedCategory == 'All' ||
          cls.categoryName.toLowerCase() == _selectedCategory.toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          cls.title.toLowerCase().contains(query) ||
          cls.branchName.toLowerCase().contains(query) ||
          cls.categoryName.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    final favGyms = filteredGyms.where((g) => g.isFavorite).toList();
    final favClasses = filteredClasses.where((c) => c.isFavorite).toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 20),
              _buildTabSwitcher(),
              const SizedBox(height: 20),
              if (_selectedTab == 'Gyms')
                _buildGymList(filteredGyms)
              else if (_selectedTab == 'Classes')
                _buildClassList(filteredClasses)
              else
                _buildFavoriteList(favGyms, favClasses),
            ],
          ),
        ),
      ),
    );
  }
}
