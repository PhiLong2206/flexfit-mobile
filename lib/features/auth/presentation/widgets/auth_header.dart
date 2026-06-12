import 'package:flutter/material.dart';

import 'auth_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final bool showLogo;

  static const String heroUrl =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[const _FlexFitLogo(), const SizedBox(height: 24)],
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  heroUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AuthTheme.card,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.fitness_center,
                      color: AuthTheme.primary,
                      size: 44,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(15),
                        AuthTheme.background.withAlpha(235),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          style: const TextStyle(
            color: AuthTheme.text,
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: AuthTheme.secondaryText,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FlexFitLogo extends StatelessWidget {
  const _FlexFitLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AuthTheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'FF',
            style: TextStyle(
              color: AuthTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'FLEXFIT',
          style: TextStyle(
            color: AuthTheme.text,
            fontSize: 20,
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
