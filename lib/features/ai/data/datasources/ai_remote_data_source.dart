import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../models/ai_models.dart';

class AiRemoteDataSource {
  AiRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AiSuggestionModel> getWorkoutSuggestion() async {
    final response = await _apiClient.get('/AI/suggest-workout');
    return _parseSuggestionResponse(response);
  }

  Future<AiSuggestionModel> getClassSuggestion() async {
    final response = await _apiClient.get('/AI/suggest-classes');
    return _parseSuggestionResponse(response);
  }

  Future<AiChatResponseModel> sendChatMessage(
    AiChatRequestModel request,
  ) async {
    const path = '/AI/chat';
    try {
      debugPrint('AI REQUEST PATH: $path');
      debugPrint('AI REQUEST BODY: ${request.toJson()}');

      final response = await _apiClient.post(path, body: request.toJson());

      debugPrint('AI RESPONSE RAW: $response');
      final chatResponse = AiChatResponseModel.fromDynamic(response);
      if (chatResponse.response.trim().isEmpty) {
        _logParseError(response);
        throw const ApiException('AI response body did not contain a reply.');
      }
      return chatResponse;
    } catch (e, stackTrace) {
      debugPrint('AI API ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  AiSuggestionModel _parseSuggestionResponse(dynamic response) {
    final suggestion = AiSuggestionModel.fromDynamic(response);
    if (suggestion.suggestion.trim().isEmpty) {
      _logParseError(response);
      throw const ApiException(
        'AI suggestion response body did not contain suggestion text.',
      );
    }
    return suggestion;
  }

  void _logParseError(dynamic response) {
    debugPrint('AI PARSE ERROR: unsupported response shape');
    debugPrint('AI RESPONSE RAW: $response');
  }
}
