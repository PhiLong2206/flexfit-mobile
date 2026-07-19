class PaymentStatusOverrideNotifier {
  PaymentStatusOverrideNotifier._();

  static final PaymentStatusOverrideNotifier instance =
      PaymentStatusOverrideNotifier._();

  final Set<String> cancelledPaymentIds = <String>{};
  final Set<String> cancelledOrderCodes = <String>{};

  void markCancelled({String? paymentId, String? orderCode}) {
    final normalizedPaymentId = _normalize(paymentId);
    final normalizedOrderCode = _normalize(orderCode);

    if (normalizedPaymentId != null) {
      cancelledPaymentIds.add(normalizedPaymentId);
    }
    if (normalizedOrderCode != null) {
      cancelledOrderCodes.add(normalizedOrderCode);
    }
  }

  bool isCancelled({String? paymentId, String? orderCode}) {
    final normalizedPaymentId = _normalize(paymentId);
    final normalizedOrderCode = _normalize(orderCode);

    return normalizedPaymentId != null &&
            cancelledPaymentIds.contains(normalizedPaymentId) ||
        normalizedOrderCode != null &&
            cancelledOrderCodes.contains(normalizedOrderCode);
  }

  void clearCancelled({String? paymentId, String? orderCode}) {
    final normalizedPaymentId = _normalize(paymentId);
    final normalizedOrderCode = _normalize(orderCode);

    if (normalizedPaymentId != null) {
      cancelledPaymentIds.remove(normalizedPaymentId);
    }
    if (normalizedOrderCode != null) {
      cancelledOrderCodes.remove(normalizedOrderCode);
    }
  }

  String? _normalize(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text.toLowerCase();
  }
}
