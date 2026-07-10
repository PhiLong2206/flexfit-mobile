import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_coach_provider.dart';

class SuggestedPromptChips extends StatelessWidget {
  const SuggestedPromptChips({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AiCoachProvider>().isLoading;
    final prompts = [
      'Hôm nay nên tập gì?',
      'Tìm lớp học phù hợp',
      'Phục hồi cơ bắp',
      'Nên tập phòng gym nào?',
      'Lịch tập tiếp theo của tôi',
      'Tôi bị đau lưng, nên tập gì?',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: prompts.map((prompt) {
        return ActionChip(
          label: Text(prompt, style: const TextStyle(fontSize: 12)),
          backgroundColor: const Color(0xFF1A1F2E),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: isLoading
              ? null
              : () {
                  context.read<AiCoachProvider>().sendMessage(prompt);
                },
        );
      }).toList(),
    );
  }
}
