import 'package:again/features/voice/data/unconfigured_voice_services.dart';
import 'package:again/features/voice/data/platform_voice_services.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/story/data/story_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Phase 30 truthful voice foundation', () {
    test(
      'production story audio defaults to unavailable and fails closed',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(storyAudioAvailabilityProvider), isFalse);
        await expectLater(
          container.read(storyAudioServiceProvider).playPhrase('Hello'),
          throwsA(isA<StoryAudioUnavailable>()),
        );
      },
    );
    test('all production voice capabilities default to unconfigured', () {
      const capabilities = VoiceCapabilities.unconfigured;
      expect(capabilities.microphoneRecording, VoiceAvailability.unconfigured);
      expect(capabilities.speechToText, VoiceAvailability.unconfigured);
      expect(capabilities.textToSpeech, VoiceAvailability.unconfigured);
      expect(
        capabilities.pronunciationAssessment,
        VoiceAvailability.unconfigured,
      );
      expect(capabilities.canRecordAndTranscribe, isFalse);
      expect(capabilities.canSpeakText, isFalse);
    });

    test(
      'permission is not requested or claimed at service construction',
      () async {
        const recorder = UnconfiguredVoiceRecorderService();
        expect(
          await recorder.getPermissionState(),
          MicrophonePermissionState.unsupported,
        );
      },
    );

    test('unconfigured recorder never reports recording state', () async {
      final session = await const UnconfiguredVoiceRecorderService()
          .startRecording(
            sessionId: 'voice-1',
            ownerId: 'guest:device-a',
            sourceContext: VoiceSourceContext.humaConversation,
          );
      expect(session.state, VoiceRecordingState.error);
      expect(session.failure, VoiceFailureKind.unconfigured);
      expect(session.temporaryRecordingReference, isNull);
      expect(session.durationMilliseconds, 0);
    });

    test('unconfigured STT returns no fake transcript or confidence', () async {
      final result = await const UnconfiguredSpeechToTextService().transcribe(
        const SpeechRecognitionRequest(
          requestId: 'request-1',
          sessionId: 'voice-1',
          recordingReference: 'temporary-reference',
          sourceLocale: 'tr-TR',
          targetLearningLanguage: 'en-US',
        ),
      );
      expect(result.isSuccess, isFalse);
      expect(result.failure, VoiceFailureKind.unconfigured);
      expect(result.transcript, isNull);
      expect(result.confidence, isNull);
    });

    test('live and future recorded recognition modes stay distinct', () async {
      const live = SpeechRecognitionRequest(
        requestId: 'live-1',
        sessionId: 'session-1',
        mode: SpeechRecognitionMode.liveShortUtterance,
        sourceLocale: 'tr-TR',
        targetLearningLanguage: 'en-US',
      );
      const recorded = SpeechRecognitionRequest(
        requestId: 'file-1',
        sessionId: 'session-1',
        recordingReference: 'temporary.m4a',
        sourceLocale: 'tr-TR',
        targetLearningLanguage: 'en-US',
      );

      expect(live.recordingReference, isNull);
      expect(live.mode, SpeechRecognitionMode.liveShortUtterance);
      expect(recorded.mode, SpeechRecognitionMode.recordedAudioFuture);
      final result = await PlatformSpeechToTextService().transcribe(recorded);
      expect(result.failure, VoiceFailureKind.unconfigured);
      expect(result.transcript, isNull);
    });

    test('unconfigured TTS and pronunciation cannot fake success', () async {
      await expectLater(
        const UnconfiguredTextToSpeechService().speak(
          const TextToSpeechRequest(
            text: 'Hello',
            locale: 'en-US',
            speed: EducationalSpeechSpeed.normal,
            purpose: TextToSpeechPurpose.vocabularyPronunciation,
          ),
        ),
        throwsA(isA<VoiceServiceUnavailable>()),
      );
      expect(
        const UnconfiguredPronunciationAssessmentService().availability,
        VoiceAvailability.unconfigured,
      );
    });

    test('recording session keeps owner and temporary audio separate', () {
      final session = VoiceRecordingSession(
        sessionId: 'voice-1',
        ownerId: 'user:user-a',
        state: VoiceRecordingState.completed,
        sourceContext: VoiceSourceContext.storySpeaking,
        startedAt: DateTime.utc(2026),
        endedAt: DateTime.utc(2026).add(const Duration(seconds: 12)),
        durationMilliseconds: 12000,
        temporaryRecordingReference: 'temporary-only',
      );
      expect(session.ownerId, 'user:user-a');
      expect(session.durationMilliseconds, 12000);
      expect(session.temporaryRecordingReference, 'temporary-only');
    });
  });
}
