import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_coach_provider.dart';
import 'chat_bubble.dart';
import 'chat_input_bar.dart';
import 'compact_ai_response_bubble.dart';
import 'suggested_prompt_chips.dart';

class AiCoachPopup extends StatefulWidget {
  const AiCoachPopup({super.key});

  static void show(BuildContext context) {
    // For mobile, use a BottomSheet that takes up 80% height.
    // For web/desktop, we could use a Dialog, but we'll use bottom sheet everywhere for consistency in this example
    // or we can use constraints.
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.bottomRight,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            height: 600,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const AiCoachPopup(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF070B14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.85,
          child: const AiCoachPopup(),
        ),
      );
    }
  }

  @override
  State<AiCoachPopup> createState() => _AiCoachPopupState();
}

class _AiCoachPopupState extends State<AiCoachPopup> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiCoachProvider>();
    final messages = provider.messages;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    final isBottomSheet = ModalRoute.of(context) is ModalBottomSheetRoute;

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20, isBottomSheet ? 12 : 20, 20, 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBottomSheet)
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, color: Color(0xFFFF6B16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'FlexFit AI Coach',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF22C55E,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF22C55E,
                                  ).withValues(alpha: 0.45),
                                ),
                              ),
                              child: const Text(
                                'PT',
                                style: TextStyle(
                                  color: Color(0xFF86EFAC),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'PT ảo của bạn trong FlexFit',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Error bar
        if (provider.error != null)
          Container(
            color: Colors.red.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: provider.clearError,
                ),
              ],
            ),
          ),
        // Chat list
        Expanded(
          child: messages.isEmpty
              ? const _AiCoachDashboard()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF6B16),
                          ),
                        ),
                      );
                    }

                    final message = messages[index];
                    final isUser = message.role == 'user';

                    if (isUser) {
                      return ChatBubble(text: message.content, isUser: true);
                    } else {
                      final parsedMsg = provider.getParsedMessage(index);
                      final recommendedClasses = provider.getRecommendedClasses(
                        index,
                      );
                      final recommendedGyms = provider.getRecommendedGyms(
                        index,
                      );
                      final recommendationNote = provider.getRecommendationNote(
                        index,
                      );
                      final responseTitle = provider.getResponseTitle(index);

                      if (parsedMsg != null) {
                        return CompactAiResponseBubble(
                          parsedResponse: parsedMsg,
                          rawText: message.content,
                          title: responseTitle,
                          recommendedClasses: recommendedClasses,
                          recommendedGyms: recommendedGyms,
                          recommendationNote: recommendationNote,
                        );
                      } else {
                        // Fallback before parsed
                        return ChatBubble(text: message.content, isUser: false);
                      }
                    }
                  },
                ),
        ),
        const ChatInputBar(),
      ],
    );
  }
}

class _AiCoachDashboard extends StatelessWidget {
  const _AiCoachDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào bạn, hôm nay tập gì?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Huấn luyện viên cá nhân ảo dựa trên mục tiêu, thể trạng và lịch tập trong FlexFit.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AssistantActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Gợi ý lịch tập',
            subtitle: 'PT lên lịch theo mục tiêu của bạn',
            accent: Color(0xFFFF6B16),
            intent: AiCoachIntent.todayWorkout,
          ),
          _AssistantActionCard(
            icon: Icons.search_rounded,
            title: 'Tìm lớp học',
            subtitle: 'Lớp phù hợp với thể trạng và lịch tập',
            accent: Color(0xFF22C55E),
            intent: AiCoachIntent.findClass,
          ),
          _AssistantActionCard(
            icon: Icons.self_improvement_rounded,
            title: 'Phục hồi cơ bắp',
            subtitle: 'Giãn cơ, mobility, yoga nhẹ',
            accent: Color(0xFFF59E0B),
            intent: AiCoachIntent.recovery,
          ),
          _AssistantActionCard(
            icon: Icons.fitness_center_rounded,
            title: 'Chọn phòng gym',
            subtitle: 'Tìm phòng tập phù hợp trong FlexFit',
            accent: Color(0xFF38BDF8),
            intent: AiCoachIntent.gymRecommendation,
          ),
          const SizedBox(height: 18),
          const SuggestedPromptChips(),
        ],
      ),
    );
  }
}

class _AssistantActionCard extends StatelessWidget {
  const _AssistantActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.intent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final AiCoachIntent intent;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AiCoachProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading
              ? null
              : () =>
                    context.read<AiCoachProvider>().sendDashboardAction(intent),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
