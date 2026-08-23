import 'package:again/features/voice/application/voice_recognition_coordinator.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/voice/domain/voice_services.dart';
import 'package:again/features/voice/domain/voice_telemetry.dart';
import 'package:again/features/voice/domain/voice_transcript.dart';
import 'package:flutter_test/flutter_test.dart';

class _Stt implements SpeechToTextService {
  _Stt(this.result);
  final SpeechRecognitionResult result;
  int calls = 0;
  @override
  VoiceAvailability get availability => VoiceAvailability.available;
  @override
  Future<SpeechRecognitionResult> transcribe(
    SpeechRecognitionRequest request,
  ) async {
    calls++;
    return result;
  }
}

class _Telemetry implements VoiceTelemetrySink {
  final List<VoiceEvent> events = [];
  @override
  void record(VoiceEvent event) => events.add(event);
}

const _request = SpeechRecognitionRequest(
  requestId: 'request-1',
  sessionId: 'session-1',
  recordingReference: 'temporary-only',
  sourceLocale: 'tr-TR',
  targetLearningLanguage: 'en-US',
);

void main() {
  group('Phase 30 transcript confirmation', () {
    test('recognised text waits for explicit user confirmation', () async {
      final coordinator = VoiceRecognitionCoordinator(
        speechToText: _Stt(
          const SpeechRecognitionResult.success(transcript: 'It is sunny.'),
        ),
      );
      final review = await coordinator.recognise(_request);
      expect(review, isNotNull);
      expect(review!.state, VoiceTranscriptReviewState.awaitingConfirmation);
      expect(review.canSubmit, isFalse);
      expect(review.confirm().canSubmit, isTrue);
    });

    test('original and user-corrected transcripts remain distinct', () {
      final review = VoiceTranscriptReview.fromRecognition(
        requestId: 'r',
        sessionId: 's',
        transcript: 'It sunny',
      ).edit('It is sunny.').confirm();
      expect(review.originalTranscript, 'It sunny');
      expect(review.currentTranscript, 'It is sunny.');
      expect(review.wasEdited, isTrue);
      expect(review.canUseForFuturePronunciationAssessment, isFalse);
    });

    test('re-record choice cannot submit stale transcript', () {
      final review = VoiceTranscriptReview.fromRecognition(
        requestId: 'r',
        sessionId: 's',
        transcript: 'Hello',
      ).requestReRecord();
      expect(review.state, VoiceTranscriptReviewState.reRecord);
      expect(review.canSubmit, isFalse);
    });

    test('duplicate STT request is processed and logged once', () async {
      final stt = _Stt(
        const SpeechRecognitionResult.success(
          transcript: 'Hello',
          durationMilliseconds: 2100,
        ),
      );
      final telemetry = _Telemetry();
      final coordinator = VoiceRecognitionCoordinator(
        speechToText: stt,
        telemetry: telemetry,
      );
      await coordinator.recognise(_request);
      await coordinator.recognise(_request);
      expect(stt.calls, 1);
      expect(telemetry.events, hasLength(1));
      expect(telemetry.events.single.type, VoiceEventType.sttSucceeded);
    });

    test('empty transcript fails without fabricated confirmation', () async {
      final telemetry = _Telemetry();
      final review = await VoiceRecognitionCoordinator(
        speechToText: _Stt(
          const SpeechRecognitionResult.success(transcript: '   '),
        ),
        telemetry: telemetry,
      ).recognise(_request);
      expect(review, isNull);
      expect(telemetry.events.single.type, VoiceEventType.sttFailed);
      expect(telemetry.events.single.failureCode, 'emptyTranscript');
    });

    test('voice telemetry schema contains no audio or transcript fields', () {
      final event = VoiceEvent(
        type: VoiceEventType.recordingCompleted,
        sessionId: 's',
        occurredAt: DateTime.utc(2026),
        durationMilliseconds: 2500,
      );
      expect(event.toString().toLowerCase(), isNot(contains('transcript')));
      expect(event.toString().toLowerCase(), isNot(contains('audio')));
      expect(event.toString().toLowerCase(), isNot(contains('spoken')));
    });
  });
}
