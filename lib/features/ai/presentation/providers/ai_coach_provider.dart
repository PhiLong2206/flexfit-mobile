import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../membership/data/repositories/credit_repository.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../data/models/ai_models.dart';
import '../../domain/entities/parsed_ai_response.dart';
import '../../domain/usecases/chat_with_ai_usecase.dart';
import '../../domain/usecases/get_workout_suggestion_usecase.dart';
import '../helpers/ai_text_formatter.dart';

enum AiCoachIntent {
  greeting,
  todayWorkout,
  workoutPlan,
  findClass,
  gymRecommendation,
  schedule,
  credit,
  recovery,
  painGuidance,
  nutritionUnsupported,
  unclearShortText,
  outOfScope,
  flexfitCoachChat,
}

class AiCoachProvider extends ChangeNotifier {
  AiCoachProvider(
    this._chatWithAiUseCase, {
    GetWorkoutSuggestionUseCase? workoutSuggestionUseCase,
  });

  final ChatWithAiUseCase _chatWithAiUseCase;
  final CatalogRepository _catalogRepository = CatalogRepository();
  final BookingRepository _bookingRepository = BookingRepository();
  final CreditRepository _creditRepository = CreditRepository();

  final List<AiChatMessageModel> _messages = [];
  List<AiChatMessageModel> get messages => List.unmodifiable(_messages);

  final Map<int, ParsedAiResponse> _parsedMessages = {};
  final Map<int, AiCoachRecommendation> _structuredRecommendations = {};
  final Map<int, List<FitnessClass>> _recommendedClasses = {};
  final Map<int, List<Gym>> _recommendedGyms = {};
  final Map<int, String> _recommendationNotes = {};
  final Map<int, String> _responseTitles = {};

  ParsedAiResponse? getParsedMessage(int index) => _parsedMessages[index];
  AiCoachRecommendation? getStructuredRecommendation(int index) =>
      _structuredRecommendations[index];
  List<FitnessClass>? getRecommendedClasses(int index) =>
      _recommendedClasses[index];
  List<Gym>? getRecommendedGyms(int index) => _recommendedGyms[index];
  String? getRecommendationNote(int index) => _recommendationNotes[index];
  String? getResponseTitle(int index) => _responseTitles[index];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void addMessage(AiChatMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_isLoading) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = AiChatMessageModel(role: 'user', content: trimmed);
    addMessage(userMessage);

    final intent = _detectIntent(trimmed);
    debugPrint('AI INPUT: $trimmed');
    debugPrint('AI INTENT: $intent');
    if (intent == AiCoachIntent.outOfScope) {
      debugPrint('AI BLOCKED: true');
      _addLocalAiMessage(_outOfScopeMessage);
      return;
    }
    debugPrint('AI BLOCKED: false');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (intent) {
        case AiCoachIntent.greeting:
          await _sendGreetingOverview();
          return;
        case AiCoachIntent.todayWorkout:
          await _sendWorkoutSuggestion(trimmed);
          return;
        case AiCoachIntent.workoutPlan:
          await _sendCatalogAwareRecommendation(
            trimmed,
            title: 'Kế hoạch tập phù hợp',
            includeClasses: true,
            includeGyms: true,
          );
          return;
        case AiCoachIntent.findClass:
          await _sendClassRecommendations(trimmed);
          return;
        case AiCoachIntent.gymRecommendation:
          await _sendGymRecommendations(trimmed);
          return;
        case AiCoachIntent.schedule:
          await _sendScheduleOverview();
          return;
        case AiCoachIntent.credit:
          await _sendCreditOverview();
          return;
        case AiCoachIntent.recovery:
        case AiCoachIntent.painGuidance:
          await _sendHealthGuidance(trimmed);
          return;
        case AiCoachIntent.nutritionUnsupported:
          _addLocalAiMessage(
            _nutritionUnsupportedMessage,
            title: 'Dinh dưỡng trong FlexFit',
          );
          return;
        case AiCoachIntent.unclearShortText:
          _addLocalAiMessage(_unknownFlexFitMessage, title: 'FlexFit AI Coach');
          return;
        case AiCoachIntent.outOfScope:
          _addLocalAiMessage(_outOfScopeMessage);
          return;
        case AiCoachIntent.flexfitCoachChat:
          break;
      }

      if (_needsCatalogContext(trimmed)) {
        await _sendCatalogAwareRecommendation(
          trimmed,
          title: 'Gợi ý phù hợp',
          includeClasses: true,
          includeGyms: true,
        );
        return;
      }

      final request = AiChatRequestModel(
        message: _coachPersonaMessage(trimmed),
        history: _messages.where((m) => m != userMessage).toList(),
      );
      final response = await _chatWithAiUseCase(request);
      final responseText =
          _shouldReplaceBackendResponse(trimmed, response.response)
          ? _healthGuidanceMessage
          : response.response;

