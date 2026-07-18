import 'dart:io';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/member_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this.remoteDataSource);

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Profile> getProfile() async {
    final model = await remoteDataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final modelToUpdate = MemberProfileModel.fromEntity(profile);
    final updatedModel = await remoteDataSource.updateProfile(modelToUpdate);
    return updatedModel.toEntity();
  }

  @override
  Future<Profile> uploadAvatar(File imageFile) async {
    final model = await remoteDataSource.uploadAvatar(imageFile);
    return model.toEntity();
  }
}
