import '../domain/voice_models.dart';
import '../domain/voice_services.dart';

class VoiceServiceUnavailable implements Exception {
  const VoiceServiceUnavailable(this.failure);
  final VoiceFailureKind failure;
}

class UnconfiguredVoiceRecorderService implements VoiceRecorderService {
  const UnconfiguredVoiceRecorderService();

  @override
  Future<MicrophonePermissionState> getPermissionState() async =>
      MicrophonePermissionState.unsupported;

  @override
  Future<MicrophonePermissionState> requestPermission() async =>
      MicrophonePermissionState.unsupported;

  @override
  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  }) async => VoiceRecordingSession(
    sessionId: sessionId,
    ownerId: ownerId,
    state: VoiceRecordingState.error,
    sourceContext: sourceContext,
    failure: VoiceFailureKind.unconfigured,
  );

  @override
  Future<VoiceRecordingSession> stopRecording() async =>
      throw const VoiceServiceUnavailable(VoiceFailureKind.unconfigured);

  @override
  Future<void> cancelRecording() async {}

  @override
  Future<void> dispose() async {}
}

class UnconfiguredSpeechToTextService implements SpeechToTextService {
  const UnconfiguredSpeechToTextService();

  @override
  VoiceAvailability get availability => VoiceAvailability.unconfigured;

  @override
  Future<SpeechRecognitionResult> transcribe(
    SpeechRecognitionRequest request,
  ) async =>
      const SpeechRecognitionResult.failure(VoiceFailureKind.unconfigured);
}

class UnconfiguredTextToSpeechService implements TextToSpeechService {
  const UnconfiguredTextToSpeechService();

  @override
  VoiceAvailability get availability => VoiceAvailability.unconfigured;

  @override
  Future<void> speak(TextToSpeechRequest request) async {
    throw const VoiceServiceUnavailable(VoiceFailureKind.unconfigured);
  }

  @override
  Future<void> stop() async {}
}

class UnconfiguredPronunciationAssessmentService
    implements PronunciationAssessmentService {
  const UnconfiguredPronunciationAssessmentService();

  @override
  VoiceAvailability get availability => VoiceAvailability.unconfigured;

  @override
  Future<void> assess(PronunciationAssessmentRequest request) async {
    throw const VoiceServiceUnavailable(VoiceFailureKind.unconfigured);
  }
}
