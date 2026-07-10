import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';

class AiChatMessageModel {
  const AiChatMessageModel({required this.role, required this.content});

  final String role; // "user" or "model"
  final String content;

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AiChatMessageModel(
      role: json['role']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class AiCoachRecommendation {
  const AiCoachRecommendation({
    required this.summary,
    this.workoutTips = const [],
    this.recommendedGyms = const [],
    this.recommendedClasses = const [],
    this.reason,
  });

  final String summary;
  final List<String> workoutTips;
  final List<RecommendedGym> recommendedGyms;
  final List<RecommendedClass> recommendedClasses;
  final String? reason;

  bool get hasData =>
      workoutTips.isNotEmpty ||
      recommendedGyms.isNotEmpty ||
      recommendedClasses.isNotEmpty;

  bool get hasCatalogData =>
      recommendedGyms.isNotEmpty || recommendedClasses.isNotEmpty;
}

class RecommendedGym {
  const RecommendedGym({
    required this.id,
    required this.name,
    this.branchName,
    this.address,
    this.imageUrl,
    this.reason,
    this.source,
  });

  final String id;
  final String name;
  final String? branchName;
  final String? address;
  final String? imageUrl;
  final String? reason;
  final Gym? source;

  factory RecommendedGym.fromGym(Gym gym, {String? reason}) {
    return RecommendedGym(
      id: gym.id,
      name: gym.name,
      branchName: gym.branchName,
      address: gym.branchAddress,
      imageUrl: gym.thumbnailUrl,
      reason: reason,
      source: gym,
    );
  }
}

class RecommendedClass {
  const RecommendedClass({
    required this.id,
    required this.title,
    required this.branchName,
    required this.categoryName,
    this.address,
    this.startTime,
    this.imageUrl,
    this.reason,
    this.source,
  });

  final String id;
  final String title;
  final String branchName;
  final String categoryName;
  final String? address;
  final DateTime? startTime;
  final String? imageUrl;
  final String? reason;
  final FitnessClass? source;

  factory RecommendedClass.fromFitnessClass(
    FitnessClass fitnessClass, {
    String? address,
    String? reason,
  }) {
    return RecommendedClass(
      id: fitnessClass.id,
      title: fitnessClass.name,
      branchName: fitnessClass.branchName,
      categoryName: fitnessClass.categoryName,
      address: address,
      startTime: fitnessClass.startTime,
      imageUrl: fitnessClass.thumbnailUrl,
      reason: reason,
      source: fitnessClass,
    );
  }
}

class AiChatRequestModel {
  const AiChatRequestModel({required this.message, this.history});

  final String message;
  final List<AiChatMessageModel>? history;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (history != null) 'history': history!.map((e) => e.toJson()).toList(),
    };
  }
}

class AiChatResponseModel {
  const AiChatResponseModel({required this.response});

  final String response;

  factory AiChatResponseModel.fromDynamic(dynamic value) {
    return AiChatResponseModel(response: _extractAiText(value) ?? '');
  }

  factory AiChatResponseModel.fromJson(Map<String, dynamic> json) {
    return AiChatResponseModel(response: _extractAiText(json) ?? '');
  }
}

class AiSuggestionModel {
  const AiSuggestionModel({required this.suggestion, this.suggestedAt});

  final String suggestion;
  final DateTime? suggestedAt;

  factory AiSuggestionModel.fromDynamic(dynamic value) {
    final json = value is Map ? Map<String, dynamic>.from(value) : null;
    return AiSuggestionModel(
      suggestion: _extractAiText(value) ?? '',
      suggestedAt: json == null ? null : _dateTime(json, 'suggestedAt'),
    );
  }

  factory AiSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionModel(
      suggestion: _extractAiText(json) ?? '',
      suggestedAt: _dateTime(json, 'suggestedAt'),
    );
  }
}

String? _extractAiText(dynamic value) {
  if (value is String) {
    final text = value.trim();
    return text.isEmpty ? null : value;
  }

  if (value is! Map) {
    return null;
  }

  final json = Map<String, dynamic>.from(value);
  final data = _read(json, 'data');
  if (data != null) {
    final dataText = _extractAiText(data);
    if (dataText != null) {
      return dataText;
    }
  }

  return _string(json, 'response') ??
      _string(json, 'suggestion') ??
      _string(json, 'reply') ??
      _string(json, 'message') ??
      _string(json, 'result') ??
      _string(json, 'answer');
}

String? _string(Map<String, dynamic> json, String key) {
  final value = _read(json, key);
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

DateTime? _dateTime(Map<String, dynamic> json, String key) {
  final value = _read(json, key)?.toString();
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
