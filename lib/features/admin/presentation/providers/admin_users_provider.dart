import 'package:flutter/foundation.dart';

import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminUsersProvider extends ChangeNotifier {
  AdminUsersProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  List<AdminUser> _users = const [];
  List<Gym> _gyms = const [];
  List<Branch> _branches = const [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;
  String _query = '';

  List<AdminUser> get users => _users;
  List<Gym> get gyms => _gyms;
  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;
  String get query => _query;

  List<AdminUser> get filteredUsers {
    final text = _query.trim().toLowerCase();
    if (text.isEmpty) return _users;
    return _users
        .where((user) {
          return user.fullName.toLowerCase().contains(text) ||
              user.email.toLowerCase().contains(text) ||
              user.roles.join(' ').toLowerCase().contains(text);
        })
        .toList(growable: false);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final usersFuture = _repository.getUsers();
      final gymsFuture = _repository.getGyms();
      final branchesFuture = _repository.getBranches();
      _users = await usersFuture;
      _gyms = await gymsFuture;
      _branches = await branchesFuture;
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

  Future<void> updateUser({
    required String userId,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? dateOfBirth,
  }) {
    return _mutate(
      () => _repository.updateUser(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        dateOfBirth: dateOfBirth,
      ),
    );
  }

  Future<void> changeUserStatus({
    required String userId,
    required bool isActive,
  }) {
    return _mutate(
      () => _repository.changeUserStatus(userId: userId, isActive: isActive),
    );
  }

  Future<void> deleteUser(String userId) {
    return _mutate(() => _repository.deleteUser(userId));
  }

  Future<void> assignRole({
    required String userId,
    required String roleName,
    String? gymId,
    String? branchId,
  }) {
    return _mutate(
      () => _repository.assignRole(
        userId: userId,
        roleName: roleName,
        gymId: gymId,
        branchId: branchId,
      ),
    );
  }

  Future<void> revokeRole({required String userId, required String roleName}) {
    return _mutate(
      () => _repository.revokeRole(userId: userId, roleName: roleName),
    );
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
