import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/credit_refresh_notifier.dart';
import '../../data/payment_status_override_notifier.dart';
import 'payment_history_page.dart';

class PaymentWebviewPage extends StatefulWidget {
  const PaymentWebviewPage({
    super.key,
    required this.paymentUrl,
    this.paymentId,
    this.providerTransactionCode,
  });

  final String paymentUrl;
  final String? paymentId;
  final String? providerTransactionCode;

  @override
  State<PaymentWebviewPage> createState() => _PaymentWebviewPageState();
}

class _PaymentWebviewPageState extends State<PaymentWebviewPage> {
  late final WebViewController _controller;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('PAYOS WEBVIEW URL: ${request.url}');
            final url = request.url.toLowerCase();

            if (url == 'https://www.flexfit.io.vn/payment/cancel' ||
                url.contains('/payment/cancel') ||
                url.contains('cancel') ||
                url.contains('cancelled') ||
                url.contains('canceled')) {
              _handleCancel();
              return NavigationDecision.prevent;
            }

            if (url == 'https://www.flexfit.io.vn/payment/success' ||
                url.contains('/payment/success') ||
                url.contains('success') ||
                url.contains('paid') ||
                url.contains('completed')) {
              _handleSuccess();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleCancel() {
    if (!mounted || _isCompleting) return;
    _isCompleting = true;

    PaymentStatusOverrideNotifier.instance.markCancelled(
      paymentId: widget.paymentId,
      orderCode: widget.providerTransactionCode,
    );
    CreditRefreshNotifier.instance.notifyCreditChanged();
    final messenger = ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Thanh toán đã bị hủy'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _handleSuccess() {
    if (!mounted || _isCompleting) return;
    _isCompleting = true;

    PaymentStatusOverrideNotifier.instance.clearCancelled(
      paymentId: widget.paymentId,
      orderCode: widget.providerTransactionCode,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanh toán thành công, đang cập nhật lịch sử'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      CreditRefreshNotifier.instance.notifyCreditChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán PayOS'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
