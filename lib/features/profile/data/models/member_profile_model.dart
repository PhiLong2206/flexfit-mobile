class MemberProfileModel {
  const MemberProfileModel({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.activityLevel,
    this.preferredWorkoutTime,
    this.bio,
    this.avatarUrl,
    this.targetWeight,
    this.workoutSessionsPerWeek,
  });

  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessGoal;
  final String? activityLevel;
  final String? preferredWorkoutTime;
  final String? bio;
  final String? avatarUrl;
  final double? targetWeight;
  final int? workoutSessionsPerWeek;

  factory MemberProfileModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileModel(
      fullName: _read(json, 'fullName')?.toString() ?? '',
      email: _read(json, 'email')?.toString() ?? '',
      phoneNumber: _read(json, 'phoneNumber')?.toString(),
      dateOfBirth: _read(json, 'dateOfBirth')?.toString(),
      gender: _read(json, 'gender')?.toString(),
      heightCm: double.tryParse(_read(json, 'heightCm')?.toString() ?? ''),
      weightKg: double.tryParse(_read(json, 'weightKg')?.toString() ?? ''),
      fitnessGoal: _read(json, 'fitnessGoal')?.toString(),
      activityLevel: _read(json, 'activityLevel')?.toString(),
      preferredWorkoutTime: _read(json, 'preferredWorkoutTime')?.toString(),
      bio: _read(json, 'bio')?.toString(),
      avatarUrl: _read(json, 'avatarUrl')?.toString() ?? _read(json, 'avatar')?.toString(),
      targetWeight: double.tryParse(_read(json, 'targetWeight')?.toString() ?? ''),
      workoutSessionsPerWeek: int.tryParse(_read(json, 'workoutSessionsPerWeek')?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'preferredWorkoutTime': preferredWorkoutTime,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'targetWeight': targetWeight,
      'workoutSessionsPerWeek': workoutSessionsPerWeek,
    };
  }

  MemberProfileModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? preferredWorkoutTime,
    String? bio,
    String? avatarUrl,
    double? targetWeight,
    int? workoutSessionsPerWeek,
  }) {
    return MemberProfileModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetWeight: targetWeight ?? this.targetWeight,
      workoutSessionsPerWeek: workoutSessionsPerWeek ?? this.workoutSessionsPerWeek,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
