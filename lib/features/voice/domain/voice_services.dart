import 'voice_models.dart';

abstract interface class VoiceRecorderService {
  Future<MicrophonePermissionState> getPermissionState();
  Future<MicrophonePermissionState> requestPermission();
  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  });
  Future<VoiceRecordingSession> stopRecording();
  Future<void> cancelRecording();
  Future<void> dispose();
}

abstract interface class SpeechToTextService {
  VoiceAvailability get availability;
  Future<SpeechRecognitionResult> transcribe(SpeechRecognitionRequest request);
}

abstract interface class LiveSpeechToTextService
    implements SpeechToTextService {
  String? get selectedLocale;
  Future<VoiceAvailability> initialize({bool requestPermission = false});
  Future<void> stop();
  Future<void> cancel();
  Future<void> dispose();
}

abstract interface class TextToSpeechService {
  VoiceAvailability get availability;
  Future<void> speak(TextToSpeechRequest request);
  Future<void> stop();
}

abstract interface class AudioPlaybackService {
  AudioPlaybackState get state;
  Future<void> play(String audioReference);
  Future<void> pause();
  Future<void> stop();
}

abstract interface class PronunciationAssessmentService {
  VoiceAvailability get availability;
  Future<void> assess(PronunciationAssessmentRequest request);
}
