import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/notification/presentation/providers/notification_provider.dart';

class FlexFitApp extends StatelessWidget {
  const FlexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('FlexFitApp build');

    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
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
