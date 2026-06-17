import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/credit_package_model.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_history_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with WidgetsBindingObserver {
  static const Color _backgroundColor = AppConstants.backgroundColor;
  static const Color _cardColor = AppConstants.surfaceColor;
  static const Color _primaryOrange = AppConstants.primaryColor;

  final _creditRepository = CreditRepository();
  final _paymentRepository = PaymentRepository();
  late Future<_MembershipData> _future;
  String? _buyingPackageId;
  bool _shouldRefreshOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldRefreshOnResume) {
      _shouldRefreshOnResume = false;
      _reload();
    }
  }

  Future<_MembershipData> _load() async {
    final creditFuture = _creditRepository.getMyCredit();
    final packagesFuture = _creditRepository.getPackages();
    return _MembershipData(
      credit: await creditFuture,
      packages: await packagesFuture,
    );
  }

  void _reload() {
    if (!mounted) {
      return;
    }
    setState(() => _future = _load());
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _startPayment(CreditPackageModel package) async {
    if (_buyingPackageId != null) {
      return;
    }

    setState(() => _buyingPackageId = package.id);
    try {
      final payment = await _paymentRepository.createPayment(
        packageId: package.id,
      );
      final paymentUrl = payment.paymentUrl;
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw const ApiException('Backend chưa trả về liên kết thanh toán.');
      }

      final resolvedUrl = _paymentRepository.resolvePaymentUrl(paymentUrl);
      final uri = Uri.parse(resolvedUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw const ApiException('Không mở được liên kết thanh toán.');
      }

      _shouldRefreshOnResume = true;
      _reload();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã mở cổng thanh toán. FlexFit sẽ cập nhật khi bạn quay lại.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyPaymentError(error))));
    } finally {
      if (mounted) {
        setState(() => _buyingPackageId = null);
      }
    }
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PaymentHistoryPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Thành viên'),
        backgroundColor: _backgroundColor,
        actions: [
          IconButton(
            tooltip: 'Lịch sử thanh toán',
            onPressed: _openHistory,
            icon: const Icon(Icons.receipt_long_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_MembershipData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _StateMessage(
                title: 'Không tải được thông tin thành viên',
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CreditHeader(credit: data.credit),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Gói Credit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _openHistory,
                                    icon: const Icon(
                                      Icons.history_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Lịch sử'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (data.packages.isEmpty)
                                const _EmptyPackages()
                              else
                                _PackageGrid(
                                  packages: data.packages,
                                  isWide: isWide,
                                  buyingPackageId: _buyingPackageId,
                                  onBuy: _startPayment,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CreditHeader extends StatelessWidget {
  const _CreditHeader({required this.credit});

  final UserCreditModel credit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF241A14)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _MembershipPageState._primaryOrange.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: _MembershipPageState._primaryOrange.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: _MembershipPageState._primaryOrange,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${credit.balance} Credit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đã nhận ${credit.totalEarned} · Đã dùng ${credit.totalSpent}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
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

class _PackageGrid extends StatelessWidget {
  const _PackageGrid({
    required this.packages,
    required this.isWide,
    required this.buyingPackageId,
    required this.onBuy,
  });

  final List<CreditPackageModel> packages;
  final bool isWide;
  final String? buyingPackageId;
  final ValueChanged<CreditPackageModel> onBuy;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (final package in packages) ...[
            _PackageCard(
              package: package,
              isBuying: buyingPackageId == package.id,
              isDisabled:
                  buyingPackageId != null && buyingPackageId != package.id,
              onBuy: () => onBuy(package),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final package in packages)
          SizedBox(
            width: 374,
            child: _PackageCard(
              package: package,
              isBuying: buyingPackageId == package.id,
              isDisabled:
                  buyingPackageId != null && buyingPackageId != package.id,
              onBuy: () => onBuy(package),
            ),
          ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isBuying,
    required this.isDisabled,
    required this.onBuy,
  });

  final CreditPackageModel package;
  final bool isBuying;
  final bool isDisabled;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final hasBonus = package.bonusCredit > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _MembershipPageState._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: package.isPopular
              ? _MembershipPageState._primaryOrange
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (package.isPopular)
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: _MembershipPageState._primaryOrange,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            package.description ?? '${package.creditAmount} Credit FlexFit',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          if (hasBonus) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _MembershipPageState._primaryOrange.withValues(
                  alpha: 0.14,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+${package.bonusCredit} bonus · ${package.totalCredit} Credit',
                style: const TextStyle(
                  color: _MembershipPageState._primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${package.creditAmount} Credit',
                style: const TextStyle(
                  color: _MembershipPageState._primaryOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: (isBuying || isDisabled) ? null : onBuy,
                child: isBuying
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_formatCurrency(package.price)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPackages extends StatelessWidget {
  const _EmptyPackages();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _MembershipPageState._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Text(
        'Không có gói Credit đang hoạt động.',
        style: TextStyle(color: Colors.white70),
      ),
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
              color: _MembershipPageState._primaryOrange,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
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

class _MembershipData {
  const _MembershipData({required this.credit, required this.packages});

  final UserCreditModel credit;
  final List<CreditPackageModel> packages;
}

String _friendlyPaymentError(Object error) {
  if (error is ApiException && error.statusCode == 401) {
    return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại để thanh toán.';
  }
  return error.toString();
}

String _formatCurrency(double value) {
  final text = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final position = text.length - i;
    buffer.write(text[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${buffer.toString()}đ';
}
