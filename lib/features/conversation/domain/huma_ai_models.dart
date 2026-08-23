import 'conversation_models.dart';

enum HumaInteractionMode { productGuidance, localScripted, remoteAi }

enum HumaResponseMode {
  conversation,
  correction,
  explanation,
  simplify,
  translationHelp,
  storyHelp,
  vocabularyHelp,
  sessionSummary,
}

enum HumaAiAvailability { available, providerUnavailable, offline, rateLimited }

enum HumaSafetyEvent {
  safe,
  blocked,
  redirected,
  needsSupport,
  providerFailure,
}

enum HumaAiFailureKind {
  providerUnavailable,
  offline,
  timeout,
  rateLimited,
  malformedResponse,
  unsafeResponse,
  unknown,
}

enum HumaCorrectionCategory {
  correct,
  understandableButUnnatural,
  grammarIssue,
  vocabularyIssue,
  contextIssue,
  moreNaturalAlternative,
}

class HumaCorrection {
  const HumaCorrection({
    required this.category,
    required this.original,
    required this.suggestion,
    required this.shortExplanation,
    this.severity = 1,
  });

  final HumaCorrectionCategory category;
  final String original;
  final String suggestion;
  final String shortExplanation;
  final int severity;
}

class HumaPolicyConfig {
  const HumaPolicyConfig({
    this.policyVersion = 'huma-safety-v1',
    this.promptVersion = 'huma-personality-v1',
    this.responseSchemaVersion = 'huma-response-v1',
    this.maxRecentTurns = 8,
    this.maxTargetVocabulary = 8,
    this.maxUserMessageCharacters = 1200,
    this.maxAssistantCharacters = 1800,
  });

  final String policyVersion;
  final String promptVersion;
  final String responseSchemaVersion;
  final int maxRecentTurns;
  final int maxTargetVocabulary;
  final int maxUserMessageCharacters;
  final int maxAssistantCharacters;
}

class HumaAiRequest {
  HumaAiRequest({
    required this.requestId,
    required this.sessionId,
    required this.turnId,
    required this.learnerType,
    required this.englishLevel,
    required this.scenario,
    required this.userMessage,
    required this.requestedAction,
    required this.safetyProfile,
    required this.locale,
    required this.policyVersion,
    required this.promptVersion,
    this.responseSchemaVersion = 'huma-response-v1',
    List<HumaConversationTurn> recentContext = const [],
    Set<String> activeLearningGoals = const {},
    List<String> targetVocabulary = const [],
    this.storyContext,
    HumaPolicyConfig limits = const HumaPolicyConfig(),
  }) : recentContext = List.unmodifiable(
         recentContext.length <= limits.maxRecentTurns
             ? recentContext
             : recentContext.sublist(
                 recentContext.length - limits.maxRecentTurns,
               ),
       ),
       activeLearningGoals = Set.unmodifiable(activeLearningGoals),
       targetVocabulary = List.unmodifiable(
         targetVocabulary.take(limits.maxTargetVocabulary),
       ) {
    if (requestId.trim().isEmpty ||
        sessionId.trim().isEmpty ||
        turnId.trim().isEmpty) {
      throw ArgumentError(
        'Request, session and turn identifiers are required.',
      );
    }
    if (userMessage.trim().isEmpty ||
        userMessage.length > limits.maxUserMessageCharacters) {
      throw ArgumentError('User message is empty or exceeds the safe limit.');
    }
  }

  final String requestId;
  final String sessionId;
  final String turnId;
  final String learnerType;
  final String englishLevel;
  final ConversationScenario scenario;
  final String userMessage;
  final List<HumaConversationTurn> recentContext;
  final Set<String> activeLearningGoals;
  final List<String> targetVocabulary;
  final String? storyContext;
  final HumaResponseMode requestedAction;
  final HumaSafetyProfile safetyProfile;
  final String locale;
  final String policyVersion;
  final String promptVersion;
  final String responseSchemaVersion;
}

