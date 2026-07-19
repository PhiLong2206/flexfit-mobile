class Profile {
  const Profile({
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

  Profile copyWith({
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
    return Profile(
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
}
