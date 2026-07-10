import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../booking/presentation/screens/booking_confirmation_page.dart';
import '../../../booking/presentation/screens/gym_detail_page.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/presentation/widgets/gym_time_slot_sheet.dart';
import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart' as catalog;
import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../home/presentation/widgets/gym_card.dart';
import '../../../../core/presentation/widgets/main_bottom_navigation_bar.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _catalogRepository = CatalogRepository();
  late final TabController _tabController;
  late Future<_ExploreData> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<_ExploreData> _load() async {
    final results = await Future.wait([
      _catalogRepository.getGyms(),
      _catalogRepository.getClasses(),
      _catalogRepository.getCategories(),
      _catalogRepository.getBranches(),
    ]);
    return _ExploreData(
      gyms: results[0] as List<Gym>,
      classes: results[1] as List<FitnessClass>,
      categories: results[2] as List<catalog.Category>,
      branches: results[3] as List<Branch>,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _bookClass(
    BuildContext bookingContext,
    FitnessClass fitnessClass,
  ) async {
    try {
      await bookingContext.read<BookingProvider>().createClassBooking(
        fitnessClass.id,
        startTime: fitnessClass.startTime,
        endTime: fitnessClass.endTime,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt lớp học thành công.')));
    } catch (error) {
      if (!mounted) return;
      _showBookingError(error.toString());
    }
  }

  void _showBookingError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: const Text('Khám phá'),
            backgroundColor: _backgroundColor,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: _primaryOrange,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Phòng gym'),
                Tab(text: 'Lớp học'),
                Tab(text: 'Danh mục'),
              ],
            ),
          ),
          body: SafeArea(
            child: FutureBuilder<_ExploreData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _StateMessage(
                    title: 'Không tải được dữ liệu khám phá',
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }
                final data = snapshot.data!;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _GymList(gyms: data.gyms, branches: data.branches),
                    _ClassList(
                      classes: data.classes,
                      bookingClassId: context
                          .watch<BookingProvider>()
                          .bookingClassId,
                      onBook: _bookClass,
                    ),
                    _CategoryList(categories: data.categories),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: const MainBottomNavigationBar(currentIndex: 2),
        ),
      ),
    );
  }
}

class _GymList extends StatelessWidget {
  const _GymList({required this.gyms, required this.branches});

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48';

  final List<Gym> gyms;
  final List<Branch> branches;

  Branch? _branchForGym(Gym gym) {
    return CatalogRepository().resolveBranchForGym(gym, branches);
  }

  Future<void> _bookOpenGym(BuildContext context, Gym gym) async {
    final branch = _branchForGym(gym);
    if (branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phòng gym này chưa có chi nhánh để đặt lịch.'),
        ),
      );
      return;
    }

    final selection = await showGymTimeSlotSheet(
      context: context,
      gymName: gym.name,
      branch: branch,
    );
    if (!context.mounted || selection == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingConfirmationPage(
          gymName: gym.name,
          address: selection.branch.displayAddress,
          branchName: selection.branch.name,
          rating: gym.ratingAverage,
          creditCost: selection.branch.creditCost,
          branchId: selection.branch.id,
          startTime: selection.startTime,
          endTime: selection.endTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (gyms.isEmpty) {
      return const _EmptyList(message: 'Không tìm thấy phòng gym.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: gyms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final gym = gyms[index];
        return GymCard(
          imageUrl: gym.thumbnailUrl ?? _fallbackImage,
          name: gym.name,
          location: gym.description ?? gym.status,
          rating: gym.ratingAverage,
          credits: _branchForGym(gym)?.creditCost ?? 0,
          onBookTap: () => _bookOpenGym(context, gym),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GymDetailPage(gymId: gym.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({
    required this.classes,
    required this.bookingClassId,
    required this.onBook,
  });

  final List<FitnessClass> classes;
  final String? bookingClassId;
  final void Function(BuildContext context, FitnessClass fitnessClass) onBook;

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const _EmptyList(message: 'Không có lớp học.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: classes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final fitnessClass = classes[index];
        final isBooking = bookingClassId == fitnessClass.id;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _ExplorePageState._cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fitnessClass.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${fitnessClass.branchName} - ${fitnessClass.categoryName}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatTime(fitnessClass.startTime)}-${_formatTime(fitnessClass.endTime)}',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${fitnessClass.creditCost} Credit',
                    style: const TextStyle(
                      color: _ExplorePageState._primaryOrange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isBooking
                        ? null
                        : () => onBook(context, fitnessClass),
                    child: Text(isBooking ? 'Đang đặt...' : 'Đặt lịch'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories});

  final List<catalog.Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyList(message: 'Không có danh mục.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          tileColor: _ExplorePageState._cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: const Icon(
            Icons.fitness_center_rounded,
            color: _ExplorePageState._primaryOrange,
          ),
          title: Text(category.name),
          subtitle: Text(category.description ?? 'Danh mục lớp học'),
        );
      },
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: _ExplorePageState._primaryOrange,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _ExploreData {
  const _ExploreData({
    required this.gyms,
    required this.classes,
    required this.categories,
    required this.branches,
  });

  final List<Gym> gyms;
  final List<FitnessClass> classes;
  final List<catalog.Category> categories;
  final List<Branch> branches;
}
