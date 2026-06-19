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

  factory MemberProfileModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileModel(
      fullName: _read(json, 'fullName')?.toString() ?? '',
      email: _read(json, 'email')?.toString() ?? '',
      phoneNumber: _read(json, 'phoneNumber')?.toString(),
      dateOfBirth: _read(json, 'dateOfBirth')?.toString(),
      gender: _read(json, 'gender')?.toString(),
      avatarUrl: _read(json, 'avatarUrl')?.toString(),
      heightCm: double.tryParse(_read(json, 'heightCm')?.toString() ?? ''),
      weightKg: double.tryParse(_read(json, 'weightKg')?.toString() ?? ''),
      fitnessGoal: _read(json, 'fitnessGoal')?.toString(),
      activityLevel: _read(json, 'activityLevel')?.toString(),
      preferredWorkoutTime: _read(json, 'preferredWorkoutTime')?.toString(),
      bio: _read(json, 'bio')?.toString(),
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
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
