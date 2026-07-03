import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/member_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<MemberProfileModel> getProfile();
  Future<MemberProfileModel> updateProfile(MemberProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<MemberProfileModel> getProfile() async {
    final response = await _apiClient.get('/profiles/me');
    return MemberProfileModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  @override
  Future<MemberProfileModel> updateProfile(MemberProfileModel profile) async {
    final body = profile.toUpdateJson();

    debugPrint('UPDATE PROFILE BODY: $body');

    final response = await _apiClient.put('/profiles/me', body: body);
    debugPrint('UPDATE PROFILE RESPONSE: $response');

    final profileData = _extractProfileData(response);
    if (profileData != null) {
      return MemberProfileModel.fromJson(profileData);
    }

    debugPrint(
      'UPDATE PROFILE RESPONSE HAS NO PROFILE DATA; RELOADING /profiles/me',
    );
    return getProfile();
  }

  Map<String, dynamic>? _extractProfileData(dynamic response) {
    if (response is! Map) return null;

    final data = Map<String, dynamic>.from(response);
    final wrappedProfile = data['data'] ?? data['Data'];
    if (wrappedProfile is Map) {
      return Map<String, dynamic>.from(wrappedProfile);
    }

    final hasProfileShape =
        data.containsKey('fullName') ||
        data.containsKey('FullName') ||
        data.containsKey('email') ||
        data.containsKey('Email');
    if (hasProfileShape) {
      return data;
    }

    return null;
  }
}
