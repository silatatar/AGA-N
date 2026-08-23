import '../domain/conversation_models.dart';
import '../domain/huma_ai_models.dart';

class HumaAiLearningContext {
  const HumaAiLearningContext({
    required this.learnerType,
    required this.englishLevel,
    required this.safetyProfile,
    required this.locale,
    this.activeLearningGoals = const {},
    this.relevantVocabulary = const [],
    this.recentTurns = const [],
    this.storyContext,
  });

  final String learnerType;
  final String englishLevel;
  final HumaSafetyProfile safetyProfile;
  final String locale;
  final Set<String> activeLearningGoals;
  final List<String> relevantVocabulary;
  final List<HumaConversationTurn> recentTurns;
  final String? storyContext;
}

/// Builds the minimal client payload. Authentication identity and the final
/// system prompt are intentionally absent and must be derived server-side.
class HumaAiRequestFactory {
  const HumaAiRequestFactory({this.policy = const HumaPolicyConfig()});
  final HumaPolicyConfig policy;

  HumaAiRequest create({
    required String requestId,
    required String sessionId,
    required String turnId,
    required ConversationScenario scenario,
    required String userMessage,
    required HumaResponseMode action,
    required HumaAiLearningContext context,
  }) => HumaAiRequest(
    requestId: requestId,
    sessionId: sessionId,
    turnId: turnId,
    learnerType: context.learnerType,
    englishLevel: context.englishLevel,
    scenario: scenario,
    userMessage: userMessage,
    recentContext: context.recentTurns,
    activeLearningGoals: context.activeLearningGoals,
    targetVocabulary: context.relevantVocabulary,
    storyContext: context.storyContext,
    requestedAction: action,
    safetyProfile: context.safetyProfile,
    locale: context.locale,
    policyVersion: policy.policyVersion,
    promptVersion: policy.promptVersion,
    responseSchemaVersion: policy.responseSchemaVersion,
    limits: policy,
  );
}
