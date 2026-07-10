import 'package:flutter/material.dart';

import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../booking/presentation/screens/gym_detail_page.dart';
import '../../../gym/presentation/screens/explore_page.dart';
import '../../domain/entities/parsed_ai_response.dart';
import '../helpers/ai_text_formatter.dart';
import 'ai_class_recommendation_card.dart';

class CompactAiResponseBubble extends StatefulWidget {
  const CompactAiResponseBubble({
    super.key,
    required this.parsedResponse,
    required this.recommendedClasses,
    required this.rawText,
    this.title,
    this.recommendedGyms,
    this.recommendationNote,
  });

  final ParsedAiResponse parsedResponse;
  final List<FitnessClass>? recommendedClasses;
  final String rawText;
  final String? title;
  final List<Gym>? recommendedGyms;
  final String? recommendationNote;

  @override
  State<CompactAiResponseBubble> createState() =>
      _CompactAiResponseBubbleState();
}

class _CompactAiResponseBubbleState extends State<CompactAiResponseBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cleanedText = AiTextFormatter.removeUnsupportedNutrition(
      AiTextFormatter.compactAiResponse(widget.rawText),
    );
    final previewBullets = AiTextFormatter.buildPreviewBullets(cleanedText);
    final recommendedClasses = _dedupeClasses(widget.recommendedClasses);
    final recommendedGyms = _dedupeGyms(widget.recommendedGyms);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFF6B16),
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(topLeft: const Radius.circular(0)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title ?? 'PT gợi ý',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(
                              0xFF22C55E,
                            ).withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          'PT GỢI Ý',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_expanded) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: SingleChildScrollView(
                        child: Text(
                          cleanedText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ...previewBullets.map(_PreviewBullet.new),
                  ],
                  const SizedBox(height: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Thu gọn' : 'Xem chi tiết',
                      style: const TextStyle(
                        color: Color(0xFFFF6B16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (recommendedClasses.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Lớp học phù hợp cho bạn:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...recommendedClasses.map(
                      (fc) => AiClassRecommendationWidget(fitnessClass: fc),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExplorePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Xem kế hoạch chi tiết',
                        style: TextStyle(color: Color(0xFFFF6B16)),
                      ),
                    ),
                  ],
                  if (recommendedGyms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Phòng gym phù hợp cho bạn:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...recommendedGyms.map(
                      (gym) => _AiGymRecommendationCard(gym: gym),
                    ),
                  ],
                  if (widget.recommendationNote?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.recommendationNote!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FitnessClass> _dedupeClasses(List<FitnessClass>? classes) {
    final seen = <String>{};
    final result = <FitnessClass>[];
    for (final fitnessClass in classes ?? const <FitnessClass>[]) {
      if (seen.add(fitnessClass.id.toLowerCase())) {
        result.add(fitnessClass);
      }
    }
    return result.take(3).toList();
  }

  List<Gym> _dedupeGyms(List<Gym>? gyms) {
    final seen = <String>{};
    final result = <Gym>[];
    for (final gym in gyms ?? const <Gym>[]) {
      if (seen.add(gym.id.toLowerCase())) {
        result.add(gym);
      }
    }
    return result.take(3).toList();
  }
}

class _PreviewBullet extends StatelessWidget {
  const _PreviewBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFFFF6B16),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiGymRecommendationCard extends StatelessWidget {
  const _AiGymRecommendationCard({required this.gym});

  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      gym.branchName,
      gym.branchAddress,
      if (gym.ratingAverage > 0) '${gym.ratingAverage.toStringAsFixed(1)} sao',
    ].whereType<String>().where((text) => text.trim().isNotEmpty).join(' • ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B16),
              backgroundColor: const Color(0xFFFF6B16).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GymDetailPage(gymId: gym.id)),
              );
            },
            child: const Text(
              'Xem phòng tập',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
