import 'dart:io';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<Profile> updateProfile(Profile profile);
  Future<Profile> uploadAvatar(File imageFile);
}
