class AiTextFormatter {
  const AiTextFormatter._();

  static const String _truncatedSuffix =
      'Bạn có thể hỏi thêm để xem kế hoạch chi tiết.';

  static bool looksLikeRawJson(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return false;
    }
    final startsLikeJson =
        (text.startsWith('{') && text.endsWith('}')) ||
        (text.startsWith('[') && text.endsWith(']'));
    if (!startsLikeJson) {
      return false;
    }
    return RegExp(
      r'"(?:response|message|answer|suggestion|data|content)"\s*:',
      caseSensitive: false,
    ).hasMatch(text);
  }

  static String sanitizeAiResponse(String value) {
    var text = value.trim();
    if (text.isEmpty) {
      return '';
    }
    if (looksLikeRawJson(text)) {
      return 'AI Coach đã nhận phản hồi nhưng chưa thể hiển thị đúng định dạng. Mình sẽ tóm tắt lại ngắn gọn theo dữ liệu FlexFit.';
    }

    text = text
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'(\*\*|__)(.*?)\1'), r'$2')
        .replaceAll(RegExp(r'(?<![\w:/])[*_]([^*_]+)[*_](?!\w)'), r'$1')
        .replaceAll(RegExp(r'^\s*(-{3,}|={3,}|_{3,})\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\d+[\.\)]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\|?[\s:\-\|]+\|?\s*$', multiLine: true), '')
        .trim();

    final keptLines = <String>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        keptLines.add('');
        continue;
      }
      if (_looksLikeMarkdownTable(line)) {
        final cells = line
            .split('|')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
        if (cells.isNotEmpty) {
          keptLines.add('• ${cells.join(', ')}');
        }
      } else {
        keptLines.add(line);
      }
    }

    text = keptLines.join('\n');
    return text
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String compactAiResponse(String value, {int maxCharacters = 700}) {
    final text = sanitizeAiResponse(value);
    if (text.length <= maxCharacters) {
      return text;
    }

    final safeLimit = maxCharacters.clamp(120, text.length).toInt();
    var end = text.lastIndexOf(RegExp(r'[\.\?!]\s'), safeLimit);
    if (end < maxCharacters * 0.55) {
      end = text.lastIndexOf('\n', safeLimit);
    }
    if (end < maxCharacters * 0.55) {
      end = text.lastIndexOf(' ', safeLimit);
    }
    if (end < 1) {
      end = safeLimit;
    }

    final compact = text.substring(0, end).trimRight();
    return '$compact\n\n$_truncatedSuffix';
  }

  static String cleanAiText(String raw, {int maxWords = 130}) {
    return compactAiResponse(raw, maxCharacters: 700);
  }

  static String limitMobileLength(String raw, {int maxWords = 130}) {
    final text = raw.trim();
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) {
      return text;
    }
    return '${words.take(maxWords).join(' ')}...';
  }

  static List<String> buildPreviewBullets(String raw) {
    final cleaned = removeUnsupportedNutrition(compactAiResponse(raw));
    final lines = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final bullets = <String>[];
    for (final line in lines) {
      final normalized = line
          .replaceFirst(RegExp(r'^[•\-\*]\s*'), '')
          .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
          .trim();
      if (normalized.isEmpty || _isSectionTitle(normalized)) {
        continue;
      }
      bullets.add(_shorten(normalized));
      if (bullets.length == 3) {
        break;
      }
    }

    if (bullets.isNotEmpty) {
      return bullets;
    }

    return const [
      'PT đã phân tích mục tiêu và lịch tập của bạn.',
      'Hôm nay nên ưu tiên bài tập vừa sức, có cấu trúc rõ ràng.',
      'Bấm xem chi tiết để xem kế hoạch đầy đủ.',
    ];
  }

  static String removeUnsupportedNutrition(String raw) {
    final blocked = [
      'dinh dưỡng',
      'ăn uống',
      'protein',
      'thực phẩm',
      'nước/ngày',
      'nước mỗi ngày',
      'đồ uống có cồn',
      'meal plan',
    ];

    final kept = <String>[];
    var skipping = false;
    for (final line in raw.split('\n')) {
      final lower = line.toLowerCase();
      final isBlocked = blocked.any(lower.contains);
      final isSection =
          lower.endsWith(':') || RegExp(r'^\d+[\.\)]').hasMatch(lower);

      if (isBlocked) {
        skipping = true;
        continue;
      }
      if (skipping && isSection) {
        skipping = false;
      }
      if (!skipping) {
        kept.add(line);
      }
    }

    return kept.join('\n').trim();
  }

  static bool _isSectionTitle(String text) {
    final lower = text.toLowerCase();
    return lower.endsWith(':') ||
        lower == 'gợi ý' ||
        lower == 'kế hoạch tập' ||
        lower == 'điểm mạnh' ||
        lower == 'cần cải thiện' ||
        lower == 'gợi ý hôm nay' ||
        lower == 'lớp phù hợp' ||
        lower == 'phòng tập phù hợp' ||
        lower == 'lý do';
  }

  static String _shorten(String text) {
    const maxLength = 90;
    if (text.length <= maxLength) {
      return text;
    }

    final cut = text.lastIndexOf(' ', maxLength);
    final end = cut < 48 ? maxLength : cut;
    return text.substring(0, end).trimRight();
  }

  static bool _looksLikeMarkdownTable(String line) {
    if (!line.contains('|') || line.contains('://')) {
      return false;
    }
    final parts = line
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.length >= 2;
  }
}
