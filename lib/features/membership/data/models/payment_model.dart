class PaymentCreateResult {
  const PaymentCreateResult({
    required this.paymentId,
    required this.packageId,
    required this.amount,
    required this.status,
    this.userId,
    this.paymentMethod,
    this.paymentUrl,
    this.createdAt,
  });

  final String paymentId;
  final String? userId;
  final String packageId;
  final double amount;
  final String? paymentMethod;
  final String? paymentUrl;
  final String status;
  final DateTime? createdAt;

  factory PaymentCreateResult.fromJson(Map<String, dynamic> json) {
    return PaymentCreateResult(
      paymentId: _string(json, 'paymentId') ?? '',
      userId: _string(json, 'userId'),
      packageId: _string(json, 'packageId') ?? '',
      amount: _double(json, 'amount'),
      paymentMethod: _string(json, 'paymentMethod'),
      paymentUrl: _string(json, 'paymentUrl'),
      status: _string(json, 'status') ?? 'Pending',
      createdAt: _dateTime(json, 'createdAt'),
    );
  }
}

class PaymentHistoryModel {
  const PaymentHistoryModel({
    required this.paymentId,
    required this.packageId,
    required this.amount,
    required this.status,
    this.packageName,
    this.paymentMethod,
    this.providerTransactionCode,
    this.paidAt,
    this.createdAt,
  });

  final String paymentId;
  final String packageId;
  final String? packageName;
  final double amount;
  final String? paymentMethod;
  final String? providerTransactionCode;
  final String status;
  final DateTime? paidAt;
  final DateTime? createdAt;

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      paymentId: _string(json, 'paymentId') ?? '',
      packageId: _string(json, 'packageId') ?? '',
      packageName: _string(json, 'packageName'),
      amount: _double(json, 'amount'),
      paymentMethod: _string(json, 'paymentMethod'),
      providerTransactionCode: _string(json, 'providerTransactionCode'),
      status: _string(json, 'status') ?? 'Pending',
      paidAt: _dateTime(json, 'paidAt'),
      createdAt: _dateTime(json, 'createdAt'),
    );
  }
}

String? _string(Map<String, dynamic> json, String key) {
  final value = _read(json, key);
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

double _double(Map<String, dynamic> json, String key) {
  return double.tryParse(_read(json, key)?.toString() ?? '') ?? 0;
}

DateTime? _dateTime(Map<String, dynamic> json, String key) {
  final value = _read(json, key)?.toString();
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
