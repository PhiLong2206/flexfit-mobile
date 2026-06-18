import 'dart:async';

import 'package:app_links/app_links.dart';

enum PaymentDeepLinkStatus { success, cancel }

class PaymentDeepLinkResult {
  const PaymentDeepLinkResult({
    required this.status,
    required this.uri,
  });

  final PaymentDeepLinkStatus status;
  final Uri uri;
}

class PaymentDeepLinkService {
  PaymentDeepLinkService._();

  static final PaymentDeepLinkService instance = PaymentDeepLinkService._();

  final AppLinks _appLinks = AppLinks();

  Stream<PaymentDeepLinkResult> get links {
    return _appLinks.uriLinkStream
        .map(_parse)
        .where((result) => result != null)
        .cast<PaymentDeepLinkResult>();
  }

  Future<PaymentDeepLinkResult?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      return _parse(uri);
    } catch (_) {
      return null;
    }
  }

  PaymentDeepLinkResult? _parse(Uri? uri) {
    if (uri == null) return null;

    if (uri.scheme != 'flexfit' || uri.host != 'payment') {
      return null;
    }

    final path = uri.path.toLowerCase();

    if (path == '/success') {
      return PaymentDeepLinkResult(
        status: PaymentDeepLinkStatus.success,
        uri: uri,
      );
    }

    if (path == '/cancel') {
      return PaymentDeepLinkResult(
        status: PaymentDeepLinkStatus.cancel,
        uri: uri,
      );
    }

    return null;
  }
}