import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  static const Color _primaryOrange = Color(0xFFFF6B16);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _PillButton(
          label: 'Bắt đầu ngay',
          icon: Icons.arrow_forward_rounded,
          foregroundColor: Colors.white,
          backgroundColor: _primaryOrange,
          onPressed: () {},
        ),
        _PillButton(
          label: 'Khám phá',
          icon: Icons.explore_rounded,
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          borderColor: Colors.white.withValues(alpha: 0.18),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        minimumSize: const Size(0, 38),
        shape: StadiumBorder(
          side: BorderSide(color: borderColor ?? Colors.transparent),
        ),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
