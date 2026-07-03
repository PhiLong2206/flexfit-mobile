import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/di/injection_container.dart';
import '../providers/ai_suggestion_provider.dart';
import 'ai_suggestion_detail_sheet.dart';

class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiSuggestionProvider(
        getWorkoutSuggestionUseCase: sl(),
        getClassSuggestionUseCase: sl(),
      )..fetchSuggestion(),
      child: const _AiSuggestionCardContent(),
    );
  }
}

class _AiSuggestionCardContent extends StatelessWidget {
  const _AiSuggestionCardContent();

  List<String> _parsePreviewBullets(String text) {
    final lines = text.split('\n');
    final bullets = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
        var clean = trimmed.substring(1).trim();
        // Remove markdown bold
        clean = clean.replaceAll('**', '');
        if (clean.isNotEmpty) {
          bullets.add(clean);
          if (bullets.length == 3) break; // Lấy tối đa 3 bullet
        }
      }
    }
    return bullets;
  }

  void _showDetailSheet(BuildContext context, String fullText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: AiSuggestionDetailSheet(suggestionText: fullText),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiSuggestionProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1E18), Color(0xFF1A1F2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B16).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF6B16), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI Gợi ý cho bạn',
                  style: TextStyle(
                    color: Color(0xFFFF6B16),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (provider.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B16)),
                  )
                else
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                    onPressed: () => context.read<AiSuggestionProvider>().fetchSuggestion(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Builder(
              builder: (context) {
                if (provider.error != null) {
                  return Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  );
                } else if (provider.suggestionText != null) {
                  final bullets = _parsePreviewBullets(provider.suggestionText!);
                  if (bullets.isEmpty) {
                    return Text(
                      provider.suggestionText!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hôm nay bạn nên ưu tiên:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...bullets.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFFFF6B16), fontSize: 16, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(b, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4))),
                          ],
                        ),
                      )),
                    ],
                  );
                } else if (!provider.isLoading) {
                  return const Text(
                    'Không có gợi ý nào lúc này.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  );
                }
                return const SizedBox(height: 40); // Loading placeholder height
              },
            ),
          ),
          if (provider.suggestionText != null && !provider.isLoading) ...[
            const Divider(color: Colors.white12, height: 1),
            InkWell(
              onTap: () => _showDetailSheet(context, provider.suggestionText!),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    'Xem chi tiết kế hoạch',
                    style: TextStyle(
                      color: Color(0xFFFF6B16),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
