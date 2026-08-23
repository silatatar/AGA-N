enum VoiceTranscriptReviewState { awaitingConfirmation, confirmed, reRecord }

class VoiceTranscriptReview {
  const VoiceTranscriptReview({
    required this.requestId,
    required this.sessionId,
    required this.originalTranscript,
    required this.currentTranscript,
    required this.state,
  });

  factory VoiceTranscriptReview.fromRecognition({
    required String requestId,
    required String sessionId,
    required String transcript,
  }) => VoiceTranscriptReview(
    requestId: requestId,
    sessionId: sessionId,
    originalTranscript: transcript,
    currentTranscript: transcript,
    state: VoiceTranscriptReviewState.awaitingConfirmation,
  );

  final String requestId;
  final String sessionId;
  final String originalTranscript;
  final String currentTranscript;
  final VoiceTranscriptReviewState state;

  bool get wasEdited => originalTranscript != currentTranscript;
  bool get canSubmit =>
      state == VoiceTranscriptReviewState.confirmed &&
      currentTranscript.trim().isNotEmpty;
  bool get canUseForFuturePronunciationAssessment => !wasEdited;

  VoiceTranscriptReview edit(String value) => VoiceTranscriptReview(
    requestId: requestId,
    sessionId: sessionId,
    originalTranscript: originalTranscript,
    currentTranscript: value,
    state: VoiceTranscriptReviewState.awaitingConfirmation,
  );

  VoiceTranscriptReview confirm() => VoiceTranscriptReview(
    requestId: requestId,
    sessionId: sessionId,
    originalTranscript: originalTranscript,
    currentTranscript: currentTranscript,
    state: VoiceTranscriptReviewState.confirmed,
  );

  VoiceTranscriptReview requestReRecord() => VoiceTranscriptReview(
    requestId: requestId,
    sessionId: sessionId,
    originalTranscript: originalTranscript,
    currentTranscript: currentTranscript,
    state: VoiceTranscriptReviewState.reRecord,
  );
}
