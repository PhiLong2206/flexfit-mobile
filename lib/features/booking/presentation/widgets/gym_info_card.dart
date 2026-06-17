import 'package:flutter/material.dart';

import 'booking_theme.dart';

class GymInfoCard extends StatelessWidget {
  const GymInfoCard({
    super.key,
    required this.name,
    required this.address,
    required this.rating,
    required this.creditCost,
    required this.openingHours,
    required this.duration,
    required this.description,
    required this.amenities,
  });

  final String name;
  final String address;
  final double rating;
  final int creditCost;
  final String openingHours;
  final String duration;
  final String description;
  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BookingTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BookingTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: BookingTheme.text,
              fontSize: 26,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _IconLine(icon: Icons.location_on_outlined, text: address),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                icon: Icons.star_rounded,
                label: rating.toStringAsFixed(1),
                color: const Color(0xFFFFC857),
              ),
              _MetricChip(
                icon: Icons.local_fire_department_outlined,
                label: '$creditCost Credit',
                color: BookingTheme.primary,
              ),
              _MetricChip(
                icon: Icons.schedule_outlined,
                label: openingHours,
                color: BookingTheme.secondaryText,
              ),
              _MetricChip(
                icon: Icons.timer_outlined,
                label: duration,
                color: BookingTheme.secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Mô tả',
            style: TextStyle(
              color: BookingTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: BookingTheme.secondaryText,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Tiện ích',
            style: TextStyle(
              color: BookingTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities
                .map(
                  (amenity) => Chip(
                    label: Text(amenity),
                    backgroundColor: BookingTheme.background,
                    side: const BorderSide(color: BookingTheme.border),
                    labelStyle: const TextStyle(
                      color: BookingTheme.text,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BookingTheme.secondaryText, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: BookingTheme.secondaryText,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BookingTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BookingTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: BookingTheme.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
