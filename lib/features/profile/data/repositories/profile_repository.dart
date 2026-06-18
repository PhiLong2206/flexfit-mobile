import '../../../../core/services/api_client.dart';
import '../models/member_profile_model.dart';

class ProfileRepository {
  ProfileRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MemberProfileModel> getMe() async {
    final response = await _apiClient.get('/profiles/me');
    return MemberProfileModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<MemberProfileModel> updateMe(MemberProfileModel profile) async {
    final response = await _apiClient.put(
      '/profiles/me',
      body: profile.toUpdateJson(),
    );
    final data = Map<String, dynamic>.from(response as Map);
    final profileData = data['data'] ?? data['Data'];
    return MemberProfileModel.fromJson(
      Map<String, dynamic>.from(profileData as Map),
    );
  }
}
