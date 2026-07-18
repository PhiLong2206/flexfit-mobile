import 'package:flutter/material.dart';

class AdminColors {
  const AdminColors._();

  static const background = Color(0xFF070B14);
  static const sidebar = Color(0xFF0B1220);
  static const panel = Color(0xFF111827);
  static const panelAlt = Color(0xFF0F172A);
  static const border = Color(0xFF263244);
  static const muted = Color(0xFF94A3B8);
  static const subtle = Color(0xFF64748B);
  static const primary = Color(0xFF22C55E);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF38BDF8);
  static const danger = Color(0xFFEF4444);
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: const TextStyle(color: AdminColors.muted, height: 1.35),
            ),
          ],
        );
        if (trailing == null) return heading;
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 14), trailing!],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            trailing!,
          ],
        );
      },
    );
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

class AdminMetricCard extends StatelessWidget {
  const AdminMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AdminColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle(this.title, this.icon, {super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AdminColors.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 18, color: AdminColors.primary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class AdminStatusPill extends StatelessWidget {
  const AdminStatusPill({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? statusColor(label);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label.isEmpty ? 'Khong ro' : label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: tone,
          ),
        ),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AdminColors.panelAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, size: 38, color: AdminColors.primary),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.muted, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminErrorState extends StatelessWidget {
  const AdminErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AdminPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: AdminColors.danger,
              ),
              const SizedBox(height: 12),
              const Text(
                'Khong the tai du lieu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.muted, height: 1.35),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: hintText,
        filled: true,
        fillColor: AdminColors.panelAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class AdminLoadingState extends StatelessWidget {
  const AdminLoadingState({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      children: [
        const _Skeleton(widthFactor: 0.52, height: 30),
        const SizedBox(height: 10),
        const _Skeleton(widthFactor: 0.78, height: 14),
        const SizedBox(height: 24),
        for (var i = 0; i < rows; i++) ...[
          AdminPanel(
            child: Row(
              children: const [
                _SkeletonBox(size: 46),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Skeleton(widthFactor: 0.72, height: 16),
                      SizedBox(height: 10),
                      _Skeleton(widthFactor: 0.48, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class AdminInlineLoadingState extends StatelessWidget {
  const AdminInlineLoadingState({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++) ...[
          Row(
            children: const [
              _SkeletonBox(size: 40),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Skeleton(widthFactor: 0.72, height: 14),
                    SizedBox(height: 8),
                    _Skeleton(widthFactor: 0.46, height: 11),
                  ],
                ),
              ),
            ],
          ),
          if (i != rows - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class AdminBarRow extends StatelessWidget {
  const AdminBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.trailing,
  });

  final String label;
  final double value;
  final double maxValue;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final factor = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                trailing ?? formatMoney(value),
                style: const TextStyle(color: AdminColors.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 9,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation(AdminColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AdminColors.border.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(999),
        ),
        child: SizedBox(height: height),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.border.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}

Color statusColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'active' ||
      normalized == 'approved' ||
      normalized == 'success' ||
      normalized == 'paid' ||
      normalized == 'completed') {
    return AdminColors.success;
  }
  if (normalized == 'pending') return AdminColors.warning;
  if (normalized == 'rejected' ||
      normalized == 'inactive' ||
      normalized == 'failed' ||
      normalized == 'locked') {
    return AdminColors.danger;
  }
  return AdminColors.info;
}

String formatMoney(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final indexFromEnd = rounded.length - i;
    buffer.write(rounded[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${buffer.toString()} d';
}

String formatDateTime(DateTime? value) {
  if (value == null) return 'Chua co du lieu';
  final date =
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  final time =
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  return '$time $date';
}
