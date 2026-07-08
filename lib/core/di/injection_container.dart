import 'package:get_it/get_it.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/usecases/google_login_usecase.dart';
import '../../features/auth/domain/usecases/google_login_with_id_token_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/data/datasources/ai_remote_data_source.dart';
import '../../features/ai/domain/usecases/chat_with_ai_usecase.dart';
import '../../features/ai/domain/usecases/get_workout_suggestion_usecase.dart';
import '../../features/ai/domain/usecases/get_class_suggestion_usecase.dart';
import '../../features/booking/domain/usecases/get_my_bookings_usecase.dart';
import '../../features/booking/data/repositories/booking_repository.dart';

import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

import '../../features/partner/data/datasources/partner_remote_data_source.dart';
import '../../features/partner/data/repositories/partner_repository_impl.dart';
import '../../features/partner/domain/repositories/partner_repository.dart';
import '../../features/partner/domain/usecases/create_class_usecase.dart';
import '../../features/partner/domain/usecases/delete_class_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_branches_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_classes_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_dashboard_stats_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_gyms_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_customers_usecase.dart';
import '../../features/partner/domain/usecases/get_partner_reviews_usecase.dart';
import '../../features/partner/presentation/providers/partner_provider.dart';

import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Features - Auth
  sl.registerFactory(
    () => AuthProvider(googleLoginUseCase: sl(), changePasswordUseCase: sl()),
  );
  sl.registerLazySingleton(() => GoogleLoginWithIdTokenUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl()));

  // Features - AI
  sl.registerLazySingleton(() => ChatWithAiUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutSuggestionUseCase(sl()));
  sl.registerLazySingleton(() => GetClassSuggestionUseCase(sl()));
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AiRemoteDataSource(apiClient: sl()));

  // Features - Booking
  sl.registerLazySingleton(() => BookingRepository(apiClient: sl()));
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));

  // Features - Catalog

  // Features - Gym

  // Features - Home

  // Features - Membership

  // Features - Notification

  // Features - Profile
  sl.registerFactory(
    () => ProfileProvider(getProfileUseCase: sl(), updateProfileUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Partner
  sl.registerFactory(
    () => PartnerProvider(
      getPartnerDashboardStatsUseCase: sl(),
      getPartnerBranchesUseCase: sl(),
      getPartnerClassesUseCase: sl(),
      createClassUseCase: sl(),
      deleteClassUseCase: sl(),
      getPartnerGymsUseCase: sl(),
      getPartnerCustomersUseCase: sl(),
      getPartnerReviewsUseCase: sl(),
      partnerRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetPartnerDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetPartnerBranchesUseCase(sl()));
  sl.registerLazySingleton(() => GetPartnerClassesUseCase(sl()));
  sl.registerLazySingleton(() => CreateClassUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClassUseCase(sl()));
  sl.registerLazySingleton(() => GetPartnerGymsUseCase(sl()));
  sl.registerLazySingleton(() => GetPartnerCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetPartnerReviewsUseCase(sl()));
  sl.registerLazySingleton<PartnerRepository>(
    () => PartnerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PartnerRemoteDataSource>(
    () => PartnerRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Explore
}