      await _addAiResponse(responseText, userText: trimmed);
    } catch (e, stackTrace) {
      debugPrint('AI Coach Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _error = 'Không thể lấy gợi ý lúc này. Vui lòng thử lại.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> sendDashboardAction(AiCoachIntent intent) async {
    switch (intent) {
      case AiCoachIntent.todayWorkout:
        await sendMessage('Hôm nay nên tập gì?');
        return;
      case AiCoachIntent.workoutPlan:
        await sendMessage('Tôi muốn tập theo mục tiêu của mình');
        return;
      case AiCoachIntent.findClass:
        await sendMessage('Tìm lớp học phù hợp');
        return;
      case AiCoachIntent.gymRecommendation:
        await sendMessage('Nên tập phòng gym nào?');
        return;
      case AiCoachIntent.schedule:
        await sendMessage('Lịch tập tiếp theo của tôi');
        return;
      case AiCoachIntent.credit:
        await sendMessage('Tôi còn bao nhiêu credits?');
        return;
      case AiCoachIntent.recovery:
      case AiCoachIntent.painGuidance:
        await sendMessage('Phục hồi cơ bắp');
        return;
      case AiCoachIntent.nutritionUnsupported:
        await sendMessage('Hôm nay ăn gì?');
        return;
      case AiCoachIntent.unclearShortText:
        await sendMessage('ok');
        return;
      case AiCoachIntent.greeting:
        await sendMessage('Chào');
        return;
      case AiCoachIntent.outOfScope:
      case AiCoachIntent.flexfitCoachChat:
        return;
    }
  }

  Future<void> _sendGreetingOverview() async {
    final lines = <String>[
      'Mình là FlexFit AI Coach — PT ảo của bạn.',
      'Mình dựa trên mục tiêu, thể trạng, lịch tập, lớp học và phòng gym trong FlexFit để gợi ý kế hoạch tập phù hợp.',
      '',
      'Hôm nay mình có thể giúp bạn:',
      '• Gợi ý lịch tập',
      '• Tìm lớp học phù hợp',
      '• Chọn phòng gym',
      '• Gợi ý phục hồi cơ bắp',
    ];

    try {
      final profileUseCase = _profileUseCase;
      final profile = profileUseCase == null ? null : await profileUseCase();
      final name = profile?.fullName.trim();
      if (name != null && name.isNotEmpty) {
        lines.insert(0, 'Chào ${_firstName(name)} 👋');
      } else {
        lines.insert(0, 'Chào bạn 👋');
      }
      final goal = profile?.fitnessGoal?.trim();
      if (goal != null && goal.isNotEmpty) {
        lines.add('Mục tiêu của bạn là $goal.');
      }
    } catch (_) {
      lines.insert(0, 'Chào bạn 👋');
    }

    try {
      final credit = await _creditRepository.getMyCredit();
      lines.add('Hiện bạn có ${credit.balance} credits.');
    } catch (_) {}

    try {
      final nextBooking = await _nextUpcomingBooking();
      if (nextBooking != null) {
        final location = [nextBooking.branchName, nextBooking.gymName]
            .whereType<String>()
            .where((text) => text.trim().isNotEmpty)
            .join(' - ');
        lines.add(
          'Lịch tập tiếp theo: ${nextBooking.title}'
          '${location.isEmpty ? '' : ' tại $location'} lúc ${_formatTime(nextBooking.startTime)}.',
        );
      }
    } catch (_) {}

    lines.add('Bạn có thể chọn một gợi ý bên dưới để bắt đầu.');

    _addLocalAiMessage(lines.join('\n'), title: 'FlexFit AI Coach');
  }

  Future<void> _sendWorkoutSuggestion(String userText) async {
    await _sendCatalogAwareRecommendation(
      userText,
      title: 'Gợi ý hôm nay',
      includeClasses: true,
      includeGyms: true,
      preferToday: true,
    );
  }

  Future<void> _sendClassRecommendations(String userText) async {
    await _sendCatalogAwareRecommendation(
      userText,
      title: 'Lớp phù hợp',
      includeClasses: true,
      includeGyms: true,
    );
  }

  Future<void> _sendHealthGuidance(String userText) async {
    await _addAiResponse(
      _healthGuidanceMessage,
      userText: userText,
      title: 'Phục hồi cơ bắp',
    );
  }

  Future<void> _sendGymRecommendations(String userText) async {
    await _sendCatalogAwareRecommendation(
      userText,
      title: 'Phòng gym phù hợp',
      includeClasses: true,
      includeGyms: true,
    );
  }

  Future<void> _sendCatalogAwareRecommendation(
    String userText, {
    required String title,
    required bool includeClasses,
    required bool includeGyms,
    bool preferToday = false,
  }) async {
    final snapshot = await _loadCatalogSnapshot();
    final recommendation = _buildRecommendation(
      snapshot,
      userText: userText,
      includeClasses: includeClasses,
      includeGyms: includeGyms,
      preferToday: preferToday,
    );

    var responseText = _fallbackRecommendationText(recommendation);
    try {
      final response = await _chatWithAiUseCase(
        AiChatRequestModel(
          message: _catalogPrompt(userText, snapshot, recommendation),
          history: _messages.take(_messages.length - 1).toList(),
        ),
      );
      final cleaned = AiTextFormatter.sanitizeAiResponse(response.response);
      if (cleaned.isNotEmpty && !_looksLikeAiError(cleaned)) {
        responseText =
            recommendation.recommendedGyms.isNotEmpty &&
                _containsNoGymFallback(cleaned)
            ? _fallbackRecommendationText(recommendation)
            : cleaned;
      }
    } catch (e) {
      debugPrint('AI catalog prompt fallback used: $e');
      if (recommendation.hasCatalogData) {
        responseText =
            'AI Coach đang tạm thời không phản hồi. Đây là một số lựa chọn từ FlexFit.';
      }
    }

    final index = _addLocalAiMessage(responseText, title: title);
    _structuredRecommendations[index] = recommendation;
    final classSources = recommendation.recommendedClasses
        .map((item) => item.source)
        .whereType<FitnessClass>()
        .toList();
    final gymSources = recommendation.recommendedGyms
        .map((item) => item.source)
        .whereType<Gym>()
        .toList();
    if (classSources.isNotEmpty) {
      _recommendedClasses[index] = classSources;
    }
    if (gymSources.isNotEmpty) {
      _recommendedGyms[index] = gymSources;
    }
    if (!recommendation.hasCatalogData) {
      _recommendationNotes[index] =
          'Hiện tại FlexFit chưa có lớp hoặc phòng tập phù hợp trong dữ liệu hiện có.';
    }
    notifyListeners();
  }

  Future<_AiCatalogSnapshot> _loadCatalogSnapshot() async {
    final results = await Future.wait<Object?>([
      _safeLoadGyms(),
      _safeLoadBranches(),
      _safeLoadClasses(),
      _safeLoadCategories(),
      _safeLoadBookings(),
      _safeLoadProfile(),
    ]);

    return _AiCatalogSnapshot(
      gyms: results[0] as List<Gym>,
      branches: results[1] as List<Branch>,
      classes: results[2] as List<FitnessClass>,
      categories: results[3] as List<Category>,
      bookings: results[4] as List<BookingModel>,
      profile: results[5] as Profile?,
    );
  }

  Future<List<Gym>> _safeLoadGyms() async {
    try {
      return await _catalogRepository.getGyms();
    } catch (e) {
      debugPrint('AI catalog gyms ignored: $e');
      return const [];
    }
  }

  Future<List<Branch>> _safeLoadBranches() async {
    try {
      return await _catalogRepository.getBranches();
    } catch (e) {
      debugPrint('AI catalog branches ignored: $e');
      return const [];
    }
  }

  Future<List<FitnessClass>> _safeLoadClasses() async {
    try {
      return await _catalogRepository.getClasses();
    } catch (e) {
      debugPrint('AI catalog classes ignored: $e');
      return const [];
    }
  }

  Future<List<Category>> _safeLoadCategories() async {
    try {
      return await _catalogRepository.getCategories();
    } catch (e) {
      debugPrint('AI catalog categories ignored: $e');
      return const [];
    }
  }

  Future<List<BookingModel>> _safeLoadBookings() async {
    try {
      return await _bookingRepository.getMyBookings();
    } catch (_) {
      return const [];
    }
  }

  Future<Profile?> _safeLoadProfile() async {
    final profileUseCase = _profileUseCase;
    if (profileUseCase == null) {
      return null;
    }
    try {
      return await profileUseCase();
    } catch (_) {
      return null;
    }
  }

  AiCoachRecommendation _buildRecommendation(
    _AiCatalogSnapshot snapshot, {
    required String userText,
    required bool includeClasses,
    required bool includeGyms,
    required bool preferToday,
  }) {
    final matchedClasses = includeClasses
        ? _rankClasses(snapshot, userText, preferToday: preferToday).take(3)
        : const Iterable<_ScoredClass>.empty();
    final selectedClasses = matchedClasses
        .map(
          (item) => RecommendedClass.fromFitnessClass(
            item.value,
            address: snapshot.branchById[item.value.branchId]?.displayAddress,
            reason: item.reason,
          ),
        )
        .toList();

    final rankedGyms = includeGyms
        ? _rankGyms(snapshot, userText, selectedClasses)
        : const <_ScoredGym>[];
    final gymSelection = includeGyms
        ? _selectGymsForRecommendation(
            snapshot,
            userText: userText,
            rankedGyms: rankedGyms,
          )
        : const _GymSelection(scoredGyms: [], fallbackUsed: false);

    final selectedGyms = gymSelection.scoredGyms
        .map((item) => RecommendedGym.fromGym(item.value, reason: item.reason))
        .toList();
    _debugLogGymSelection(
      snapshot: snapshot,
      activeGymCount: includeGyms
          ? snapshot.gyms.where(_isActiveGym).length
          : 0,
      selectedGyms: gymSelection.scoredGyms.map((item) => item.value).toList(),
      classCount: selectedClasses.length,
      fallbackUsed: gymSelection.fallbackUsed,
    );

    final hasMatches = selectedClasses.isNotEmpty || selectedGyms.isNotEmpty;
    return AiCoachRecommendation(
      summary: hasMatches
          ? 'Mình đã lọc dữ liệu FlexFit thật để chọn gợi ý phù hợp.'
          : 'Hiện tại FlexFit chưa có lựa chọn phù hợp trong dữ liệu hiện có.',
      workoutTips: _workoutTipsFor(userText, snapshot.profile),
      recommendedClasses: selectedClasses,
      recommendedGyms: selectedGyms,
      reason: _personalizedReason(userText, snapshot.profile),
    );
  }

  List<_ScoredClass> _rankClasses(
    _AiCatalogSnapshot snapshot,
    String userText, {
    required bool preferToday,
  }) {
    final query = _normalizeForMatch(userText);
    final queryTerms = _queryTerms(userText, snapshot.categories);
    final preferredEvening = _containsAny(query, [
      'toi',
      'buoi toi',
      'evening',
    ]);
    final now = DateTime.now();
    final normalizedHistory = _normalizeForMatch(
      snapshot.bookings
          .map((booking) => '${booking.title} ${booking.branchName ?? ''}')
          .join(' '),
    );

    final scored = <_ScoredClass>[];
    for (final fitnessClass in snapshot.classes) {
      if (!_isRecommendableClass(fitnessClass, preferToday)) {
        continue;
      }

      var score = 0;
      final searchable = _normalizeForMatch(_classSearchableText(fitnessClass));
      score += _classCatalogMatchScore(
        fitnessClass,
        snapshot.categories,
        query,
      );
      if (queryTerms.any((term) => searchable.contains(term))) {
        score += 5;
      }
      if (snapshot.categories.any((category) {
        final categoryName = _normalizeForMatch(category.name);
        return categoryName.isNotEmpty &&
            query.contains(categoryName) &&
            _normalizeForMatch(
              fitnessClass.categoryName,
            ).contains(categoryName);
      })) {
        score += 12;
      }
      if (_goalMatchesClass(snapshot.profile?.fitnessGoal, fitnessClass)) {
        score += 3;
      }
      if (preferredEvening && fitnessClass.startTime.toLocal().hour >= 17) {
        score += 3;
      }
      if (normalizedHistory.contains(
            _normalizeForMatch(fitnessClass.branchName),
          ) ||
          normalizedHistory.contains(
            _normalizeForMatch(fitnessClass.categoryName),
          )) {
        score += 1;
      }
      if (fitnessClass.startTime.isAfter(now)) {
        score += 1;
      }

      if (score > 0 || _isBroadGymOrClassQuery(query)) {
        scored.add(
          _ScoredClass(
            fitnessClass,
            score,
            _classReason(fitnessClass, userText, snapshot.profile),
          ),
        );
      }
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.value.startTime.compareTo(b.value.startTime);
    });
    return scored;
  }

  List<_ScoredGym> _rankGyms(
    _AiCatalogSnapshot snapshot,
    String userText,
    List<RecommendedClass> selectedClasses,
  ) {
    final query = _normalizeForMatch(userText);
    final terms = _queryTerms(userText, snapshot.categories);
    final classBranchIds = selectedClasses
        .map((item) => item.source?.branchId)
        .whereType<String>()
        .toSet();
    final scored = <_ScoredGym>[];

    for (final gym in snapshot.gyms) {
      if (!_isActiveGym(gym)) {
        continue;
      }

      var score = 0;
      final branches = snapshot.branches
          .where((branch) => branch.gymId.toLowerCase() == gym.id.toLowerCase())
          .toList();
      final searchable = _normalizeForMatch(
        [
          gym.name,
          gym.description ?? '',
          gym.branchName ?? '',
          gym.branchAddress ?? '',
          ...branches.map(
            (branch) => '${branch.name} ${branch.displayAddress}',
          ),
        ].join(' '),
      );
      if (terms.any((term) => searchable.contains(term))) {
        score += 4;
      }
      if (classBranchIds.any(
        (branchId) => branches.any(
          (branch) => branch.id.toLowerCase() == branchId.toLowerCase(),
        ),
      )) {
        score += 6;
      }
      if (query.contains('gym') || query.contains('phong tap')) {
        score += 3;
      }
      if (gym.ratingAverage > 0) {
        score += 1;
      }

      if (score > 0 || _isBroadGymOrClassQuery(query)) {
        scored.add(
          _ScoredGym(
            _gymWithResolvedBranch(gym, branches),
            score,
            branches.isNotEmpty
                ? 'Có chi nhánh ${branches.first.name} trong dữ liệu FlexFit.'
                : 'Có trong danh sách phòng tập FlexFit.',
          ),
        );
      }
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.value.ratingAverage.compareTo(a.value.ratingAverage);
    });
    return scored;
  }

  _GymSelection _selectGymsForRecommendation(
    _AiCatalogSnapshot snapshot, {
    required String userText,
    required List<_ScoredGym> rankedGyms,
  }) {
    final selected = rankedGyms.take(3).toList();
    if (selected.isNotEmpty) {
      return _GymSelection(scoredGyms: selected, fallbackUsed: false);
    }

    if (!_isGeneralWorkoutOrGymQuery(userText) || snapshot.gyms.isEmpty) {
      return const _GymSelection(scoredGyms: [], fallbackUsed: false);
    }

    final fallbackGyms = _candidateGymsForRecommendation(snapshot).take(3);
    return _GymSelection(
      scoredGyms: fallbackGyms.map((gym) {
        final branches = _branchesForGym(snapshot, gym);
        return _ScoredGym(
          _gymWithResolvedBranch(gym, branches),
          0,
          'Có trong danh sách phòng tập FlexFit.',
        );
      }).toList(),
      fallbackUsed: true,
    );
  }

  List<Gym> _candidateGymsForRecommendation(_AiCatalogSnapshot snapshot) {
    final activeGyms = snapshot.gyms.where(_isActiveGym).toList();
    final activeIds = activeGyms.map((gym) => gym.id).toSet();
    final fallbackGyms = snapshot.gyms
        .where((gym) => !activeIds.contains(gym.id))
        .where((gym) => !_hasBlockedGymStatus(gym))
        .toList();
    return [...activeGyms, ...fallbackGyms];
  }

  List<Branch> _branchesForGym(_AiCatalogSnapshot snapshot, Gym gym) {
    return snapshot.branches
        .where((branch) => branch.gymId.toLowerCase() == gym.id.toLowerCase())
        .toList();
  }

  bool _isGeneralWorkoutOrGymQuery(String userText) {
    final query = _normalizeForMatch(userText);
    return _isBroadGymOrClassQuery(query) ||
        _containsAny(query, [
          'hom nay nen tap gi',
          'toi nen tap gi',
          'goi y hom nay',
          'goi y lop hoc phu hop',
          'phong gym phu hop voi toi',
          'gym',
          'phong tap',
          'phong gym',
          'tap gi',
          'tap o dau',
          'nen tap',
          'goi y',
        ]);
  }

  bool _hasBlockedGymStatus(Gym gym) {
    final status = _normalizeForMatch(gym.status);
    if (status.isEmpty || status == 'null') {
      return false;
    }
    final tokens = status.split(' ').where((token) => token.isNotEmpty);
    return tokens.any(
      (token) =>
          token == 'inactive' ||
          token == 'closed' ||
          token == 'disabled' ||
          token == 'deleted' ||
          token == 'blocked' ||
          token == 'cancelled' ||
          token == 'canceled' ||
          token == 'expired',
    );
  }

  String? _excludedGymReason(Gym gym) {
    if (_hasBlockedGymStatus(gym)) {
      return 'blocked status "${gym.status}"';
    }
    return null;
  }

  void _debugLogGymSelection({
    required _AiCatalogSnapshot snapshot,
    required int activeGymCount,
    required List<Gym> selectedGyms,
    required int classCount,
    required bool fallbackUsed,
  }) {
    if (!kDebugMode) {
      return;
    }
    final excludedReasons = <String>[];
    for (final gym in snapshot.gyms) {
      final reason = _excludedGymReason(gym);
      if (reason != null) {
        excludedReasons.add('${gym.id}:${gym.name}:$reason');
      }
    }
    debugPrint('[AI Coach] rawGymsFromCatalog=${snapshot.gyms.length}');
    debugPrint('[AI Coach] gymsAfterActiveFilter=$activeGymCount');
    debugPrint(
      '[AI Coach] selectedGyms=${selectedGyms.map((gym) => gym.name).join(', ')}',
    );
    debugPrint('[AI Coach] classCount=$classCount');
    debugPrint('[AI Coach] gymFallbackUsed=$fallbackUsed');
    debugPrint(
      '[AI Coach] excludedGymReasons=${excludedReasons.isEmpty ? '[]' : excludedReasons.join('; ')}',
    );
  }

  int _classCatalogMatchScore(
    FitnessClass fitnessClass,
    List<Category> categories,
    String query,
  ) {
    var score = 0;
    final classCategory = _normalizeForMatch(fitnessClass.categoryName);
    final className = _normalizeForMatch(fitnessClass.name);
    final classDescription = _normalizeForMatch(fitnessClass.description ?? '');

    for (final category in categories) {
      final categoryName = _normalizeForMatch(category.name);
      final categoryDescription = _normalizeForMatch(
        category.description ?? '',
      );
      if (categoryName.isEmpty) {
        continue;
      }
      final sameCategory =
          category.id.toLowerCase() == fitnessClass.categoryId.toLowerCase() ||
          (classCategory.isNotEmpty &&
              (classCategory.contains(categoryName) ||
                  categoryName.contains(classCategory)));
      if (!sameCategory) {
        continue;
      }
      if (_containsPhrase(query, categoryName)) {
        score += 30;
      } else if (categoryDescription.isNotEmpty &&
          _containsAnyToken(query, categoryDescription)) {
        score += 8;
      }
    }

    if (classCategory.isNotEmpty && _containsPhrase(query, classCategory)) {
      score += 26;
    }
    if (className.isNotEmpty && _containsPhrase(query, className)) {
      score += 18;
    } else if (className.isNotEmpty && _containsAnyToken(query, className)) {
      score += 8;
    }
    if (classDescription.isNotEmpty &&
        _containsAnyToken(query, classDescription)) {
      score += 4;
    }
    return score;
  }

  bool _containsPhrase(String query, String phrase) {
    if (phrase.trim().length < 3) {
      return false;
    }
    return query.contains(phrase);
  }

  bool _containsAnyToken(String query, String text) {
    final ignored = {
      'tap',
      'lop',
      'gym',
      'phong',
      'phu',
      'hop',
      'voi',
      'toi',
      'cho',
      'the',
      'class',
    };
    final queryTokens = query
        .split(' ')
        .where((token) => token.length >= 3 && !ignored.contains(token))
        .toSet();
    if (queryTokens.isEmpty) {
      return false;
    }
    final textTokens = text.split(' ').toSet();
    return queryTokens.any(textTokens.contains);
  }

  bool _isBroadGymOrClassQuery(String query) {
    return _containsAny(query, [
      'phong gym',
      'phong tap',
      'gym phu hop',
      'lop phu hop',
      'lop tap',
      'tap o dau',
      'goi y lop',
      'goi y lich tap',
      // Additional broad patterns to catch generic class/gym queries
      'tim lop',
      'lop hoc',
      'lop phu',
      'co lop',
      'nen tap',
      'muon tap',
      'chon lop',
      'lich tap',
      'buoi tap',
      'nen vao phong',
      'muon vao gym',
    ]);
  }

  Gym _gymWithResolvedBranch(Gym gym, List<Branch> branches) {
    if ((gym.branchName?.trim().isNotEmpty ?? false) || branches.isEmpty) {
      return gym;
    }
    final branch = branches.first;
    return Gym(
      id: gym.id,
      name: gym.name,
      description: gym.description,
      thumbnailUrl: gym.thumbnailUrl ?? branch.thumbnailUrl,
      phoneNumber: gym.phoneNumber,
      email: gym.email,
      branchId: branch.id,
      branchName: branch.name,
      branchAddress: branch.displayAddress,
      status: gym.status,
      ratingAverage: gym.ratingAverage,
      totalReviews: gym.totalReviews,
    );
  }

  String _catalogPrompt(
    String userText,
    _AiCatalogSnapshot snapshot,
    AiCoachRecommendation recommendation,
  ) {
    final classes = recommendation.recommendedClasses
        .map(
          (item) =>
              '- ${item.id}: ${item.title}, ${item.categoryName}, ${item.branchName}, ${_formatOptionalDateTime(item.startTime)}',
        )
        .join('\n');
    final gyms = recommendation.recommendedGyms
        .map(
          (item) =>
              '- ${item.id}: ${item.name}${item.branchName == null ? '' : ', ${item.branchName}'}${item.address == null ? '' : ', ${item.address}'}',
        )
        .join('\n');
    final profile = snapshot.profile;

    return '''
Bạn là FlexFit AI Coach.

Trả lời bằng tiếng Việt, plain text, ngắn gọn cho mobile.
Không dùng Markdown: không #, *, **, _, ---, bảng hoặc code block.
Chỉ được nhắc lớp/phòng tập có trong danh sách ứng viên bên dưới.
Không tự tạo tên lớp, phòng tập, thời gian, địa chỉ hoặc giá.
Nếu danh sách ứng viên trống, nói đúng ý: Hiện tại FlexFit chưa có lựa chọn phù hợp trong dữ liệu hiện có.
Tối đa 3 lớp và 3 phòng tập. Chỉ hiện section có dữ liệu.
Khong noi khong co phong tap phu hop khi ung vien phong tap that khong trong.

User profile:
- Mục tiêu: ${profile?.fitnessGoal ?? 'Chưa cập nhật'}
- Mức hoạt động: ${profile?.activityLevel ?? 'Chưa cập nhật'}
- Giờ tập ưa thích: ${profile?.preferredWorkoutTime ?? 'Chưa cập nhật'}

Câu hỏi: $userText

Ứng viên lớp thật:
${classes.isEmpty ? '- Không có lớp phù hợp.' : classes}

Ứng viên phòng tập thật:
${gyms.isEmpty ? '- Không có phòng tập phù hợp.' : gyms}

Format:
Gợi ý hôm nay
• nội dung ngắn

Lớp phù hợp
• tên lớp — chi nhánh/giờ nếu có

Phòng tập phù hợp
• tên phòng — chi nhánh nếu có

Lý do
• lý do ngắn
''';
  }

  String _fallbackRecommendationText(AiCoachRecommendation recommendation) {
    if (!recommendation.hasCatalogData) {
      return 'Hiện tại FlexFit chưa có lớp hoặc phòng tập phù hợp trong dữ liệu hiện có.';
    }

    final lines = <String>[];
    if (recommendation.workoutTips.isNotEmpty) {
      lines.add('Gợi ý hôm nay');
      lines.addAll(recommendation.workoutTips.take(2).map((tip) => '• $tip'));
    }
    if (recommendation.recommendedClasses.isNotEmpty) {
      lines.add('');
      lines.add('Lớp phù hợp');
      lines.addAll(
        recommendation.recommendedClasses.take(3).map((item) {
          final time = _formatOptionalDateTime(item.startTime);
          final suffix = [
            item.branchName,
            time,
          ].where((part) => part.trim().isNotEmpty).join(', ');
          return '• ${item.title}${suffix.isEmpty ? '' : ' — $suffix'}';
        }),
      );
    }
    if (recommendation.recommendedGyms.isNotEmpty) {
      lines.add('');
      lines.add('Phòng tập phù hợp');
      lines.addAll(
        recommendation.recommendedGyms.take(3).map((item) {
          final suffix = item.branchName ?? item.address ?? '';
          return '• ${item.name}${suffix.isEmpty ? '' : ' — $suffix'}';
        }),
      );
    }
    if (recommendation.reason?.trim().isNotEmpty == true) {
      lines.add('');
      lines.add('Lý do');
      lines.add('• ${recommendation.reason}');
    }
    if (lines.isEmpty) {
      return 'Hiện tại FlexFit chưa có lựa chọn phù hợp trong dữ liệu hiện có.';
    }
    return AiTextFormatter.cleanAiText(lines.join('\n'));
  }

  Future<void> _sendCreditOverview() async {
    try {
      final credit = await _creditRepository.getMyCredit();
      _addLocalAiMessage(
        'Hiện bạn có ${credit.balance} credits. PT sẽ ưu tiên gợi ý lớp hoặc phòng tập phù hợp với số credits hiện có.',
        title: 'Credits của bạn',
      );
    } catch (_) {
      _addLocalAiMessage(
        'Mình chưa lấy được số credits lúc này. Bạn vẫn có thể hỏi PT về lịch tập, lớp học hoặc phòng gym phù hợp.',
        title: 'Credits của bạn',
      );
    }
  }

  Future<void> _sendScheduleOverview() async {
    try {
      final booking = await _nextUpcomingBooking();
      if (booking == null) {
        _addLocalAiMessage(
          'Bạn chưa có lịch tập sắp tới trong FlexFit.',
          title: 'Lịch tập tiếp theo',
        );
        return;
      }

      final location = [
        booking.branchName,
        booking.gymName,
      ].whereType<String>().where((text) => text.trim().isNotEmpty).join(' - ');
      _addLocalAiMessage(
        '${booking.title}\n${location.isEmpty ? '' : '$location\n'}${_formatDate(booking.startTime)} • ${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
        title: 'Lịch tập tiếp theo',
      );
    } catch (_) {
      _addLocalAiMessage(
        'Mình chưa lấy được lịch tập lúc này. Bạn có thể thử lại sau.',
        title: 'Lịch tập tiếp theo',
      );
    }
  }

  int _addLocalAiMessage(String text, {String? title}) {
    final index = _messages.length;
    addMessage(AiChatMessageModel(role: 'model', content: text));
    _parsedMessages[index] = AiResponseParser.parse(text);
    if (title != null) {
      _responseTitles[index] = title;
    }
    notifyListeners();
    return index;
  }

  Future<void> _addAiResponse(
    String text, {
    required String userText,
    bool preferToday = false,
    String? title,
  }) async {
    final msgIndex = _messages.length;
    addMessage(AiChatMessageModel(role: 'model', content: text));

    final parsed = AiResponseParser.parse(text);
    _parsedMessages[msgIndex] = parsed;
    if (title != null) {
      _responseTitles[msgIndex] = title;
    }
    await _attachClassRecommendations(
      msgIndex,
      parsed: parsed,
      userText: userText,
      responseText: AiTextFormatter.sanitizeAiResponse(text),
      preferToday: preferToday,
    );
  }

  Future<void> _attachClassRecommendations(
    int msgIndex, {
    required ParsedAiResponse parsed,
    required String userText,
    required String responseText,
    required bool preferToday,
  }) async {
    try {
      final keywords = await _recommendationKeywords(
        parsed: parsed,
        userText: userText,
        responseText: responseText,
      );
      final todayOnly = preferToday || _isTodayOnlyPrompt(userText);
      debugPrint('AI RECOMMENDATION TODAY ONLY: $todayOnly');

      if (keywords.isEmpty && !todayOnly) {
        await _attachGymRecommendations(msgIndex, userText: userText);
        return;
      }

      final allClasses = await _catalogRepository.getClasses();
      debugPrint('AI RECOMMENDATION RAW COUNT: ${allClasses.length}');
      final candidates = allClasses
          .where(
            (fitnessClass) => _isRecommendableClass(fitnessClass, todayOnly),
          )
          .toList();
      debugPrint('AI RECOMMENDATION FILTERED COUNT: ${candidates.length}');

      final matchedClasses = candidates
          .where((fitnessClass) {
            if (keywords.isEmpty) {
              return true;
            }
            final searchable = [
              fitnessClass.name,
              fitnessClass.branchName,
              fitnessClass.categoryName,
              fitnessClass.description ?? '',
              fitnessClass.difficultyLevel ?? '',
            ].join(' ').toLowerCase();
            return keywords.any(searchable.contains);
          })
          .take(3)
          .toList();

      if (matchedClasses.isNotEmpty) {
        _recommendedClasses[msgIndex] = matchedClasses;
      } else if (todayOnly) {
        _recommendationNotes[msgIndex] = _fallbackPlanForPrompt(userText);
      } else if (keywords.isNotEmpty) {
        _recommendationNotes[msgIndex] = _fallbackPlanForPrompt(userText);
      }
      debugPrint('AI RECOMMENDED CLASS COUNT: ${matchedClasses.length}');
      debugPrint('AI RESPONSE HAS CLASS CARDS: ${matchedClasses.isNotEmpty}');
      notifyListeners();
    } catch (e) {
      debugPrint('AI recommendation fetch ignored: $e');
    }

    await _attachGymRecommendations(msgIndex, userText: userText);
  }

  Future<void> _attachGymRecommendations(
    int msgIndex, {
    required String userText,
    bool force = false,
  }) async {
    // Use normalized form so Vietnamese diacritics don't block matching
    final normalizedUser = _normalizeForMatch(userText);
    final wantsGym = _containsAny(normalizedUser, [
      'gym',
      'phong tap',
      'phong gym',
      'o dau',
      'tap o dau',
      'tap gi',
      'nen tap',
      'goi y',
    ]);
    if (!force && !wantsGym && !_isGeneralWorkoutOrGymQuery(userText)) {
      return;
    }

    try {
      final gyms = await _catalogRepository.getGyms();
      final snapshot = _AiCatalogSnapshot(
        gyms: gyms,
        branches: const [],
        classes: const [],
        categories: const [],
        bookings: const [],
        profile: null,
      );
      final selectedGyms = _candidateGymsForRecommendation(
        snapshot,
      ).take(3).toList();
      _debugLogGymSelection(
        snapshot: snapshot,
        activeGymCount: gyms.where(_isActiveGym).length,
        selectedGyms: selectedGyms,
        classCount: _recommendedClasses[msgIndex]?.length ?? 0,
        fallbackUsed:
            gyms.where(_isActiveGym).isEmpty && selectedGyms.isNotEmpty,
      );

      if (selectedGyms.isNotEmpty) {
        _recommendedGyms[msgIndex] = selectedGyms;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AI gym recommendation fetch ignored: $e');
    }
  }

  Future<List<String>> _recommendationKeywords({
    required ParsedAiResponse parsed,
    required String userText,
    required String responseText,
  }) async {
    final keywords = <String>{...parsed.recommendedClassKeywords};
    final lowerText = '$userText $responseText'.toLowerCase();

    if (_containsAny(lowerText, [
      'đau lưng',
      'đau vai',
      'đau gối',
      'mỏi',
      'phục hồi',
    ])) {
      keywords.addAll(['yoga', 'stretching', 'mobility', 'pilates']);
    }
    if (_containsAny(lowerText, ['giảm cân', 'fat', 'calo', 'cardio'])) {
      keywords.addAll(['hiit', 'cardio', 'zumba', 'cycling']);
    }
    if (_containsAny(lowerText, ['tăng cơ', 'body', 'strength', 'cơ'])) {
      keywords.addAll(['strength', 'core', 'gym']);
    }
    if (_containsAny(lowerText, ['yoga', 'giãn cơ', 'mobility'])) {
      keywords.addAll(['yoga', 'stretching', 'mobility']);
    }

    if (keywords.isEmpty) {
      final profileProvider = sl.isRegistered<GetProfileUseCase>()
          ? sl<GetProfileUseCase>()
          : null;
      if (profileProvider != null) {
        try {
          final profile = await profileProvider.call();
          final goal = profile.fitnessGoal?.toLowerCase() ?? '';
          if (_containsAny(goal, ['giảm cân', 'fat'])) {
            keywords.add('hiit');
          }
          if (_containsAny(goal, ['cơ', 'strength'])) {
            keywords.add('strength');
          }
          if (_containsAny(goal, ['dẻo', 'yoga'])) {
            keywords.add('yoga');
          }
        } catch (_) {}
      }
    }

    return keywords.toList();
  }

  AiCoachIntent _detectIntent(String text) {
    final value = text.toLowerCase();
    if (_isGreetingPrompt(value)) {
      return AiCoachIntent.greeting;
    }
    if (_isNutritionPrompt(value)) {
      return AiCoachIntent.nutritionUnsupported;
    }
    if (_containsAny(value, _outOfScopeKeywords)) {
      return AiCoachIntent.outOfScope;
    }
    if (_containsAny(value, _recoveryKeywords)) {
      return AiCoachIntent.painGuidance;
    }
    if (_containsAny(value, _todayWorkoutKeywords)) {
      return AiCoachIntent.todayWorkout;
    }
    if (_containsAny(value, _workoutPlanKeywords)) {
      return AiCoachIntent.workoutPlan;
    }
    if (_containsAny(value, _findClassKeywords)) {
      return AiCoachIntent.findClass;
    }
    if (_containsAny(value, _gymKeywords)) {
      return AiCoachIntent.gymRecommendation;
    }
    if (_containsAny(value, _scheduleKeywords)) {
      return AiCoachIntent.schedule;
    }
    if (_containsAny(value, _creditKeywords)) {
      return AiCoachIntent.credit;
    }
    if (_isUnclearShortText(value)) {
      return AiCoachIntent.unclearShortText;
    }
    if (_containsAny(value, _allowedKeywords)) {
      return AiCoachIntent.flexfitCoachChat;
    }

    return AiCoachIntent.flexfitCoachChat;
  }

  bool _isHealthSensitive(String text) {
    final value = text.toLowerCase();
    return _containsAny(value, [
      'đau lưng',
      'đau vai',
      'đau gối',
      'chấn thương',
      'đau',
      'mỏi',
    ]);
  }

  bool _shouldReplaceBackendResponse(String userText, String responseText) {
    final response = responseText.toLowerCase();
    return _isHealthSensitive(userText) &&
        response.contains('không tìm thấy thông tin');
  }

  GetProfileUseCase? get _profileUseCase {
    return sl.isRegistered<GetProfileUseCase>()
        ? sl<GetProfileUseCase>()
        : null;
  }

  String _coachPersonaMessage(String userText) {
    return 'You are FlexFit AI Coach, a personal trainer inside FlexFit. '
        'Answer only about workout planning, gym, classes, booking, recovery, credits and member fitness data. '
        'Use Vietnamese, practical PT tone, short and actionable. '
        'If out of scope, decline politely. Do not diagnose injuries or claim to be a doctor.\n\n'
        'User: $userText';
  }

  bool _isTodayOnlyPrompt(String text) {
    return _containsAny(text.toLowerCase(), [
      'hôm nay',
      'today',
      'tối nay',
      'sáng nay',
      'chiều nay',
      'lớp hôm nay',
      'bài tập hôm nay',
      'tập hôm nay',
    ]);
  }

  bool _isRecommendableClass(FitnessClass fitnessClass, bool todayOnly) {
    final now = DateTime.now();
    final start = fitnessClass.startTime.toLocal();
    final end = fitnessClass.endTime.toLocal();

    if (_hasBlockedClassStatus(fitnessClass.status)) {
      return false;
    }

    if (todayOnly) {
      return _isSameDate(start, now) && end.isAfter(now);
    }

    return end.isAfter(now);
  }

  bool _hasBlockedClassStatus(String status) {
    final value = status.toLowerCase().trim();
    if (value.isEmpty) {
      return false;
    }

    final normalized = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    final tokens = normalized.split(' ').where((token) => token.isNotEmpty);
    return tokens.any(
      (token) =>
          token == 'cancelled' ||
          token == 'canceled' ||
          token == 'completed' ||
          token == 'finished' ||
          token == 'expired' ||
          token == 'past' ||
          token == 'closed' ||
          token == 'inactive',
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _fallbackPlanForPrompt(String text) {
    final value = text.toLowerCase();
    if (_containsAny(value, _recoveryKeywords) ||
        _containsAny(value, ['yoga', 'stretching', 'giãn cơ'])) {
      final safety = _isHealthSensitive(value)
          ? 'Nếu bạn đau nhiều, đau kéo dài hoặc có chấn thương, hãy nghỉ ngơi và hỏi ý kiến bác sĩ hoặc huấn luyện viên trước khi tập.\n\n'
          : '';
      return '$safety'
          'Hiện chưa có lớp phục hồi phù hợp hôm nay, nhưng bạn vẫn có thể tự tập nhẹ:\n'
          '• Giãn cơ cổ/vai/lưng nhẹ\n'
          '• Mobility 10 phút\n'
          '• Yoga nhẹ 15-20 phút\n'
          '• Đi bộ nhẹ nếu còn mỏi';
    }

    return _fallbackWorkoutPlanMessage;
  }

  String _classSearchableText(FitnessClass fitnessClass) {
    return [
      fitnessClass.name,
      fitnessClass.branchName,
      fitnessClass.categoryName,
      fitnessClass.description ?? '',
      fitnessClass.difficultyLevel ?? '',
    ].join(' ').toLowerCase();
  }

  Future<BookingModel?> _nextUpcomingBooking() async {
    final now = DateTime.now();
    final bookings = await _bookingRepository.getMyBookings();
    for (final booking in bookings) {
      if (booking.endTime.isAfter(now) &&
          !_hasBlockedClassStatus(booking.status)) {
        return booking;
      }
    }
    return null;
  }

  String _firstName(String fullName) {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return parts.isEmpty ? fullName : parts.first;
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  bool _isGreetingPrompt(String value) {
    final compact = value.trim();
    if (_greetingExactKeywords.contains(compact)) {
      return true;
    }
    return _containsAny(compact, [
      'chào',
      'coach ơi',
      'ai ơi',
      'pt ơi',
      'tư vấn cho tôi',
    ]);
  }

  bool _isUnclearShortText(String value) {
    final compact = value.trim();
    if (compact.isEmpty) {
      return false;
    }
    return compact.length <= 4 || RegExp(r'^\d+$').hasMatch(compact);
  }

  bool _isNutritionPrompt(String value) {
    return _containsAny(value, _nutritionKeywords);
  }

  bool _containsAny(String value, Iterable<String> keywords) {
    return keywords.any((keyword) => value.contains(keyword.toLowerCase()));
  }

  bool _needsCatalogContext(String text) {
    final value = _normalizeForMatch(text);
    return _containsAny(value, [
      'phong gym',
      'phong tap',
      'lop',
      'class',
      'tap gi',
      'tap o dau',
      'goi y lich tap',
      'lich tap',
      'boxing',
      'yoga',
      'cardio',
      'hiit',
      'pilates',
      'dance',
      'crossfit',
      'functional',
      'gym',
      'buoi toi',
    ]);
  }

  List<String> _queryTerms(String text, List<Category> categories) {
    final query = _normalizeForMatch(text);
    final terms = <String>{};

    for (final category in categories) {
      final name = _normalizeForMatch(category.name);
      if (name.isNotEmpty && query.contains(name)) {
        terms.add(name);
      }
    }

    final keywordMap = <String, List<String>>{
      'boxing': ['boxing', 'box'],
      'yoga': ['yoga'],
      'pilates': ['pilates'],
      'cardio': ['cardio', 'giam can', 'dot mo', 'calo'],
      'hiit': ['hiit', 'giam can', 'dot mo'],
      'dance': ['dance', 'zumba', 'nhay'],
      'strength': ['gym', 'tang co', 'suc manh', 'the hinh'],
      'core': ['core', 'bung'],
      'stretching': ['stretching', 'gian co', 'phuc hoi', 'mobility'],
      'functional': ['functional', 'chuc nang'],
      'crossfit': ['crossfit'],
    };

    for (final entry in keywordMap.entries) {
      if (entry.value.any(query.contains)) {
        terms.add(entry.key);
      }
    }

    return terms.toList();
  }

  bool _goalMatchesClass(String? goal, FitnessClass fitnessClass) {
    final normalizedGoal = _normalizeForMatch(goal ?? '');
    if (normalizedGoal.isEmpty) {
      return false;
    }
    final searchable = _normalizeForMatch(_classSearchableText(fitnessClass));
    if (_containsAny(normalizedGoal, ['giam can', 'dot mo'])) {
      return _containsAny(searchable, ['cardio', 'hiit', 'boxing', 'dance']);
    }
    if (_containsAny(normalizedGoal, ['tang co', 'suc manh'])) {
      return _containsAny(searchable, ['strength', 'gym', 'core']);
    }
    if (_containsAny(normalizedGoal, ['deo dai', 'linh hoat', 'phuc hoi'])) {
      return _containsAny(searchable, ['yoga', 'pilates', 'stretching']);
    }
    return false;
  }

  bool _isActiveGym(Gym gym) {
    final status = _normalizeForMatch(gym.status);
    if (status.isEmpty || status == 'null') {
      return true;
    }
    if (_hasBlockedGymStatus(gym)) {
      return false;
    }
    return _containsAny(status, ['active', 'open', 'available', 'hoat dong']);
  }

  List<String> _workoutTipsFor(String userText, Profile? profile) {
    final query = _normalizeForMatch('$userText ${profile?.fitnessGoal ?? ''}');
    if (_containsAny(query, ['boxing'])) {
      return const ['Tập Boxing vừa sức 45 phút để tăng sức bền.'];
    }
    if (_containsAny(query, ['giam can', 'cardio', 'hiit', 'dot mo'])) {
      return const ['Ưu tiên cardio hoặc HIIT vừa sức 30-45 phút.'];
    }
    if (_containsAny(query, ['tang co', 'strength', 'gym', 'suc manh'])) {
      return const ['Tập sức mạnh toàn thân, giữ kỹ thuật ổn định.'];
    }
    if (_containsAny(query, ['yoga', 'gian co', 'phuc hoi', 'pilates'])) {
      return const ['Chọn buổi nhẹ để phục hồi và tăng độ linh hoạt.'];
    }
    return const ['Bắt đầu bằng buổi tập vừa sức, có khởi động và giãn cơ.'];
  }

  String _personalizedReason(String userText, Profile? profile) {
    final parts = <String>[];
    final goal = profile?.fitnessGoal?.trim();
    final preferredTime = profile?.preferredWorkoutTime?.trim();
    if (goal != null && goal.isNotEmpty) {
      parts.add('mục tiêu $goal');
    }
    if (preferredTime != null && preferredTime.isNotEmpty) {
      parts.add('khung giờ $preferredTime');
    }
    if (parts.isEmpty) {
      return 'Các lựa chọn được lọc theo câu hỏi của bạn và dữ liệu hiện có trong FlexFit.';
    }
    return 'Các lựa chọn này phù hợp với ${parts.join(' và ')} của bạn.';
  }

  String _classReason(
    FitnessClass fitnessClass,
    String userText,
    Profile? profile,
  ) {
    if (_goalMatchesClass(profile?.fitnessGoal, fitnessClass)) {
      return 'Phù hợp với mục tiêu tập luyện của bạn.';
    }
    final terms = _queryTerms(userText, [
      Category(id: fitnessClass.categoryId, name: fitnessClass.categoryName),
    ]);
    if (terms.isNotEmpty) {
      return 'Khớp với nhu cầu bạn vừa hỏi.';
    }
    return 'Lớp còn lịch sắp diễn ra trong FlexFit.';
  }

  String _formatOptionalDateTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  bool _looksLikeAiError(String text) {
    final value = _normalizeForMatch(text);
    return _containsAny(value, [
      'loi ket noi',
      'cau hinh api',
      'khong the ket noi',
      'khong the phan tich',
      'gemini api',
      'api key',
    ]);
  }

  bool _containsNoGymFallback(String text) {
    final value = _normalizeForMatch(text);
    return _containsAny(value, [
      'khong co phong tap phu hop',
      'chua co phong tap phu hop',
      'khong co lua chon phu hop',
      'chua co lua chon phu hop',
    ]);
  }
}

class _AiCatalogSnapshot {
  _AiCatalogSnapshot({
    required this.gyms,
    required this.branches,
    required this.classes,
    required this.categories,
    required this.bookings,
    required this.profile,
  }) : branchById = {for (final branch in branches) branch.id: branch};

  final List<Gym> gyms;
  final List<Branch> branches;
  final List<FitnessClass> classes;
  final List<Category> categories;
  final List<BookingModel> bookings;
  final Profile? profile;
  final Map<String, Branch> branchById;
}

class _ScoredClass {
  const _ScoredClass(this.value, this.score, this.reason);

  final FitnessClass value;
  final int score;
  final String reason;
}

class _ScoredGym {
  const _ScoredGym(this.value, this.score, this.reason);

  final Gym value;
  final int score;
  final String reason;
}

class _GymSelection {
  const _GymSelection({required this.scoredGyms, required this.fallbackUsed});

  final List<_ScoredGym> scoredGyms;
  final bool fallbackUsed;
}

String _normalizeForMatch(String value) {
  var text = value.toLowerCase().trim();
  const replacements = {
    'à': 'a',
    'á': 'a',
    'ạ': 'a',
    'ả': 'a',
    'ã': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ậ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ặ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'è': 'e',
    'é': 'e',
    'ẹ': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ệ': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ì': 'i',
    'í': 'i',
    'ị': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ò': 'o',
    'ó': 'o',
    'ọ': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ộ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ợ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ù': 'u',
    'ú': 'u',
    'ụ': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ự': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ỳ': 'y',
    'ý': 'y',
    'ỵ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'đ': 'd',
  };
  for (final entry in replacements.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }
  return text.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

const _outOfScopeMessage =
    'Mình là FlexFit AI Coach, nên mình chỉ hỗ trợ về tập luyện, phòng gym, lớp học, lịch tập và thông tin trong FlexFit.';

const _healthGuidanceMessage =
    'Nếu bạn đau nhiều, đau kéo dài hoặc có chấn thương, hãy nghỉ ngơi và hỏi ý kiến bác sĩ hoặc huấn luyện viên trước khi tập.\n\n'
    'Nếu chỉ đau nhẹ hoặc mỏi cơ, bạn có thể cân nhắc đi bộ nhẹ, mobility, giãn cơ nhẹ hoặc yoga nhẹ. Nếu đau lưng, nên tránh squat nặng, deadlift hoặc leg press. Nếu đau gối/vai, tránh bài ép khớp và dừng lại nếu đau tăng.\n\n'
    'PT sẽ ưu tiên các lớp phục hồi, yoga hoặc stretching còn sắp diễn ra trong FlexFit nếu có.';

const _nutritionUnsupportedMessage =
    'Hiện FlexFit chưa hỗ trợ dữ liệu dinh dưỡng. Mình có thể giúp bạn lên lịch tập, tìm lớp học, chọn phòng gym hoặc phục hồi cơ bắp.';

const _unknownFlexFitMessage =
    'Mình là FlexFit AI Coach — PT ảo của bạn. Bạn có thể hỏi mình: hôm nay nên tập gì, có lớp nào phù hợp, nên tập phòng gym nào, hoặc lịch tập tiếp theo của bạn.';

const _fallbackWorkoutPlanMessage =
    'Hiện chưa có lớp phù hợp hôm nay, nhưng bạn có thể tự tập:\n'
    '• Khởi động 5-10 phút\n'
    '• Cardio nhẹ 15-20 phút\n'
    '• Strength toàn thân vừa sức 20 phút\n'
    '• Giãn cơ 5 phút';

const _greetingExactKeywords = [
  'chao',
  'chaof',
  'hello',
  'hi',
  'alo',
  'hey',
  'ê',
];

const _todayWorkoutKeywords = [
  'hôm nay nên tập gì',
  'hom nay nen tap gi',
  'tôi nên tập gì',
  'toi nen tap gi',
  'nên tập gì',
  'nen tap gi',
  'gợi ý bài tập hôm nay',
  'bài tập hôm nay',
  'bai tap hom nay',
  'lịch tập hôm nay',
  'gợi ý lịch tập',
];

const _workoutPlanKeywords = [
  'muốn giảm cân',
  'giảm cân thì tập gì',
  'muốn tăng cơ',
  'tăng cơ thì tập gì',
  'mới tập lại',
  'nên tập sao',
  'kế hoạch tập',
  'lên lịch tập',
];

const _findClassKeywords = [
  'tìm lớp',
  'tim lop',
  'có lớp nào',
  'co lop nao',
  'có lớp',
  'co lop',
  'lop tap phu hop',
  'lop phu hop',
  'lop hoc',
  'lớp yoga',
  'lop yoga',
  'lớp stretching',
  'lop stretching',
  'lớp phù hợp',
  'nên học lớp nào',
  'lớp học phù hợp',
];

const _recoveryKeywords = [
  'phục hồi',
  'đau lưng',
  'đau vai',
  'đau gối',
  'mỏi',
  'chấn thương',
  'giãn cơ',
  'stretching',
];

const _gymKeywords = [
  'phòng gym',
  'phòng tập',
  'tập ở đâu',
  'nên tập phòng nào',
  'nên tập phòng gym nào',
];

const _nutritionKeywords = [
  'hôm nay ăn gì',
  'nên ăn gì',
  'ăn gì',
  'dinh dưỡng',
  'meal plan',
  'ăn sao để giảm cân',
  'giảm mỡ',
  'tăng cơ ăn gì',
];

const _scheduleKeywords = [
  'lịch tập',
  'lịch tiếp theo',
  'booking của tôi',
  'buổi tập sắp tới',
];

const _creditKeywords = ['credits', 'credit', 'còn bao nhiêu', 'số dư'];

const _allowedKeywords = [
  'tập',
  'gym',
  'phòng tập',
  'phòng gym',
  'lớp',
  'class',
  'yoga',
  'stretching',
  'pilates',
  'boxing',
  'cardio',
  'strength',
  'lịch',
  'booking',
  'đặt lịch',
  'credit',
  'membership',
  'gói',
  'hôm nay',
  'buổi tập',
  'bài tập',
  'giảm cân',
  'tăng cơ',
  'đau lưng',
  'đau vai',
  'đau gối',
  'đau',
  'mỏi',
  'phục hồi',
  'giãn cơ',
  'calo',
  'body',
  'workout',
  'fitness',
  'flexfit',
];

const _outOfScopeKeywords = [
  'nấu gì',
  'học gì',
  'học bài',
  'làm bài tập',
  'code',
  'lập trình',
  'tình yêu',
  'thời tiết',
  'tin tức',
  'phim',
  'nhạc',
  'game',
  'mua điện thoại',
  'chứng khoán',
  'crypto',
];
