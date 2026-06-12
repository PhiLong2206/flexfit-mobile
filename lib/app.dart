import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/pages/login_page.dart';

class FlexFitApp extends StatelessWidget {
  const FlexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}