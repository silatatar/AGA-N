import '../../conversation/data/conversation_repository.dart';
import '../../conversation/domain/conversation_models.dart';
import '../../conversation/domain/huma_ai_models.dart';
import '../domain/voice_transcript.dart';

class HumaVoicePipelineRequest {
  const HumaVoicePipelineRequest({
    required this.transcriptReview,
    required this.learnerLevel,
    required this.learnerType,
    required this.scenario,
    required this.history,
    required this.safetyProfile,
    this.learningGoals = const {},
    this.targetVocabulary = const [],
  });

  final VoiceTranscriptReview transcriptReview;
  final String learnerLevel;
  final String learnerType;
  final ConversationScenario scenario;
  final List<HumaConversationTurn> history;
  final HumaSafetyProfile safetyProfile;
  final Set<String> learningGoals;
  final List<String> targetVocabulary;
}

class HumaVoicePipelineResult {
  const HumaVoicePipelineResult({
    required this.response,
    required this.interactionMode,
    required this.submittedTranscript,
    required this.transcriptWasEdited,
  });

  final HumaConversationResponse response;
  final HumaInteractionMode interactionMode;
  final String submittedTranscript;
  final bool transcriptWasEdited;
}

class HumaVoicePipeline {
  const HumaVoicePipeline({required this.conversationService});
  final HumaConversationService conversationService;

  Future<HumaVoicePipelineResult> submit(
    HumaVoicePipelineRequest request,
  ) async {
    final review = request.transcriptReview;
    if (!review.canSubmit) {
      throw const TranscriptConfirmationRequired();
    }
    final response = await conversationService.respond(
      HumaConversationRequest(
        userMessage: review.currentTranscript,
        learnerLevel: request.learnerLevel,
        learnerType: request.learnerType,
        scenario: request.scenario,
        history: [
          ...request.history,
          HumaConversationTurn(
            author: ConversationAuthor.user,
            text: review.currentTranscript,
          ),
        ],
        safetyProfile: request.safetyProfile,
        learningGoals: request.learningGoals,
        targetVocabulary: request.targetVocabulary,
      ),
    );
    return HumaVoicePipelineResult(
      response: response,
      interactionMode: conversationService.isLocalDeterministic
          ? HumaInteractionMode.localScripted
          : HumaInteractionMode.remoteAi,
      submittedTranscript: review.currentTranscript,
      transcriptWasEdited: review.wasEdited,
    );
  }
}

class TranscriptConfirmationRequired implements Exception {
  const TranscriptConfirmationRequired();
}
