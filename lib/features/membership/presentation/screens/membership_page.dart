import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/main_bottom_navigation_bar.dart';
import '../../data/credit_refresh_notifier.dart';
import '../../data/models/credit_package_model.dart';
import '../providers/membership_provider.dart';
import 'payment_history_page.dart';
import 'payment_webview_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipProvider>().loadPackages();
    });
    CreditRefreshNotifier.instance.addListener(_reload);
  }

  @override
  void dispose() {
    CreditRefreshNotifier.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) {
      context.read<MembershipProvider>().loadPackages();
    }
  }

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
            constraints: const BoxConstraints(maxWidth: 430),
            child: Consumer<MembershipProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.packages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.packages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: provider.loadPackages,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadPackages,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    children: [
                      const _MembershipHeader(),
                      const SizedBox(height: 20),
                      _currentCredit(provider.currentCredit),
                      const SizedBox(height: 16),
                      _paymentHistoryButton(context),
                      const SizedBox(height: 24),
                      _title('Nạp Credit & Thành viên'),
                      const SizedBox(height: 12),
                      if (provider.packages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Chưa có gói credit khả dụng',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ...provider.packages.map(
                          (pkg) => _creditCard(pkg, provider),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _currentCredit(UserCreditModel? credit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF2A1E18)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN CREDIT',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'FLEXFIT MEMBER',
            style: TextStyle(
              color: orange,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${credit?.balance ?? 0} Credits khả dụng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m == m.toInt() ? m.toInt() : m.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return '${value.toInt()}đ';
  }

  Widget _creditCard(CreditPackageModel pkg, MembershipProvider provider) {
    final title = pkg.name;
    final priceStr = _formatCurrency(pkg.price);
    final desc =
        pkg.description ??
        (pkg.bonusCredit > 0
            ? 'Tặng thêm ${pkg.bonusCredit} credits'
            : 'Mua thêm ${pkg.creditAmount} credits');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pkg.isPopular ? orange : Colors.white12,
          width: pkg.isPopular ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: orange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: orange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${pkg.creditAmount} Credits',
                        style: const TextStyle(
                          color: orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (pkg.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                priceStr,
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
                    backgroundColor: pkg.isPopular
                        ? orange
                        : AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _handleBuy(context, provider, pkg),
                  child: const Text(
                    'Mua',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long, color: orange, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch sử thanh toán',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem các giao dịch nạp credit',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBuy(
    BuildContext context,
    MembershipProvider provider,
    CreditPackageModel pkg,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final payment = await provider.createPayment(pkg.id);
    final paymentUrl = payment?.paymentUrl;

    if (!context.mounted) return;
    Navigator.of(context).pop(); // hide loading

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWebviewPage(
            paymentUrl: paymentUrl,
            paymentId: payment?.paymentId,
            providerTransactionCode:
                payment?.orderCode ?? payment?.providerTransactionCode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tạo giao dịch. Vui lòng thử lại.'),
        ),
      );
    }
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
          child: Text('DR', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
