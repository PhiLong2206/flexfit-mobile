import '../../../../core/services/api_client.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/fitness_class.dart';
import '../../domain/entities/gym.dart';
import '../models/branch_model.dart';
import '../models/category_model.dart';
import '../models/fitness_class_model.dart';
import '../models/gym_model.dart';

class CatalogRepository {
  CatalogRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Gym>> getGyms() async {
    final response = await _apiClient.get('/gyms');
    return _readList(response)
        .map(
          (item) => GymModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<Gym> getGymById(String id) async {
    final response = await _apiClient.get('/gyms/$id');
    return GymModel.fromJson(_readMap(response));
  }

  Future<List<Branch>> getBranches() async {
    final response = await _apiClient.get('/branches');
    return _readList(response)
        .map(
          (item) =>
              BranchModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .where((branch) => branch.id.trim().isNotEmpty)
        .toList();
  }

  Future<List<Branch>> getBranchesByGymId(String gymId) async {
    final branches = await getBranches();
    return branches
        .where((branch) => branch.gymId.toLowerCase() == gymId.toLowerCase())
        .toList();
  }

  Branch? resolveBranchForGym(Gym gym, List<Branch> branches) {
    final activeBranches = branches.where((branch) => branch.isActive).toList();
    final source = activeBranches.isEmpty ? branches : activeBranches;

    Branch? matchBy(bool Function(Branch branch) test) {
      for (final branch in source) {
        if (test(branch)) {
          return branch;
        }
      }
      return null;
    }

    final gymBranchId = _normalize(gym.branchId);
    if (gymBranchId != null) {
      final branch = matchBy((branch) => _sameId(branch.id, gymBranchId));
      if (branch != null) {
        return branch;
      }
      return Branch(
        id: gym.branchId!,
        gymId: gym.id,
        name: gym.branchName ?? gym.name,
        address: gym.branchAddress ?? gym.description,
        creditCost: 0,
        isActive: true,
      );
    }

    final gymBranchName = _normalize(gym.branchName);
    if (gymBranchName != null) {
      final branch = matchBy(
        (branch) => _normalize(branch.name) == gymBranchName,
      );
      if (branch != null) {
        return branch;
      }
    }

    final gymBranchAddress = _normalize(gym.branchAddress);
    if (gymBranchAddress != null) {
      final branch = matchBy((branch) {
        return _normalize(branch.address) == gymBranchAddress ||
            _normalize(branch.displayAddress) == gymBranchAddress;
      });
      if (branch != null) {
        return branch;
      }
    }

    final gymId = _normalize(gym.id);
    if (gymId != null) {
      final branch = matchBy((branch) => _sameId(branch.gymId, gymId));
      if (branch != null) {
        return branch;
      }
    }

    return null;
  }

  Future<List<FitnessClass>> getClasses() async {
    final response = await _apiClient.get('/classes');
    return _readList(response)
        .map(
          (item) => FitnessClassModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories');
    return _readList(response)
        .map(
          (item) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  List<dynamic> _readList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      final data = response['data'] ?? response['Data'] ?? response['items'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }

  Map<String, dynamic> _readMap(dynamic response) {
    final map = Map<String, dynamic>.from(response as Map);
    final data = map['data'] ?? map['Data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return map;
  }
}

bool _sameId(String? a, String? b) {
  final normalizedA = _normalize(a);
  final normalizedB = _normalize(b);
  return normalizedA != null &&
      normalizedB != null &&
      normalizedA == normalizedB;
}

String? _normalize(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty || normalized == 'null') {
    return null;
  }
  return normalized;
}
