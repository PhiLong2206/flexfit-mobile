class CreditPackageModel {
  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.creditAmount,
    required this.bonusCredit,
    required this.price,
    this.description,
    required this.isActive,
    required this.isPopular,
  });

  final String id;
  final String name;
  final int creditAmount;
  final int bonusCredit;
  final double price;
  final String? description;
  final bool isActive;
  final bool isPopular;

  factory CreditPackageModel.fromJson(Map<String, dynamic> json) {
    return CreditPackageModel(
      id: (_read(json, 'packageId') ?? _read(json, 'id')).toString(),
      name:
          (_read(json, 'packageName') ?? _read(json, 'name'))?.toString() ??
          'Gói Credit',
      creditAmount:
          int.tryParse(_read(json, 'creditAmount')?.toString() ?? '') ?? 0,
      bonusCredit:
          int.tryParse(_read(json, 'bonusCredit')?.toString() ?? '') ?? 0,
      price: double.tryParse(_read(json, 'price')?.toString() ?? '') ?? 0,
      description: _read(json, 'description')?.toString(),
      isActive: _read(json, 'isActive') != false,
      isPopular: _read(json, 'isPopular') == true,
    );
  }

  int get totalCredit => creditAmount + bonusCredit;
}

class UserCreditModel {
  const UserCreditModel({
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
  });

  final int balance;
  final int totalEarned;
  final int totalSpent;

  factory UserCreditModel.fromJson(Map<String, dynamic> json) {
    return UserCreditModel(
      balance: int.tryParse(_read(json, 'balance')?.toString() ?? '') ?? 0,
      totalEarned:
          int.tryParse(_read(json, 'totalEarned')?.toString() ?? '') ?? 0,
      totalSpent:
          int.tryParse(_read(json, 'totalSpent')?.toString() ?? '') ?? 0,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
