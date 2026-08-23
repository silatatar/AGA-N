import 'package:again/features/voice/application/voice_permission_controller.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/voice/domain/voice_privacy_policy.dart';
import 'package:again/features/voice/domain/voice_services.dart';
import 'package:again/features/voice/domain/voice_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

class _PermissionRecorder implements VoiceRecorderService {
  _PermissionRecorder(this.result);
  final MicrophonePermissionState result;
  int requests = 0;
  @override
  Future<MicrophonePermissionState> getPermissionState() async =>
      MicrophonePermissionState.unknown;
  @override
  Future<MicrophonePermissionState> requestPermission() async {
    requests++;
    return result;
  }

  @override
  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  }) => throw UnimplementedError();
  @override
  Future<VoiceRecordingSession> stopRecording() => throw UnimplementedError();
  @override
  Future<void> cancelRecording() async {}
  @override
  Future<void> dispose() async {}
}

class _Telemetry implements VoiceTelemetrySink {
  final List<VoiceEvent> events = [];
  @override
  void record(VoiceEvent event) => events.add(event);
}

class _RecordingStore implements TemporaryRecordingStore {
  final List<String> deleted = [];
  @override
  Future<void> delete(String temporaryRecordingReference) async =>
      deleted.add(temporaryRecordingReference);
}

void main() {
  group('Phase 30 permission behavior', () {
    test('controller construction never requests microphone permission', () {
      final recorder = _PermissionRecorder(MicrophonePermissionState.granted);
      final controller = VoicePermissionController(recorder: recorder);
      expect(controller.state, MicrophonePermissionState.unknown);
      expect(recorder.requests, 0);
      expect(controller.textAlternativeAvailable, isTrue);
    });

    test('explicit user action requests and logs permission once', () async {
      final recorder = _PermissionRecorder(MicrophonePermissionState.granted);
      final telemetry = _Telemetry();
      final controller = VoicePermissionController(
        recorder: recorder,
        telemetry: telemetry,
      );
      await controller.requestFromUserAction(sessionId: 'voice-1');
      await controller.requestFromUserAction(sessionId: 'voice-1');
      expect(recorder.requests, 1);
      expect(telemetry.events, hasLength(1));
      expect(
        telemetry.events.single.type,
        VoiceEventType.microphonePermissionRequested,
      );
    });

    test(
      'permanent denial does not spam dialog and enables settings guidance',
      () async {
        final recorder = _PermissionRecorder(
          MicrophonePermissionState.permanentlyDenied,
        );
        final controller = VoicePermissionController(recorder: recorder);
        await controller.requestFromUserAction(sessionId: 'voice-1');
        await controller.requestFromUserAction(sessionId: 'voice-1');
        expect(recorder.requests, 1);
        expect(controller.canOpenSystemSettings, isTrue);
        expect(controller.textAlternativeAvailable, isTrue);
      },
    );
  });

  group('Phase 30 voice privacy and retention', () {
    test('child policy forbids permanent and social voice storage', () {
      final policy = VoicePrivacyPolicy.forProfile(
        VoiceLearnerSafetyProfile.child,
      );
      expect(policy.rawAudioTemporaryOnly, isTrue);
      expect(policy.allowPermanentRawAudio, isFalse);
      expect(policy.allowCommunityVoiceUpload, isFalse);
      expect(policy.allowStrangerVoiceChat, isFalse);
      expect(policy.requireGuardianReviewForFutureRemoteProcessing, isTrue);
    });

    test('adult policy still forbids hidden permanent raw audio', () {
      final policy = VoicePrivacyPolicy.forProfile(
        VoiceLearnerSafetyProfile.adult,
      );
      expect(policy.rawAudioTemporaryOnly, isTrue);
      expect(policy.allowPermanentRawAudio, isFalse);
    });

    test(
      'temporary recording is deleted after processing or cancellation',
      () async {
        final store = _RecordingStore();
        final retention = VoiceRecordingRetention(store: store);
        await retention.deleteAfterProcessing('temp-a');
        await retention.deleteAfterCancellation('temp-b');
        await retention.deleteAfterProcessing(null);
        expect(store.deleted, ['temp-a', 'temp-b']);
      },
    );
  });
}
