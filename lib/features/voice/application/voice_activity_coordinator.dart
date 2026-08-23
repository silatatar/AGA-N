import '../domain/voice_models.dart';
import '../domain/voice_services.dart';

enum VoiceActivityState { idle, playing, recording }

class VoiceActivityCoordinator {
  VoiceActivityCoordinator({required this.playback, required this.recorder});

  final AudioPlaybackService playback;
  final VoiceRecorderService recorder;
  VoiceActivityState _state = VoiceActivityState.idle;

  VoiceActivityState get state => _state;

  Future<void> play(String audioReference) async {
    if (_state == VoiceActivityState.recording) {
      throw const VoiceActivityConflict('Audio cannot start while recording.');
    }
    if (_state == VoiceActivityState.playing) await playback.stop();
    await playback.play(audioReference);
    _state = VoiceActivityState.playing;
  }

  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  }) async {
    if (_state == VoiceActivityState.playing) await playback.stop();
    final session = await recorder.startRecording(
      sessionId: sessionId,
      ownerId: ownerId,
      sourceContext: sourceContext,
    );
    _state = session.state == VoiceRecordingState.recording
        ? VoiceActivityState.recording
        : VoiceActivityState.idle;
    return session;
  }

  Future<VoiceRecordingSession> stopRecording() async {
    final session = await recorder.stopRecording();
    _state = VoiceActivityState.idle;
    return session;
  }

  Future<void> cancelRecording() async {
    await recorder.cancelRecording();
    _state = VoiceActivityState.idle;
  }

  Future<void> dispose() async {
    if (_state == VoiceActivityState.recording) {
      await recorder.cancelRecording();
    }
    await playback.stop();
    await recorder.dispose();
    _state = VoiceActivityState.idle;
  }
}

class VoiceActivityConflict implements Exception {
  const VoiceActivityConflict(this.message);
  final String message;
}
