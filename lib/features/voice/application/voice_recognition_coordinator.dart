import '../domain/voice_models.dart';
import '../domain/voice_services.dart';
import '../domain/voice_telemetry.dart';
import '../domain/voice_transcript.dart';

class VoiceRecognitionCoordinator {
  VoiceRecognitionCoordinator({
    required this.speechToText,
    this.telemetry = const NoopVoiceTelemetrySink(),
  });

  final SpeechToTextService speechToText;
  final VoiceTelemetrySink telemetry;
  final Map<String, Future<VoiceTranscriptReview?>> _inFlight = {};
  final Map<String, VoiceTranscriptReview?> _completed = {};

  Future<VoiceTranscriptReview?> recognise(SpeechRecognitionRequest request) {
    if (_completed.containsKey(request.requestId)) {
      return Future.value(_completed[request.requestId]);
    }
    return _inFlight.putIfAbsent(request.requestId, () => _run(request));
  }

  Future<VoiceTranscriptReview?> _run(SpeechRecognitionRequest request) async {
    try {
      if (speechToText.availability != VoiceAvailability.available) {
        _recordFailure(request, speechToText.availability.name);
        _completed[request.requestId] = null;
        return null;
      }
      final result = await speechToText.transcribe(request);
      final transcript = result.transcript?.trim() ?? '';
      if (!result.isSuccess || transcript.isEmpty) {
        _recordFailure(
          request,
          result.failure?.name ?? VoiceFailureKind.emptyTranscript.name,
        );
        _completed[request.requestId] = null;
        return null;
      }
      final review = VoiceTranscriptReview.fromRecognition(
        requestId: request.requestId,
        sessionId: request.sessionId,
        transcript: transcript,
      );
      telemetry.record(
        VoiceEvent(
          type: VoiceEventType.sttSucceeded,
          sessionId: request.sessionId,
          requestId: request.requestId,
          occurredAt: DateTime.now().toUtc(),
          durationMilliseconds: result.durationMilliseconds,
        ),
      );
      _completed[request.requestId] = review;
      return review;
    } finally {
      _inFlight.remove(request.requestId);
    }
  }

  void _recordFailure(SpeechRecognitionRequest request, String failure) {
    telemetry.record(
      VoiceEvent(
        type: VoiceEventType.sttFailed,
        sessionId: request.sessionId,
        requestId: request.requestId,
        occurredAt: DateTime.now().toUtc(),
        failureCode: failure,
      ),
    );
  }
}
