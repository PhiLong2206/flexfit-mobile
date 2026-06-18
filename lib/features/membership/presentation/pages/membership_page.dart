import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/payment_deep_link_service.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/credit_refresh_notifier.dart';
import '../../data/models/credit_package_model.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../../home/presentation/pages/home_page.dart';
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
  final _profileRepository = ProfileRepository();

  late Future<_MembershipData> _future;
  String? _buyingPackageId;
  String? _pendingPaymentId;
  bool _shouldRefreshOnResume = false;
  StreamSubscription<PaymentDeepLinkResult>? _paymentLinkSubscription;
  final Set<String> _handledPaymentLinks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
    _listenForPaymentDeepLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paymentLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldRefreshOnResume) {
      _shouldRefreshOnResume = false;
      unawaited(_refreshAfterPayment(showDialogs: true));
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

  void _listenForPaymentDeepLinks() {
    _paymentLinkSubscription = PaymentDeepLinkService.instance.links.listen(
      _handlePaymentDeepLink,
    );
    unawaited(_handleInitialPaymentDeepLink());
  }

  Future<void> _handleInitialPaymentDeepLink() async {
    final result = await PaymentDeepLinkService.instance.getInitialLink();
    if (result != null) {
      await _handlePaymentDeepLink(result);
    }
  }

  Future<void> _handlePaymentDeepLink(PaymentDeepLinkResult result) async {
    final linkKey = result.uri.toString();
    if (!_handledPaymentLinks.add(linkKey) || !mounted) {
      return;
    }

    _shouldRefreshOnResume = false;
    _pendingPaymentId ??= result.uri.queryParameters['paymentId'];

    if (result.status == PaymentDeepLinkStatus.success) {
      await _refreshAfterPayment(showDialogs: false);
      await _reloadProfileQuietly();
      if (!mounted) {
        return;
      }
      _showPaymentSnackBar('Thanh toán thành công', AppColors.completed);
      return;
    }

    _pendingPaymentId = null;
    await _refresh();
    if (!mounted) {
      return;
    }
    _showPaymentSnackBar('Bạn đã hủy giao dịch', AppColors.cancelled);
  }

  void _showPaymentSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _reload() {
    if (!mounted) {
      return;
    }
    setState(() {
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _startPayment(CreditPackageModel package) async {
    if (_buyingPackageId != null) {
      return;
    }

    final confirmed = await _confirmPayment(package);
    if (!mounted) {
      return;
    }
    if (confirmed != true) {
      await _showPaymentCancelledDialog(
        message: 'Bạn đã huỷ thanh toán cho gói Credit này.',
      );
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

      _pendingPaymentId = payment.paymentId;
      final resolvedUrl = _paymentRepository.resolvePaymentUrl(paymentUrl);
      final opened = await launchUrl(
        Uri.parse(resolvedUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw const ApiException('Không mở được liên kết thanh toán.');
      }

      _shouldRefreshOnResume = true;
      await _refreshAfterPayment(showDialogs: false);
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
      await _showPaymentFailedDialog(_friendlyPaymentError(error));
    } finally {
      if (mounted) {
        setState(() => _buyingPackageId = null);
      }
    }
  }

  Future<bool?> _confirmPayment(CreditPackageModel package) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: Text(
            'Nạp ${package.totalCredit} Credit?',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '${package.name}\n${_formatCurrency(package.price)}',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Thanh toán'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshAfterPayment({required bool showDialogs}) async {
    final paymentId = _pendingPaymentId;
    final status = paymentId == null
        ? null
        : await _findPaymentStatus(paymentId);

    if (mounted) {
      final future = _load();
      setState(() {
        _future = future;
      });
      try {
        await future;
        CreditRefreshNotifier.instance.notifyCreditChanged();
      } catch (_) {
        if (showDialogs) {
          return;
        }
      }
    }

    if (_isPaymentSuccess(status)) {
      _pendingPaymentId = null;
      await _reloadProfileQuietly();
      if (showDialogs && mounted) {
        await _showPaymentSuccessDialog();
      }
      return;
    }

    if (!showDialogs || !mounted) {
      return;
    }

    if (_isPaymentCancelled(status)) {
      _pendingPaymentId = null;
      await _showPaymentCancelledDialog(
        message:
            'Giao dịch đã bị huỷ. Bạn có thể chọn lại gói Credit bất kỳ lúc nào.',
      );
    } else if (_isPaymentFailed(status)) {
      _pendingPaymentId = null;
      await _showPaymentFailedDialog(
        'Thanh toán thất bại hoặc giao dịch chưa được xử lý thành công.',
      );
    }
  }

  Future<String?> _findPaymentStatus(String paymentId) async {
    try {
      final history = await _paymentRepository.getMyPaymentHistory();
      for (final payment in history) {
        if (payment.paymentId == paymentId) {
          return payment.status;
        }
      }
    } catch (_) {
      // Payment history is optional; credit refresh still runs without it.
    }
    return null;
  }

  Future<void> _reloadProfileQuietly() async {
    try {
      await _profileRepository.getMe();
    } catch (_) {
      // Credit is the visible source of truth here; profile refresh should not
      // block the payment completion UI.
    }
  }

  Future<void> _showPaymentSuccessDialog() {
    return _showResultDialog(
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.completed,
      title: 'Thanh toán thành công',
      message: 'Credit và hồ sơ thành viên đã được cập nhật.',
      buttonText: 'Đóng',
    );
  }

  Future<void> _showPaymentFailedDialog(String message) {
    return _showResultDialog(
      icon: Icons.error_rounded,
      iconColor: AppColors.cancelled,
      title: 'Thanh toán thất bại',
      message: message,
      buttonText: 'Thử lại',
    );
  }

  Future<void> _showPaymentCancelledDialog({required String message}) {
    return _showResultDialog(
      icon: Icons.cancel_rounded,
      iconColor: Colors.white60,
      title: 'Thanh toán đã huỷ',
      message: message,
      buttonText: 'Đóng',
    );
  }

  Future<void> _showResultDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
  }) {
    if (!mounted) {
      return Future.value();
    }
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
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
  leading: IconButton(
    tooltip: 'Quay lại',
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    onPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    },
  ),
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
                  'Đã nhận ${credit.totalEarned} - Đã dùng ${credit.totalSpent}',
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
        boxShadow: package.isPopular
            ? [
                BoxShadow(
                  color: _MembershipPageState._primaryOrange.withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
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
              if (package.isPopular) const _PopularBadge(),
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
                '+${package.bonusCredit} bonus - ${package.totalCredit} Credit',
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

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _MembershipPageState._primaryOrange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _MembershipPageState._primaryOrange.withValues(alpha: 0.36),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: _MembershipPageState._primaryOrange,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Phổ biến',
            style: TextStyle(
              color: _MembershipPageState._primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
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

bool _isPaymentSuccess(String? status) {
  final value = status?.toLowerCase() ?? '';
  return value.contains('success') || value.contains('paid');
}

bool _isPaymentCancelled(String? status) {
  final value = status?.toLowerCase() ?? '';
  return value.contains('cancel') ||
      value.contains('huy') ||
      value.contains('huỷ');
}

bool _isPaymentFailed(String? status) {
  final value = status?.toLowerCase() ?? '';
  return value.contains('fail') || value.contains('error');
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
  return '$bufferđ';
}
