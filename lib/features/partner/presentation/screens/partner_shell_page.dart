import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/local_storage.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../providers/partner_provider.dart';
import 'subpages/partner_branches_subpage.dart';
import 'subpages/partner_classes_subpage.dart';
import 'subpages/partner_customers_subpage.dart';
import 'subpages/partner_overview_subpage.dart';
import 'subpages/partner_promotions_subpage.dart';
import 'subpages/partner_revenue_subpage.dart';
import 'subpages/partner_reviews_subpage.dart';
import 'subpages/partner_settings_subpage.dart';
import 'subpages/partner_staff_subpage.dart';

class PartnerShellPage extends StatefulWidget {
  const PartnerShellPage({super.key});

  @override
  State<PartnerShellPage> createState() => _PartnerShellPageState();
}

class _PartnerShellPageState extends State<PartnerShellPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartnerProvider>().fetchAllData();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await LocalStorage.removeToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Tổng quan';
      case 1:
        return 'Cơ sở & Chi nhánh';
      case 2:
        return 'Quản lý lớp học';
      case 3:
        return 'Nhân sự & Nhân viên';
      case 4:
        return 'Hội viên';
      case 5:
        return 'Báo cáo doanh thu';
      case 6:
        return 'Chương trình khuyến mãi';
      case 7:
        return 'Đánh giá & Phản hồi';
      case 8:
        return 'Cài đặt';
      default:
        return 'Partner Area';
    }
  }

  Widget _getBody(PartnerProvider provider) {
    switch (_currentIndex) {
      case 0:
        return PartnerOverviewSubpage(provider: provider);
      case 1:
        return PartnerBranchesSubpage(provider: provider);
      case 2:
        return PartnerClassesSubpage(provider: provider);
      case 3:
        return PartnerStaffSubpage(provider: provider);
      case 4:
        return PartnerCustomersSubpage(provider: provider);
      case 5:
        return PartnerRevenueSubpage(provider: provider);
      case 6:
        return PartnerPromotionsSubpage(provider: provider);
      case 7:
        return PartnerReviewsSubpage(provider: provider);
      case 8:
        return PartnerSettingsSubpage(provider: provider);
      default:
        return PartnerOverviewSubpage(provider: provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (provider.isLoadingStats ||
              provider.isLoadingBranches ||
              provider.isLoadingClasses ||
              provider.isLoadingCustomers ||
              provider.isLoadingRevenue ||
              provider.isLoadingReviews ||
              provider.isLoadingPromotions)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppConstants.surfaceColor,
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppConstants.cardColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
                child: const Text(
                  'FP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              accountName: const Text(
                'FLEXFIT PARTNER',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              accountEmail: const Text(
                'partner@flexfit.io',
                style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    label: 'Tổng quan',
                  ),
                  _buildDrawerItem(
                    index: 1,
                    icon: Icons.storefront_outlined,
                    label: 'Quản lý cơ sở',
                  ),
                  _buildDrawerItem(
                    index: 2,
                    icon: Icons.calendar_today_outlined,
                    label: 'Quản lý lớp học',
                  ),
                  _buildDrawerItem(
                    index: 3,
                    icon: Icons.people_outline,
                    label: 'Nhân sự & Nhân viên',
                  ),
                  _buildDrawerItem(
                    index: 4,
                    icon: Icons.badge_outlined,
                    label: 'Quản lý hội viên',
                  ),
                  _buildDrawerItem(
                    index: 5,
                    icon: Icons.monetization_on_outlined,
                    label: 'Báo cáo doanh thu',
                  ),
                  _buildDrawerItem(
                    index: 6,
                    icon: Icons.local_offer_outlined,
                    label: 'Khuyến mãi',
                  ),
                  _buildDrawerItem(
                    index: 7,
                    icon: Icons.rate_review_outlined,
                    label: 'Đánh giá & Phản hồi',
                  ),
                  _buildDrawerItem(
                    index: 8,
                    icon: Icons.settings_outlined,
                    label: 'Cài đặt',
                  ),
                  const Divider(color: AppConstants.borderColor),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      _logout(context);
                    },
                  ),
                ],
              ),
            ),

            // Version at bottom
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Phiên bản 1.0.0 (GymPartner)',
                style: TextStyle(color: AppConstants.textSecondary, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      body: _getBody(provider),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppConstants.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppConstants.primaryColor.withOpacity(0.08),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.of(context).pop(); // Close drawer
      },
    );
  }
}
