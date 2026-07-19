import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _getProfileUseCase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? avatarUrl,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? preferredWorkoutTime,
    String? bio,
    double? targetWeight,
    int? workoutSessionsPerWeek,
  }) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        avatarUrl: avatarUrl,
        heightCm: heightCm,
        weightKg: weightKg,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
        preferredWorkoutTime: preferredWorkoutTime,
        bio: bio,
        targetWeight: targetWeight,
        workoutSessionsPerWeek: workoutSessionsPerWeek,
      );

      _profile = await _updateProfileUseCase(updatedProfile);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(File imageFile) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _getProfileUseCase.repository.uploadAvatar(imageFile);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
