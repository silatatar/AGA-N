import '../domain/voice_models.dart';
import '../domain/voice_services.dart';
import '../domain/voice_telemetry.dart';

class VoicePermissionController {
  VoicePermissionController({
    required this.recorder,
    this.telemetry = const NoopVoiceTelemetrySink(),
  });

  final VoiceRecorderService recorder;
  final VoiceTelemetrySink telemetry;
  MicrophonePermissionState _state = MicrophonePermissionState.unknown;
  bool _requestInFlight = false;

  MicrophonePermissionState get state => _state;
  bool get canOpenSystemSettings =>
      _state == MicrophonePermissionState.permanentlyDenied;
  bool get textAlternativeAvailable => true;

  Future<MicrophonePermissionState> refresh() async {
    _state = await recorder.getPermissionState();
    return _state;
  }

  /// Must only be called from an explicit user voice action.
  Future<MicrophonePermissionState> requestFromUserAction({
    required String sessionId,
  }) async {
    if (_requestInFlight ||
        _state == MicrophonePermissionState.granted ||
        _state == MicrophonePermissionState.permanentlyDenied ||
        _state == MicrophonePermissionState.restricted ||
        _state == MicrophonePermissionState.unsupported) {
      return _state;
    }
    _requestInFlight = true;
    _state = MicrophonePermissionState.requesting;
    telemetry.record(
      VoiceEvent(
        type: VoiceEventType.microphonePermissionRequested,
        sessionId: sessionId,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
    try {
      _state = await recorder.requestPermission();
      return _state;
    } finally {
      _requestInFlight = false;
    }
  }
}
