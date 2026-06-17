import 'package:flutter/material.dart';
import 'models/user_profile.dart';

class ProfileNotifier extends ChangeNotifier {
  UserProfile _profile = UserProfile(
    firstName: 'DragonPi',
    lastName: 'DragonPi',
    email: 'longphinguyen2206@gmail.com',
    phone: '1224141',
    gender: 'Nam',
    birthDate: DateTime(2004, 6, 22),
    height: 1.8,
    weight: 130.0,
    fitnessGoal: 'Giảm cân',
    activityLevel: 'Hoạt động rất tích cực (VĐV)',
    preferredTimeSlot: 'Linh hoạt / Tự do',
    bio: '',
  );

  UserProfile get profile => _profile;

  void updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }

  void updateHealthGoal({
    required String gender,
    required DateTime? birthDate,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String activityLevel,
    required String preferredTimeSlot,
    required String bio,
  }) {
    _profile = _profile.copyWith(
      gender: gender,
      birthDate: birthDate,
      height: height,
      weight: weight,
      fitnessGoal: fitnessGoal,
      activityLevel: activityLevel,
      preferredTimeSlot: preferredTimeSlot,
      bio: bio,
    );
    notifyListeners();
  }
}
