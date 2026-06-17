import 'package:flutter/material.dart';

import 'booking_theme.dart';

class BookingTimeSelector extends StatelessWidget {
  const BookingTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onSelected,
  });

  final String selectedTime;
  final ValueChanged<String> onSelected;

  static const List<String> options = ['Hôm nay', 'Ngày mai', 'Cuối tuần'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn thời gian',
          style: TextStyle(
            color: BookingTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: options
              .map(
                (option) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option == options.last ? 0 : 10,
                    ),
                    child: ChoiceChip(
                      label: Center(child: Text(option)),
                      selected: selectedTime == option,
                      showCheckmark: false,
                      onSelected: (_) => onSelected(option),
                      backgroundColor: BookingTheme.card,
                      selectedColor: BookingTheme.primary,
                      side: BorderSide(
                        color: selectedTime == option
                            ? BookingTheme.primary
                            : BookingTheme.border,
                      ),
                      labelStyle: TextStyle(
                        color: selectedTime == option
                            ? BookingTheme.text
                            : BookingTheme.secondaryText,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
