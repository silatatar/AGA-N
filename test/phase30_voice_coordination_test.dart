import 'package:again/features/voice/application/voice_activity_coordinator.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/voice/domain/voice_progress_policy.dart';
import 'package:again/features/voice/domain/voice_services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Playback implements AudioPlaybackService {
  final List<String> events = [];
  @override
  AudioPlaybackState state = AudioPlaybackState.idle;
  @override
  Future<void> play(String audioReference) async {
    events.add('play:$audioReference');
    state = AudioPlaybackState.playing;
  }

  @override
  Future<void> pause() async => events.add('pause');
  @override
  Future<void> stop() async {
    events.add('stop');
    state = AudioPlaybackState.idle;
  }
}

class _Recorder implements VoiceRecorderService {
  bool recording = false;
  @override
  Future<MicrophonePermissionState> getPermissionState() async =>
      MicrophonePermissionState.granted;
  @override
  Future<MicrophonePermissionState> requestPermission() async =>
      MicrophonePermissionState.granted;
  @override
  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  }) async {
    recording = true;
    return VoiceRecordingSession(
      sessionId: sessionId,
      ownerId: ownerId,
      state: VoiceRecordingState.recording,
      sourceContext: sourceContext,
      startedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<VoiceRecordingSession> stopRecording() async {
    recording = false;
    return VoiceRecordingSession(
      sessionId: 'voice-1',
      ownerId: 'guest:device-a',
      state: VoiceRecordingState.completed,
      sourceContext: VoiceSourceContext.humaConversation,
      durationMilliseconds: 12500,
    );
  }

  @override
  Future<void> cancelRecording() async => recording = false;
  @override
  Future<void> dispose() async => recording = false;
}

void main() {
  group('Phase 30 audio coordination', () {
    test('starting a new playback stops the previous learning audio', () async {
      final playback = _Playback();
      final coordinator = VoiceActivityCoordinator(
        playback: playback,
        recorder: _Recorder(),
      );
      await coordinator.play('story');
      await coordinator.play('vocabulary');
      expect(playback.events, ['play:story', 'stop', 'play:vocabulary']);
    });

    test('recording stops active playback before microphone starts', () async {
      final playback = _Playback();
      final recorder = _Recorder();
      final coordinator = VoiceActivityCoordinator(
        playback: playback,
        recorder: recorder,
      );
      await coordinator.play('story');
      final session = await coordinator.startRecording(
        sessionId: 'voice-1',
        ownerId: 'guest:device-a',
        sourceContext: VoiceSourceContext.humaConversation,
      );
      expect(playback.events, ['play:story', 'stop']);
      expect(session.state, VoiceRecordingState.recording);
      expect(coordinator.state, VoiceActivityState.recording);
    });

    test('playback is blocked while microphone is recording', () async {
      final coordinator = VoiceActivityCoordinator(
        playback: _Playback(),
        recorder: _Recorder(),
      );
      await coordinator.startRecording(
        sessionId: 'voice-1',
        ownerId: 'guest:device-a',
        sourceContext: VoiceSourceContext.humaConversation,
      );
      await expectLater(
        coordinator.play('tts'),
        throwsA(isA<VoiceActivityConflict>()),
      );
    });

    test('dispose cancels hidden recording and resets state', () async {
      final recorder = _Recorder();
      final coordinator = VoiceActivityCoordinator(
        playback: _Playback(),
        recorder: recorder,
      );
      await coordinator.startRecording(
        sessionId: 'voice-1',
        ownerId: 'user:a',
        sourceContext: VoiceSourceContext.storySpeaking,
      );
      await coordinator.dispose();
      expect(recorder.recording, isFalse);
      expect(coordinator.state, VoiceActivityState.idle);
    });
  });

  group('Phase 30 progress truth', () {
    test('listening requires real playback and eighty percent completion', () {
      expect(
        VoiceProgressPolicy.listeningCompleted(
          playbackActuallyStarted: false,
          playedMilliseconds: 10000,
          totalMilliseconds: 10000,
        ),
        isFalse,
      );
      expect(
        VoiceProgressPolicy.listeningCompleted(
          playbackActuallyStarted: true,
          playedMilliseconds: 7999,
          totalMilliseconds: 10000,
        ),
        isFalse,
      );
      expect(
        VoiceProgressPolicy.listeningCompleted(
          playbackActuallyStarted: true,
          playedMilliseconds: 8000,
          totalMilliseconds: 10000,
        ),
        isTrue,
      );
    });

    test('text, mic tap, and test adapter never add speaking time', () {
      expect(
        VoiceProgressPolicy.speakingSecondsFromRecording(
          recorderActuallyStarted: false,
          testAdapter: false,
          durationMilliseconds: 60000,
        ),
        0,
      );
      expect(
        VoiceProgressPolicy.speakingSecondsFromRecording(
          recorderActuallyStarted: true,
          testAdapter: true,
          durationMilliseconds: 60000,
        ),
        0,
      );
    });

    test(
      'short recordings accumulate seconds without rounding to a minute',
      () {
        final accumulator = SpeakingDurationAccumulator();
        accumulator.addActualRecording(
          recorderActuallyStarted: true,
          testAdapter: false,
          durationMilliseconds: 12500,
        );
        accumulator.addActualRecording(
          recorderActuallyStarted: true,
          testAdapter: false,
          durationMilliseconds: 12500,
        );
        expect(accumulator.completedSeconds, 25);
        expect(accumulator.displayMinutes, closeTo(25 / 60, 0.001));
      },
    );
  });
}
