class WorkoutSuggestionModel {
  const WorkoutSuggestionModel({
    required this.title,
    required this.description,
    required this.points,
  });

  final String title;
  final String description;
  final List<String> points;

  factory WorkoutSuggestionModel.fromJson(Map<String, dynamic> json) {
    // Dynamically handle response structures from AI suggestion endpoint
    final rawTitle = _read(json, 'title') ?? 'Gợi ý lịch tập hôm nay';
    final rawDesc = _read(json, 'description') ?? _read(json, 'content') ?? '';
    
    final rawPoints = _read(json, 'points') ?? _read(json, 'bullets') ?? _read(json, 'suggestions') ?? [];
    List<String> parsedPoints = [];
    if (rawPoints is List) {
      parsedPoints = rawPoints.map((e) => e.toString()).toList();
    } else if (rawPoints is String && rawPoints.isNotEmpty) {
      parsedPoints = rawPoints.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }

    // Fallback if no points but description contains bullet points
    if (parsedPoints.isEmpty && rawDesc is String) {
      final lines = rawDesc.split('\n');
      for (var line in lines) {
        final clean = line.trim();
        if (clean.startsWith('•') || clean.startsWith('-') || clean.startsWith('*')) {
          parsedPoints.add(clean.substring(1).trim());
        }
      }
    }

    return WorkoutSuggestionModel(
      title: rawTitle.toString(),
      description: rawDesc.toString(),
      points: parsedPoints,
    );
  }
}

class ClassSuggestionModel {
  const ClassSuggestionModel({
    required this.title,
    required this.description,
    required this.points,
  });

  final String title;
  final String description;
  final List<String> points;

  factory ClassSuggestionModel.fromJson(Map<String, dynamic> json) {
    final rawTitle = _read(json, 'title') ?? 'Hôm nay nên tập gì';
    final rawDesc = _read(json, 'description') ?? _read(json, 'content') ?? '';
    
    final rawPoints = _read(json, 'points') ?? _read(json, 'bullets') ?? _read(json, 'suggestions') ?? [];
    List<String> parsedPoints = [];
    if (rawPoints is List) {
      parsedPoints = rawPoints.map((e) => e.toString()).toList();
    } else if (rawPoints is String && rawPoints.isNotEmpty) {
      parsedPoints = rawPoints.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }

    // Fallback if no points but description contains bullet points
    if (parsedPoints.isEmpty && rawDesc is String) {
      final lines = rawDesc.split('\n');
      for (var line in lines) {
        final clean = line.trim();
        if (clean.startsWith('•') || clean.startsWith('-') || clean.startsWith('*')) {
          parsedPoints.add(clean.substring(1).trim());
        }
      }
    }

    return ClassSuggestionModel(
      title: rawTitle.toString(),
      description: rawDesc.toString(),
      points: parsedPoints,
    );
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
