import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://localhost:5023/api';

  // Android emulator fallback when localhost points at the device itself.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5023/api';

  // Colors
  static const Color primaryColor = Color(0xFFFF6B16);

  static const Color backgroundColor = Color(0xFF070B14);

  static const Color surfaceColor = Color(0xFF111827);

  static const Color cardColor = Color(0xFF1B263B);

  static const Color borderColor = Color(0xFF2A3647);

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Color(0xFF9CA3AF);

  // Radius
  static const double borderRadius = 18;

  // Padding
  static const double defaultPadding = 20;
}

class AppColors {
  AppColors._();

  static const Color primary = AppConstants.primaryColor;
  static const Color background = AppConstants.backgroundColor;
  static const Color surface = AppConstants.surfaceColor;
  static const Color card = AppConstants.cardColor;
  static const Color border = AppConstants.borderColor;
  static const Color textPrimary = AppConstants.textPrimary;
  static const Color textSecondary = AppConstants.textSecondary;

  static const Color upcoming = AppConstants.primaryColor;
  static const Color completed = Color(0xFF22C55E);
  static const Color cancelled = Color(0xFFEF4444);
}
