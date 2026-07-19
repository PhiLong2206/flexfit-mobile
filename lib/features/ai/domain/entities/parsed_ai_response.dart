import '../../presentation/helpers/ai_text_formatter.dart';

class ParsedAiResponse {
  const ParsedAiResponse({
    required this.summary,
    required this.workoutHighlights,
    required this.recommendedClassKeywords,
  });

  final String summary;
  final List<String> workoutHighlights;
  final List<String> recommendedClassKeywords;
}

class AiResponseParser {
  static ParsedAiResponse parse(String rawText) {
    final text = AiTextFormatter.cleanAiText(rawText);
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const ParsedAiResponse(
        summary: '',
        workoutHighlights: [],
        recommendedClassKeywords: [],
      );
    }

    var summary = lines.first.replaceFirst(RegExp(r'^[•â€¢]\s*'), '');
    if (lines.length > 1 &&
        !RegExp(r'^[•â€¢\-\*]').hasMatch(lines[1]) &&
        !_isSectionTitle(lines[1])) {
      summary += ' ${lines[1]}';
    }
    if (summary.length > 150) {
      summary = '${summary.substring(0, 147)}...';
    }

    final workoutHighlights = <String>[];
    for (final line in lines) {
      if (RegExp(r'^[•â€¢\-\*]').hasMatch(line)) {
        final bullet = line.replaceFirst(RegExp(r'^[•â€¢\-\*]\s*'), '').trim();
        if (bullet.isNotEmpty) {
          workoutHighlights.add(bullet);
        }
      }
      if (workoutHighlights.length >= 3) break;
    }

    final recommendedClassKeywords = <String>[];
    final lowerText = text.toLowerCase();
    for (final keyword in const [
      'yoga',
      'hiit',
      'cardio',
      'strength',
      'pilates',
      'dance',
      'zumba',
      'boxing',
      'core',
      'stretching',
      'cycling',
      'functional',
      'crossfit',
    ]) {
      if (lowerText.contains(keyword) && recommendedClassKeywords.length < 3) {
        recommendedClassKeywords.add(keyword);
      }
    }

    return ParsedAiResponse(
      summary: summary,
      workoutHighlights: workoutHighlights,
      recommendedClassKeywords: recommendedClassKeywords,
    );
  }

  static bool _isSectionTitle(String line) {
    final lower = line.toLowerCase();
    return lower.endsWith(':') ||
        lower == 'gợi ý hôm nay' ||
        lower == 'lớp phù hợp' ||
        lower == 'phòng tập phù hợp' ||
        lower == 'lý do';
  }
}
