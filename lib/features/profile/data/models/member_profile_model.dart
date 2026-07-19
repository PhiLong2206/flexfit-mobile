import '../../domain/entities/profile.dart';

class MemberProfileModel {
  const MemberProfileModel({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.avatarUrl,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.activityLevel,
    this.preferredWorkoutTime,
    this.bio,
    this.targetWeight,
    this.workoutSessionsPerWeek,
  });

  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? avatarUrl;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessGoal;
  final String? activityLevel;
  final String? preferredWorkoutTime;
  final String? bio;
  final double? targetWeight;
  final int? workoutSessionsPerWeek;

  factory MemberProfileModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileModel(
      fullName: _read(json, 'fullName')?.toString() ?? '',
      email: _read(json, 'email')?.toString() ?? '',
      phoneNumber: _read(json, 'phoneNumber')?.toString(),
      dateOfBirth: _read(json, 'dateOfBirth')?.toString(),
      gender: _read(json, 'gender')?.toString(),
      avatarUrl: (_read(json, 'avatarUrl') ??
              _read(json, 'avatar') ??
              _read(json, 'avatarPath') ??
              _read(json, 'profilePicture'))
          ?.toString(),
      heightCm: double.tryParse(_read(json, 'heightCm')?.toString() ?? ''),
      weightKg: double.tryParse(_read(json, 'weightKg')?.toString() ?? ''),
      fitnessGoal: _read(json, 'fitnessGoal')?.toString(),
      activityLevel: _read(json, 'activityLevel')?.toString(),
      preferredWorkoutTime: _read(json, 'preferredWorkoutTime')?.toString(),
      bio: _read(json, 'bio')?.toString(),
      targetWeight: double.tryParse(_read(json, 'targetWeight')?.toString() ?? ''),
      workoutSessionsPerWeek: int.tryParse(_read(json, 'workoutSessionsPerWeek')?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    final data = <String, dynamic>{
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber?.trim(),
      'dateOfBirth': dateOfBirth?.trim(),
      'gender': gender?.trim(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'fitnessGoal': fitnessGoal?.trim(),
      'activityLevel': activityLevel?.trim(),
      'preferredWorkoutTime': preferredWorkoutTime?.trim(),
      'bio': bio?.trim(),
      'avatarUrl': avatarUrl?.trim(),
      'targetWeight': targetWeight,
      'workoutSessionsPerWeek': workoutSessionsPerWeek,
    };

    data.removeWhere((_, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      return false;
    });

    return data;
  }

  MemberProfileModel copyWith({
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
  }) {
    return MemberProfileModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      bio: bio ?? this.bio,
      targetWeight: targetWeight ?? this.targetWeight,
      workoutSessionsPerWeek: workoutSessionsPerWeek ?? this.workoutSessionsPerWeek,
    );
  }

  Profile toEntity() {
    return Profile(
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
  }

  factory MemberProfileModel.fromEntity(Profile profile) {
    return MemberProfileModel(
      fullName: profile.fullName,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      avatarUrl: profile.avatarUrl,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      fitnessGoal: profile.fitnessGoal,
      activityLevel: profile.activityLevel,
      preferredWorkoutTime: profile.preferredWorkoutTime,
      bio: profile.bio,
      targetWeight: profile.targetWeight,
      workoutSessionsPerWeek: profile.workoutSessionsPerWeek,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
