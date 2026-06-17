import 'package:flutter/material.dart';

import 'auth_theme.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: AuthTheme.text,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: AuthTheme.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AuthTheme.secondaryText),
        prefixIcon: Icon(icon, color: AuthTheme.secondaryText),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AuthTheme.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AuthTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AuthTheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
