import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalog/domain/entities/branch.dart';
import '../providers/booking_provider.dart';
import 'booking_theme.dart';

Future<GymTimeSlotSelection?> showGymTimeSlotSheet({
  required BuildContext context,
  required String gymName,
  required Branch branch,
}) {
  return showModalBottomSheet<GymTimeSlotSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => BookingProvider()..initializeSlotPicker(branch),
      child: _GymTimeSlotSheet(gymName: gymName, branch: branch),
    ),
  );
}

class _GymTimeSlotSheet extends StatelessWidget {
  const _GymTimeSlotSheet({required this.gymName, required this.branch});

  final String gymName;
  final Branch branch;

  void _continue(BuildContext context, BookingProvider provider) {
    final selection = provider.selectedGymTimeSlot;
    if (selection == null) {
      return;
    }
    Navigator.of(context).pop(selection);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720, maxHeight: maxHeight),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: BookingTheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: BookingTheme.border)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BookingTheme.secondaryText.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Chọn giờ tập',
                        style: TextStyle(
                          color: BookingTheme.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Open Gym - $gymName · ${branch.name}',
                        style: const TextStyle(
                          color: BookingTheme.secondaryText,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _HoursPill(label: provider.hoursLabel),
                      const SizedBox(height: 18),
                      _DateChips(
                        dates: provider.slotDates,
                        selectedIndex: provider.selectedDateIndex,
                        onSelected: provider.selectSlotDate,
                      ),
                      const SizedBox(height: 18),
                      _SlotGrid(
                        slots: provider.slotsForSelectedDate(),
                        selectedStartTime: provider.selectedStartTime,
                        onSelected: (slot) {
                          provider.selectTimeSlot(slot.startTime);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BookingTheme.text,
                                side: const BorderSide(
                                  color: BookingTheme.border,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: provider.canContinueWithSlot
                                  ? () => _continue(context, provider)
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: BookingTheme.primary,
                                foregroundColor: BookingTheme.text,
                                disabledBackgroundColor: BookingTheme.border
                                    .withValues(alpha: 0.65),
                                disabledForegroundColor:
                                    BookingTheme.secondaryText,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Tiếp tục',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HoursPill extends StatelessWidget {
  const _HoursPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: BookingTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BookingTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: BookingTheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Giờ mở cửa: $label',
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

class _DateChips extends StatelessWidget {
  const _DateChips({
    required this.dates,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == selectedIndex;
          return ChoiceChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(index),
            backgroundColor: BookingTheme.card,
            selectedColor: BookingTheme.primary,
            side: BorderSide(
              color: isSelected ? BookingTheme.primary : BookingTheme.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            label: SizedBox(
              width: 86,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dateTitle(index, date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? BookingTheme.text
                          : BookingTheme.secondaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isSelected
                          ? BookingTheme.text.withValues(alpha: 0.9)
                          : BookingTheme.secondaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _dateTitle(int index, DateTime date) {
    if (index == 0) {
      return 'Hôm nay';
    }
    if (index == 1) {
      return 'Ngày mai';
    }
    return switch (date.weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      _ => 'CN',
    };
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedStartTime,
    required this.onSelected,
  });

  final List<BookingTimeSlot> slots;
  final DateTime? selectedStartTime;
  final ValueChanged<BookingTimeSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BookingTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BookingTheme.border),
        ),
        child: const Text(
          'Chưa có khung giờ phù hợp.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BookingTheme.secondaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 3;
        return GridView.builder(
          itemCount: slots.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.9,
          ),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = selectedStartTime == slot.startTime;
            return _SlotTile(
              slot: slot,
              isSelected: isSelected,
              onTap: slot.isPast ? null : () => onSelected(slot),
            );
          },
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final BookingTimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = slot.isPast ? BookingTheme.secondaryText : BookingTheme.text;
    final backgroundColor = isSelected
        ? BookingTheme.primary
        : slot.isPast
        ? BookingTheme.card.withValues(alpha: 0.56)
        : BookingTheme.card;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? BookingTheme.primary
                  : slot.isPast
                  ? BookingTheme.border.withValues(alpha: 0.55)
                  : BookingTheme.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (slot.isPast) ...[
                const SizedBox(height: 3),
                const Text(
                  'Đã qua',
                  style: TextStyle(
                    color: BookingTheme.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
