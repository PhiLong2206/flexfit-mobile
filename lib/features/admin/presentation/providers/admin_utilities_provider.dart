import 'package:flutter/foundation.dart' hide Category;

import '../../../catalog/domain/entities/category.dart';
import '../../../membership/data/models/credit_package_model.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminUtilitiesProvider extends ChangeNotifier {
  AdminUtilitiesProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  AdminUtilityData? _data;
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;
  String _query = '';

  AdminUtilityData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;
  String get query => _query;

  List<Category> get filteredCategories {
    final categories = _data?.categories ?? const [];
    final text = _query.trim().toLowerCase();
    if (text.isEmpty) return categories;
    return categories
        .where(
          (category) =>
              category.name.toLowerCase().contains(text) ||
              (category.description ?? '').toLowerCase().contains(text),
        )
        .toList(growable: false);
  }

  List<CreditPackageModel> get filteredCreditPackages {
    final packages = _data?.creditPackages ?? const [];
    final text = _query.trim().toLowerCase();
    if (text.isEmpty) return packages;
    return packages
        .where(
          (package) =>
              package.name.toLowerCase().contains(text) ||
              (package.description ?? '').toLowerCase().contains(text),
        )
        .toList(growable: false);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _repository.getUtilityData();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  Future<void> createCategory({
    required String categoryName,
    String? description,
  }) {
    return _mutate(
      () => _repository.createCategory(
        categoryName: categoryName,
        description: description,
      ),
    );
  }

  Future<void> updateCategory({
    required String categoryId,
    required String categoryName,
    String? description,
  }) {
    return _mutate(
      () => _repository.updateCategory(
        categoryId: categoryId,
        categoryName: categoryName,
        description: description,
      ),
    );
  }

  Future<void> deleteCategory(String categoryId) {
    return _mutate(() => _repository.deleteCategory(categoryId));
  }

  Future<void> createCreditPackage({
    required String packageName,
    required int creditAmount,
    required double price,
    String? description,
  }) {
    return _mutate(
      () => _repository.createCreditPackage(
        packageName: packageName,
        creditAmount: creditAmount,
        price: price,
        description: description,
      ),
    );
  }

  Future<void> updateCreditPackage({
    required String packageId,
    String? packageName,
    int? creditAmount,
    double? price,
    String? description,
  }) {
    return _mutate(
      () => _repository.updateCreditPackage(
        packageId: packageId,
        packageName: packageName,
        creditAmount: creditAmount,
        price: price,
        description: description,
      ),
    );
  }

  Future<void> deleteCreditPackage(String packageId) {
    return _mutate(() => _repository.deleteCreditPackage(packageId));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    if (_isMutating) return;
    _isMutating = true;
    notifyListeners();
    try {
      await action();
      await load(force: true);
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
