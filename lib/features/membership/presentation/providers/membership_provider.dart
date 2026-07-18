import 'package:flutter/foundation.dart';
import '../../data/models/credit_package_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';

class MembershipProvider extends ChangeNotifier {
  MembershipProvider({
    CreditRepository? creditRepository,
    PaymentRepository? paymentRepository,
  }) : _creditRepository = creditRepository ?? CreditRepository(),
       _paymentRepository = paymentRepository ?? PaymentRepository();

  final CreditRepository _creditRepository;
  final PaymentRepository _paymentRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<CreditPackageModel> _packages = [];
  List<CreditPackageModel> get packages => _packages;

  UserCreditModel? _currentCredit;
  UserCreditModel? get currentCredit => _currentCredit;

  Future<void> loadPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _creditRepository.getMyCredit(),
        _creditRepository.getPackages(),
      ]);

      _currentCredit = futures[0] as UserCreditModel;
      _packages = futures[1] as List<CreditPackageModel>;
    } catch (e) {
      _error = 'Không thể tải danh sách gói. Vui lòng thử lại sau.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentCreateResult?> createPayment(String packageId) async {
    try {
      return _paymentRepository.createPayment(packageId: packageId);
    } catch (e) {
      return null;
    }
  }
}
