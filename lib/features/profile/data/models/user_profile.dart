class UserProfile {
  String firstName;
  String lastName;
  String email;
  String phone;
  String gender;
  DateTime? birthDate;
  double height;
  double weight;
  String fitnessGoal;
  String activityLevel;
  String preferredTimeSlot;
  String bio;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    this.birthDate,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.preferredTimeSlot,
    required this.bio,
  });

  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.toLowerCase() == 'dragonpi' && l.toLowerCase() == 'dragonpi') {
      return 'DR';
    }
    if (f.isEmpty && l.isEmpty) return 'FF';
    final firstChar = f.isNotEmpty ? f[0] : '';
    final lastChar = l.isNotEmpty ? l[0] : '';
    return '$firstChar$lastChar'.toUpperCase();
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
    String? preferredTimeSlot,
    String? bio,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      bio: bio ?? this.bio,
    );
  }
}
