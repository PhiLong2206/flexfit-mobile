import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final _repository = PaymentRepository();
  late Future<List<PaymentHistoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getMyPaymentHistory();
  }

  Future<void> _refresh() async {
    final future = _repository.getMyPaymentHistory();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: SafeArea(
        child: FutureBuilder<List<PaymentHistoryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _StateMessage(
                icon: Icons.receipt_long_rounded,
                title: 'Không tải được lịch sử thanh toán',
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() => _future = _repository.getMyPaymentHistory());
                },
              );
            }

            final payments = snapshot.data ?? const [];
            if (payments.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [SizedBox(height: 120), _EmptyHistory()],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                itemBuilder: (context, index) {
                  return _PaymentHistoryCard(payment: payments[index]);
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: payments.length,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.payment});

  final PaymentHistoryModel payment;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _statusColor(payment.status);
    final date = payment.paidAt ?? payment.createdAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.payments_rounded, color: badgeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.packageName ?? 'Gói Credit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                        payment.paymentMethod ?? 'PAYOS',
                        if (date != null) _formatDate(date),
                      ].join(' · '),
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: payment.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _formatCurrency(payment.amount),
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  '#${_shortId(payment.paymentId)}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          if (payment.providerTransactionCode?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'Mã giao dịch: ${payment.providerTransactionCode}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.receipt_long_rounded,
          color: AppConstants.primaryColor,
          size: 46,
        ),
        SizedBox(height: 12),
        Text(
          'Chưa có giao dịch thanh toán',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Các lần nạp Credit sẽ hiển thị tại đây.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
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
            Icon(icon, color: AppConstants.primaryColor, size: 42),
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

Color _statusColor(String status) {
  final value = status.toLowerCase();
  if (value.contains('success') || value.contains('paid')) {
    return AppColors.completed;
  }
  if (value.contains('fail') || value.contains('cancel')) {
    return AppColors.cancelled;
  }
  return AppConstants.primaryColor;
}

String _statusLabel(String status) {
  final value = status.toLowerCase();
  if (value.contains('success') || value.contains('paid')) {
    return 'Thành công';
  }
  if (value.contains('fail')) {
    return 'Thất bại';
  }
  if (value.contains('cancel')) {
    return 'Đã hủy';
  }
  return 'Đang xử lý';
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

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _shortId(String value) {
  if (value.length <= 8) {
    return value;
  }
  return value.substring(0, 8).toUpperCase();
}
