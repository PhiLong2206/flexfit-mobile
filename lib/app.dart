import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/profile/data/profile_notifier.dart';
import 'features/profile/data/booking_notifier.dart';
import 'features/notification/data/notification_notifier.dart';
import 'features/workout/data/workout_notifier.dart';
import 'features/review/data/review_notifier.dart';

class FlexFitApp extends StatelessWidget {
  const FlexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileNotifier()),
        ChangeNotifierProvider(create: (_) => BookingNotifier()),
        ChangeNotifierProvider(create: (_) => NotificationNotifier()),
        ChangeNotifierProvider(create: (_) => WorkoutNotifier()),
        ChangeNotifierProvider(create: (_) => ReviewNotifier()),
      ],
      child: MaterialApp(
        title: 'FlexFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.primaryColor,
            surface: AppConstants.surfaceColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.backgroundColor,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
