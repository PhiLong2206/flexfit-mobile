import 'package:flutter/material.dart';
import 'models/user_profile.dart';
import 'models/member_profile_model.dart';
import 'repositories/profile_repository.dart';

class ProfileNotifier extends ChangeNotifier {
  final _repository = ProfileRepository();
  
  UserProfile _profile = UserProfile(
    firstName: 'DragonPi',
    lastName: 'DragonPi',
    email: 'longphinguyen2206@gmail.com',
    phone: '1224141',
    gender: 'Nam',
    birthDate: DateTime(2004, 6, 22),
    height: 180.0,
    weight: 130.0,
    fitnessGoal: 'Giảm cân',
    activityLevel: 'Hoạt động rất tích cực (VĐV)',
    preferredTimeSlot: 'Linh hoạt / Tự do',
    bio: '',
  );

  bool _isLoading = false;
  String? _error;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final memberProfile = await _repository.getMe();
      _profile = _mapFromMemberProfile(memberProfile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    final updated = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    await _saveProfile(updated);
  }

  Future<void> updateHealthGoal({
    required String gender,
    required DateTime? birthDate,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String activityLevel,
    required String preferredTimeSlot,
    required String bio,
    double? targetWeight,
    int? workoutSessionsPerWeek,
  }) async {
    final updated = _profile.copyWith(
      gender: gender,
      birthDate: birthDate,
      height: height,
      weight: weight,
      fitnessGoal: fitnessGoal,
      activityLevel: activityLevel,
      preferredTimeSlot: preferredTimeSlot,
      bio: bio,
      targetWeight: targetWeight,
      workoutSessionsPerWeek: workoutSessionsPerWeek,
    );
    await _saveProfile(updated);
  }

  Future<void> _saveProfile(UserProfile updated) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dobString = updated.birthDate?.toIso8601String().split('T').first;
      final model = MemberProfileModel(
        fullName: '${updated.firstName} ${updated.lastName}'.trim(),
        email: updated.email,
        phoneNumber: updated.phone,
        dateOfBirth: dobString,
        gender: updated.gender,
        heightCm: updated.height,
        weightKg: updated.weight,
        fitnessGoal: updated.fitnessGoal,
        activityLevel: updated.activityLevel,
        preferredWorkoutTime: updated.preferredTimeSlot,
        bio: updated.bio,
        avatarUrl: updated.avatarUrl,
        targetWeight: updated.targetWeight,
        workoutSessionsPerWeek: updated.workoutSessionsPerWeek,
      );
      final savedModel = await _repository.updateMe(model);
      _profile = _mapFromMemberProfile(savedModel);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to map MemberProfileModel (API) to UserProfile (UI)
  UserProfile _mapFromMemberProfile(MemberProfileModel model) {
    String firstName = '';
    String lastName = '';
    final nameParts = model.fullName.trim().split(' ');
    if (nameParts.length > 1) {
      firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');
      lastName = nameParts.last;
    } else {
      firstName = model.fullName;
    }

    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      email: model.email,
      phone: model.phoneNumber ?? '',
      gender: model.gender ?? 'Nam',
      birthDate: model.dateOfBirth != null ? DateTime.tryParse(model.dateOfBirth!) : null,
      height: model.heightCm ?? 170.0,
      weight: model.weightKg ?? 60.0,
      fitnessGoal: model.fitnessGoal ?? 'Giảm cân',
      activityLevel: model.activityLevel ?? 'Hoạt động nhẹ',
      preferredTimeSlot: model.preferredWorkoutTime ?? 'Linh hoạt / Tự do',
      bio: model.bio ?? '',
      avatarUrl: model.avatarUrl,
      targetWeight: model.targetWeight ?? model.weightKg ?? 60.0,
      workoutSessionsPerWeek: model.workoutSessionsPerWeek ?? 3,
    );
  }
}
