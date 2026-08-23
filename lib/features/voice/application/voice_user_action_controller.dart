import 'package:flutter/foundation.dart';

import '../domain/voice_models.dart';
import '../domain/voice_services.dart';
import '../domain/voice_transcript.dart';
import 'voice_recognition_coordinator.dart';

enum VoiceUserActionState {
  idle,
  requestingPermission,
  listening,
  processing,
  transcriptReady,
  unavailable,
  error,
}

class VoiceUserActionController extends ChangeNotifier {
  VoiceUserActionController({required this.speechToText})
    : _recognition = VoiceRecognitionCoordinator(speechToText: speechToText);

  final LiveSpeechToTextService speechToText;
  final VoiceRecognitionCoordinator _recognition;
  VoiceUserActionState _state = VoiceUserActionState.idle;
  VoiceTranscriptReview? _review;
  int _sequence = 0;
  bool _disposed = false;

  VoiceUserActionState get state => _state;
  VoiceTranscriptReview? get review => _review;
  bool get isBusy =>
      _state == VoiceUserActionState.requestingPermission ||
      _state == VoiceUserActionState.listening ||
      _state == VoiceUserActionState.processing;

  Future<VoiceTranscriptReview?> startLiveRecognition() async {
    if (isBusy || _disposed) return null;
    _review = null;
    _setState(VoiceUserActionState.requestingPermission);
    final availability = await speechToText.initialize(requestPermission: true);
    if (availability != VoiceAvailability.available) {
      _setState(VoiceUserActionState.unavailable);
      return null;
    }

    final id = ++_sequence;
    final requestId = 'live-voice-$id';
    final sessionId = 'live-session-$id';
    final result = await _recognition.recognise(
      SpeechRecognitionRequest(
        requestId: requestId,
        sessionId: sessionId,
        mode: SpeechRecognitionMode.liveShortUtterance,
        sourceLocale: 'tr-TR',
        targetLearningLanguage: speechToText.selectedLocale ?? 'en-US',
        onStarted: () => _setState(VoiceUserActionState.listening),
      ),
    );
    if (_disposed) return null;
    _setState(VoiceUserActionState.processing);
    if (result == null) {
      _setState(VoiceUserActionState.error);
      return null;
    }
    _review = result;
    _setState(VoiceUserActionState.transcriptReady);
    return result;
  }

  Future<void> cancel() async {
    await speechToText.cancel();
    _review = null;
    _setState(VoiceUserActionState.idle);
  }

  void complete() {
    _review = null;
    _setState(VoiceUserActionState.idle);
  }

  void _setState(VoiceUserActionState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    speechToText.cancel();
    super.dispose();
  }
}
