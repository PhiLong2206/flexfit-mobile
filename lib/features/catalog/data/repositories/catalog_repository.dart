import '../../../../core/services/api_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/fitness_class.dart';
import '../../domain/entities/gym.dart';
import '../models/category_model.dart';
import '../models/fitness_class_model.dart';
import '../models/gym_model.dart';

class CatalogRepository {
  CatalogRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Gym>> getGyms() async {
    final response = await _apiClient.get('/gyms');
    return (response as List)
        .map(
          (item) => GymModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<Gym> getGymById(String id) async {
    final response = await _apiClient.get('/gyms/$id');
    return GymModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<List<FitnessClass>> getClasses() async {
    final response = await _apiClient.get('/classes');
    return (response as List)
        .map(
          (item) => FitnessClassModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories');
    return (response as List)
        .map(
          (item) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
