import 'package:flutter/foundation.dart';

import '../../../catalog/domain/entities/gym.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminGymsProvider extends ChangeNotifier {
  AdminGymsProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  List<Gym> _gyms = const [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;
  String _query = '';
  String _statusFilter = 'Tất cả';

  List<Gym> get gyms => _gyms;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  String get statusFilter => _statusFilter;

  List<String> get statuses {
    final values =
        _gyms
            .map((gym) => gym.status.trim())
            .where((status) => status.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Tất cả', ...values];
  }

  List<Gym> get filteredGyms {
    final text = _query.trim().toLowerCase();
    return _gyms
        .where((gym) {
          final matchesStatus =
              _statusFilter == 'Tất cả' ||
              gym.status.toLowerCase() == _statusFilter.toLowerCase();
          final matchesQuery =
              text.isEmpty ||
              gym.name.toLowerCase().contains(text) ||
              (gym.email ?? '').toLowerCase().contains(text) ||
              (gym.phoneNumber ?? '').toLowerCase().contains(text);
          return matchesStatus && matchesQuery;
        })
        .toList(growable: false);
  }

  List<Gym> get pendingGyms => _gyms
      .where((gym) => gym.status.trim().toLowerCase() == 'pending')
      .toList(growable: false);

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gyms = await _repository.getGyms();
      if (!statuses.contains(_statusFilter)) {
        _statusFilter = 'Tất cả';
      }
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

  void setStatusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    notifyListeners();
  }

  Future<void> createGym({
    required String ownerId,
    required String gymName,
    String? description,
    String? thumbnailUrl,
    String? phoneNumber,
    String? email,
  }) {
    return _mutate(
      () => _repository.createGym(
        ownerId: ownerId,
        gymName: gymName,
        description: description,
        thumbnailUrl: thumbnailUrl,
        phoneNumber: phoneNumber,
        email: email,
      ),
    );
  }

  Future<void> changeGymStatus({
    required String gymId,
    required String status,
  }) {
    return _mutate(
      () => _repository.changeGymStatus(gymId: gymId, status: status),
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
