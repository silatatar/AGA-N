enum VoiceAvailability {
  available,
  unavailable,
  permissionRequired,
  permissionDenied,
  permanentlyDenied,
  unsupportedPlatform,
  unconfigured,
  temporarilyUnavailable,
}

class VoiceCapabilities {
  const VoiceCapabilities({
    required this.microphoneRecording,
    required this.speechToText,
    required this.textToSpeech,
    required this.pronunciationAssessment,
  });

  final VoiceAvailability microphoneRecording;
  final VoiceAvailability speechToText;
  final VoiceAvailability textToSpeech;
  final VoiceAvailability pronunciationAssessment;

  static const unconfigured = VoiceCapabilities(
    microphoneRecording: VoiceAvailability.unconfigured,
    speechToText: VoiceAvailability.unconfigured,
    textToSpeech: VoiceAvailability.unconfigured,
    pronunciationAssessment: VoiceAvailability.unconfigured,
  );

  bool get canRecordAndTranscribe =>
      microphoneRecording == VoiceAvailability.available &&
      speechToText == VoiceAvailability.available;
  bool get canSpeakText => textToSpeech == VoiceAvailability.available;
}

enum MicrophonePermissionState {
  unknown,
  requesting,
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unsupported,
}

enum VoiceRecordingState {
  idle,
  ready,
  recording,
  stopping,
  processing,
  completed,
  cancelled,
  error,
}

enum VoiceSourceContext {
  storySpeaking,
  humaConversation,
  vocabularyPractice,
  guidedPractice,
}

enum VoiceFailureKind {
  permissionDenied,
  permanentlyDenied,
  unsupported,
  unconfigured,
  timeout,
  providerUnavailable,
  emptyTranscript,
  interrupted,
  unknown,
}

class VoiceRecordingSession {
  const VoiceRecordingSession({
    required this.sessionId,
    required this.ownerId,
    required this.state,
    required this.sourceContext,
    this.startedAt,
    this.endedAt,
    this.durationMilliseconds = 0,
    this.temporaryRecordingReference,
    this.failure,
  });

  final String sessionId;
  final String ownerId;
  final VoiceRecordingState state;
  final VoiceSourceContext sourceContext;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationMilliseconds;
  final String? temporaryRecordingReference;
  final VoiceFailureKind? failure;
}

enum SpeechRecognitionMode { liveShortUtterance, recordedAudioFuture }

class SpeechRecognitionRequest {
  const SpeechRecognitionRequest({
    required this.requestId,
    required this.sessionId,
    this.mode = SpeechRecognitionMode.recordedAudioFuture,
    this.recordingReference,
    required this.sourceLocale,
    required this.targetLearningLanguage,
    this.expectedPhrase,
    this.onStarted,
  });

  final String requestId;
  final String sessionId;
  final SpeechRecognitionMode mode;
  final String? recordingReference;
  final String sourceLocale;
  final String targetLearningLanguage;
  final String? expectedPhrase;
  final void Function()? onStarted;
}

class SpeechRecognitionResult {
  const SpeechRecognitionResult.success({
    required this.transcript,
    this.alternatives = const [],
    this.confidence,
    this.detectedLocale,
    this.durationMilliseconds,
  }) : failure = null;

  const SpeechRecognitionResult.failure(this.failure)
    : transcript = null,
      alternatives = const [],
      confidence = null,
      detectedLocale = null,
      durationMilliseconds = null;

  final String? transcript;
  final List<String> alternatives;
  final double? confidence;
  final String? detectedLocale;
  final int? durationMilliseconds;
  final VoiceFailureKind? failure;
  bool get isSuccess => failure == null;
}

enum TextToSpeechPurpose {
  storyNarration,
  sentenceReplay,
  vocabularyPronunciation,
  humaResponse,
  exampleSentence,
}

enum EducationalSpeechSpeed { slow, normal }

class TextToSpeechRequest {
  const TextToSpeechRequest({
    required this.text,
    required this.locale,
    required this.speed,
    required this.purpose,
    this.voiceProfile,
  });

  final String text;
  final String locale;
  final EducationalSpeechSpeed speed;
  final TextToSpeechPurpose purpose;
  final String? voiceProfile;
}

enum AudioPlaybackState { idle, loading, playing, paused, completed, error }

class PronunciationAssessmentRequest {
  const PronunciationAssessmentRequest({
    required this.recordingReference,
    required this.expectedText,
    required this.locale,
  });

  final String recordingReference;
  final String expectedText;
  final String locale;
}
