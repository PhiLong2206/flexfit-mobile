import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_storage.dart';
import '../models/member_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<MemberProfileModel> getProfile();
  Future<MemberProfileModel> updateProfile(MemberProfileModel profile);
  Future<MemberProfileModel> uploadAvatar(File imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<MemberProfileModel> getProfile() async {
    final response = await _apiClient.get('/profiles/me');
    final extracted = _extractProfileData(response) ?? Map<String, dynamic>.from(response as Map);
    
    // Gọi thêm API /users/{id} để lấy avatarUrl
    try {
      final userId = await LocalStorage.getUserIdFromToken();
      if (userId != null && userId.isNotEmpty) {
        final userResponse = await _apiClient.get('/users/$userId');
        if (userResponse is Map) {
          final userData = userResponse['data'] ?? userResponse['Data'] ?? userResponse;
          if (userData is Map) {
            final avatarUrl = userData['avatarUrl'] ?? userData['AvatarUrl'] ?? userData['avatar'] ?? userData['Avatar'];
            if (avatarUrl != null) {
              extracted['avatarUrl'] = avatarUrl.toString();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching avatarUrl from /users/{id}: $e');
    }

    return MemberProfileModel.fromJson(extracted);
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

  @override
  Future<MemberProfileModel> uploadAvatar(File imageFile) async {
    final response = await _apiClient.multipartRequest(
      'PUT',
      '/profiles/me',
      fields: {},
      files: [
        {'name': 'avatar', 'file': imageFile},
      ],
    );
    final profileData = _extractProfileData(response);
    if (profileData != null) {
      return MemberProfileModel.fromJson(profileData);
    }
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
