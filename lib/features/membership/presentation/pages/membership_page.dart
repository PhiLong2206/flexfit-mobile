import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/credit_package_model.dart';
import '../../data/repositories/credit_repository.dart';
import '../providers/membership_provider.dart';

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembershipProvider(CreditRepository())..loadData(),
      child: const _MembershipView(),
    );
  }
}

class _MembershipView extends StatelessWidget {
  const _MembershipView();

  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembershipProvider>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Thành viên'),
        backgroundColor: _backgroundColor,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryOrange),
              );
            }

            if (provider.error != null && provider.credit == null) {
              return _StateMessage(
                title: 'Không tải được thông tin thành viên',
                message: provider.error!,
                onRetry: () {
                  context.read<MembershipProvider>().loadData();
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () {
                return context.read<MembershipProvider>().loadData();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _CreditHeader(credit: provider.credit),
                  const SizedBox(height: 18),
                  const Text(
                    'Gói Credit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.packages.isEmpty)
                    const _EmptyPackages()
                  else
                    for (final package in provider.packages) ...[
                      _PackageCard(
                        package: package,
                        isBuying:
                        provider.buyingPackageId == package.id,
                        onBuy: () async {
                          final success = await context
                              .read<MembershipProvider>()
                              .buyPackage(package.id);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Mua ${package.name} thành công.'
                                    : provider.error ?? 'Mua gói thất bại.',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
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

  final UserCreditModel? credit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _MembershipView._cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: _MembershipView._primaryOrange,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${credit?.balance ?? 0} Credit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đã nhận ${credit?.totalEarned ?? 0} - Đã dùng ${credit?.totalSpent ?? 0}',
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

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isBuying,
    required this.onBuy,
  });

  final CreditPackageModel package;
  final bool isBuying;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _MembershipView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: package.isPopular
              ? _MembershipView._primaryOrange
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
                  color: _MembershipView._primaryOrange,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            package.description ?? '${package.creditAmount} Credit FlexFit',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${package.creditAmount} Credit',
                style: const TextStyle(
                  color: _MembershipView._primaryOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: isBuying ? null : onBuy,
                child: Text(
                  isBuying
                      ? 'Đang mua...'
                      : '${package.price.toStringAsFixed(0)} VND',
                ),
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
    return const Text(
      'Không có gói Credit đang hoạt động.',
      style: TextStyle(color: Colors.white70),
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
              color: _MembershipView._primaryOrange,
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
            FilledButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}