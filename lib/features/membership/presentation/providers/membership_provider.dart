import 'package:flutter/material.dart';

import '../../data/models/credit_package_model.dart';
import '../../data/repositories/credit_repository.dart';

class MembershipProvider extends ChangeNotifier {
  MembershipProvider(this._repository);

  final CreditRepository _repository;

  bool isLoading = false;
  bool isBuying = false;
  String? buyingPackageId;
  String? error;

  List<CreditPackageModel> packages = [];
  UserCreditModel? credit;

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      credit = await _repository.getMyCredit();
      packages = await _repository.getPackages();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> buyPackage(String packageId) async {
    isBuying = true;
    buyingPackageId = packageId;
    error = null;
    notifyListeners();

    try {
      await _repository.buyPackage(packageId);
      credit = await _repository.getMyCredit();

      isBuying = false;
      buyingPackageId = null;
      notifyListeners();

      return true;
    } catch (e) {
      error = e.toString();

      isBuying = false;
      buyingPackageId = null;
      notifyListeners();

      return false;
    }
  }
}