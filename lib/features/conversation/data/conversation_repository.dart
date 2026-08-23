import '../domain/conversation_models.dart';

abstract interface class HumaConversationService {
  bool get isLocalDeterministic;
  bool get supportsVoice;
  Future<HumaSessionHandle> startSession(HumaSessionStartRequest request);
  Future<HumaConversationResponse> respond(HumaConversationRequest request);
  Future<HumaConversationResponse> requestExplanation(
    HumaConversationRequest request,
  );
  Future<HumaStructuredCorrection?> requestCorrection(String sentence);
  Future<void> endSession(String sessionId);
  Future<String?> correctSentence(String sentence);
}

/// Development-only scripted adapter. A secure backend can replace this
/// implementation without changing presentation or session state.
class LocalHumaConversationService implements HumaConversationService {
  final Set<String> _activeSessions = {};

  @override
  bool get isLocalDeterministic => true;

  @override
  bool get supportsVoice => false;

  @override
  Future<HumaSessionHandle> startSession(
    HumaSessionStartRequest request,
  ) async {
    if (request.sessionId.trim().isEmpty) {
      throw ArgumentError.value(request.sessionId, 'sessionId');
    }
    _activeSessions.add(request.sessionId);
    return HumaSessionHandle(
      sessionId: request.sessionId,
      interactionMode: 'localScripted',
      startedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<HumaConversationResponse> respond(
    HumaConversationRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (request.scenario != ConversationScenario.cafe) {
      return const HumaConversationResponse(
        assistantText: 'Let’s continue this scenario when its lesson is ready.',
        translation: 'Bu senaryonun dersi hazır olduğunda devam edelim.',
        suggestedReplies: [],
        safetyState: HumaSafetyState.safe,
      );
    }
    final turn =
        request.history
            .where((item) => item.author == ConversationAuthor.user)
            .length -
        1;
    return switch (turn) {
      0 => const HumaConversationResponse(
        assistantText: 'Of course. What size would you like?',
        translation: 'Elbette. Hangi boyu istersiniz?',
        suggestedReplies: ['A medium, please.', 'A small one, please.'],
        vocabularySuggestions: ['size', 'medium'],
        usefulExpressions: ['I’d like a coffee, please.'],
        safetyState: HumaSafetyState.safe,
      ),
      1 => const HumaConversationResponse(
        assistantText: 'Would you like milk with your coffee?',
        translation: 'Kahvenizle süt ister misiniz?',
        suggestedReplies: ['Yes, please.', 'No, thank you.'],
        vocabularySuggestions: ['with'],
        usefulExpressions: ['A medium, please.'],
        safetyState: HumaSafetyState.safe,
      ),
      _ => const HumaConversationResponse(
        assistantText:
            'Perfect. Your coffee will be ready soon. That will be four euros.',
        translation:
            'Harika. Kahveniz yakında hazır olacak. Dört avro tutuyor.',
        suggestedReplies: ['Thank you!', 'That’s all, thank you.'],
        vocabularySuggestions: ['ready', 'soon'],
        usefulExpressions: ['No, thank you.'],
        safetyState: HumaSafetyState.safe,
      ),
    };
  }

  @override
  Future<String?> correctSentence(String sentence) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final normal = sentence.trim().toLowerCase();
    if (normal == 'i want coffee please' || normal == 'i want a coffee') {
      return 'I’d like a coffee, please.';
    }
    if (normal == 'give me coffee') return 'Could I have a coffee, please?';
    if (sentence.trim().isEmpty) return null;
    return sentence.trim().endsWith('.')
        ? sentence.trim()
        : '${sentence.trim()}.';
  }

  @override
  Future<HumaStructuredCorrection?> requestCorrection(String sentence) async {
    final suggestion = await correctSentence(sentence);
    if (suggestion == null) return null;
    final original = sentence.trim();
    final unchanged = suggestion == original;
    return HumaStructuredCorrection(
      original: original,
      suggestion: suggestion,
      category: unchanged ? CorrectionKind.correct : CorrectionKind.moreNatural,
      shortExplanation: unchanged
          ? 'Bu cümle doğal ve anlaşılır.'
          : 'Bu seçenek günlük İngilizcede daha doğal duyulur.',
      severity: unchanged ? 0 : 1,
    );
  }

  @override
  Future<HumaConversationResponse> requestExplanation(
    HumaConversationRequest request,
  ) async {
    final response = await respond(request);
    return HumaConversationResponse(
      assistantText: response.assistantText,
      translation: response.translation,
      suggestedReplies: response.suggestedReplies,
      corrections: response.corrections,
      vocabularySuggestions: response.vocabularySuggestions,
      usefulExpressions: response.usefulExpressions,
      explanation:
          response.explanation ??
          'Bu ifade konuşmada nazik ve doğal bir seçimdir.',
      safetyState: response.safetyState,
      sessionMetadata: response.sessionMetadata,
    );
  }

  @override
  Future<void> endSession(String sessionId) async {
    _activeSessions.remove(sessionId);
  }
}

@Deprecated('Use HumaConversationService.')
typedef ConversationRepository = HumaConversationService;

@Deprecated('Use LocalHumaConversationService.')
typedef LocalConversationRepository = LocalHumaConversationService;
