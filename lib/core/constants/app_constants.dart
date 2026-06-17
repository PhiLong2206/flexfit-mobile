import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://localhost:5173/api';

  // Android emulator fallback when localhost points at the device itself.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5173/api';

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

  static const Color background = Color(0xFF070B14);
  static const Color card = Color(0xFF111827);
  static const Color primary = Color(0xFFFF6B16);
  static const Color border = Color(0xFF243044);
  static const Color textSecondary = Color(0xFF9CA3AF);

  // Booking status colors
  static const Color upcoming = Color(0xFFFF6B16);
  static const Color completed = Color(0xFF10B981);
  static const Color cancelled = Color(0xFFEF4444);
}
