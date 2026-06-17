import '../../../../core/services/local_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await LocalStorage.saveToken(session.token);
    return session;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> verifyEmail({required String email, required String otpCode}) {
    return _remoteDataSource.verifyEmail(email: email, otpCode: otpCode);
  }

  @override
  Future<void> resendOtp({required String email}) {
    return _remoteDataSource.resendOtp(email: email);
  }
}
