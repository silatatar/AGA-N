import 'dart:async';

import 'package:again/features/voice/application/voice_user_action_controller.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/voice/domain/voice_services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLiveSpeechService implements LiveSpeechToTextService {
  VoiceAvailability initialization = VoiceAvailability.available;
  final Completer<SpeechRecognitionResult> result = Completer();
  int initializeCalls = 0;
  int recognitionCalls = 0;
  int cancelCalls = 0;

  @override
  VoiceAvailability get availability => initialization;
  @override
  String? get selectedLocale => 'en-US';

  @override
  Future<VoiceAvailability> initialize({bool requestPermission = false}) async {
    initializeCalls++;
    return initialization;
  }

  @override
  Future<SpeechRecognitionResult> transcribe(SpeechRecognitionRequest request) {
    recognitionCalls++;
    request.onStarted?.call();
    return result.future;
  }

  @override
  Future<void> cancel() async => cancelCalls++;
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  test(
    'explicit tap requests capability and waits for real start callback',
    () async {
      final service = FakeLiveSpeechService();
      final controller = VoiceUserActionController(speechToText: service);
      addTearDown(controller.dispose);

      final future = controller.startLiveRecognition();
      expect(controller.state, VoiceUserActionState.requestingPermission);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, VoiceUserActionState.listening);
      expect(service.initializeCalls, 1);
      expect(service.recognitionCalls, 1);

      service.result.complete(
        const SpeechRecognitionResult.success(transcript: 'It is sunny today.'),
      );
      final review = await future;
      expect(controller.state, VoiceUserActionState.transcriptReady);
      expect(review?.originalTranscript, 'It is sunny today.');
    },
  );

  test('double microphone tap cannot start duplicate recognition', () async {
    final service = FakeLiveSpeechService();
    final controller = VoiceUserActionController(speechToText: service);
    addTearDown(controller.dispose);

    final first = controller.startLiveRecognition();
    await Future<void>.delayed(Duration.zero);
    final second = await controller.startLiveRecognition();
    expect(second, isNull);
    expect(service.recognitionCalls, 1);
    service.result.complete(
      const SpeechRecognitionResult.success(transcript: 'Hello'),
    );
    await first;
  });

  test('unavailable recognition remains fail closed', () async {
    final service = FakeLiveSpeechService()
      ..initialization = VoiceAvailability.permissionDenied;
    final controller = VoiceUserActionController(speechToText: service);
    addTearDown(controller.dispose);

    expect(await controller.startLiveRecognition(), isNull);
    expect(controller.state, VoiceUserActionState.unavailable);
    expect(service.recognitionCalls, 0);
  });

  test('cancel stops live microphone session and resets state', () async {
    final service = FakeLiveSpeechService();
    final controller = VoiceUserActionController(speechToText: service);
    addTearDown(controller.dispose);

    controller.startLiveRecognition();
    await Future<void>.delayed(Duration.zero);
    await controller.cancel();
    expect(service.cancelCalls, 1);
    expect(controller.state, VoiceUserActionState.idle);
  });
}