class HumaAiResponse {
  const HumaAiResponse({
    required this.requestId,
    required this.assistantText,
    required this.responseMode,
    required this.safetyEvent,
    this.responseSchemaVersion = 'huma-response-v1',
    this.suggestedReplies = const [],
    this.corrections = const [],
    this.vocabularySuggestions = const [],
    this.explanation,
    this.encouragement,
    this.sessionSummaryDelta,
  });

  final String requestId;
  final String assistantText;
  final List<String> suggestedReplies;
  final List<HumaCorrection> corrections;
  final List<String> vocabularySuggestions;
  final String? explanation;
  final String? encouragement;
  final String? sessionSummaryDelta;
  final HumaResponseMode responseMode;
  final HumaSafetyEvent safetyEvent;
  final String responseSchemaVersion;
}

class HumaAiPolicyContext {
  const HumaAiPolicyContext({
    required this.cefrLevel,
    required this.safetyProfile,
    required this.maxSentenceWords,
    required this.allowHighRiskAdvice,
    required this.allowOffPlatformContact,
  });

  final String cefrLevel;
  final HumaSafetyProfile safetyProfile;
  final int maxSentenceWords;
  final bool allowHighRiskAdvice;
  final bool allowOffPlatformContact;
}

abstract final class HumaAiPolicyAssembler {
  static HumaAiPolicyContext forLearner({
    required String cefrLevel,
    required HumaSafetyProfile safetyProfile,
  }) {
    final normalized = cefrLevel.trim().toUpperCase();
    final maxSentenceWords = switch (normalized) {
      'A1' => 9,
      'A2' => 13,
      'B1' => 18,
      'B2' => 24,
      _ => 28,
    };
    return HumaAiPolicyContext(
      cefrLevel: normalized,
      safetyProfile: safetyProfile,
      maxSentenceWords: maxSentenceWords,
      allowHighRiskAdvice: false,
      allowOffPlatformContact: false,
    );
  }
}

class HumaAiTurnRecord {
  const HumaAiTurnRecord({
    required this.turnId,
    required this.requestId,
    required this.userText,
    required this.assistantText,
    required this.createdAt,
    required this.safetyEvent,
  });

  final String turnId;
  final String requestId;
  final String userText;
  final String assistantText;
  final DateTime createdAt;
  final HumaSafetyEvent safetyEvent;
}

class HumaAiSession {
  const HumaAiSession({
    required this.sessionId,
    required this.ownerId,
    required this.learnerType,
    required this.scenario,
    required this.startedAt,
    required this.turns,
    required this.targetVocabulary,
    required this.policyVersion,
    required this.promptVersion,
    this.completed = false,
    this.summary,
  });

  final String sessionId;
  final String ownerId;
  final String learnerType;
  final ConversationScenario scenario;
  final DateTime startedAt;
  final List<HumaAiTurnRecord> turns;
  final List<String> targetVocabulary;
  final String policyVersion;
  final String promptVersion;
  final bool completed;
  final String? summary;

  HumaAiSession addTurn(HumaAiTurnRecord turn) => HumaAiSession(
    sessionId: sessionId,
    ownerId: ownerId,
    learnerType: learnerType,
    scenario: scenario,
    startedAt: startedAt,
    turns: List.unmodifiable([...turns, turn]),
    targetVocabulary: targetVocabulary,
    policyVersion: policyVersion,
    promptVersion: promptVersion,
    completed: completed,
    summary: summary,
  );
}

class HumaAiOrchestrationResult {
  const HumaAiOrchestrationResult.success(this.response)
    : failure = null,
      usedFallback = false;

  const HumaAiOrchestrationResult.fallback(this.failure)
    : response = null,
      usedFallback = true;

  final HumaAiResponse? response;
  final HumaAiFailureKind? failure;
  final bool usedFallback;
}
