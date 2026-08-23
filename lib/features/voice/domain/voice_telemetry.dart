enum VoiceEventType {
  microphonePermissionRequested,
  recordingStarted,
  recordingCompleted,
  recordingCancelled,
  sttSucceeded,
  sttFailed,
  ttsStarted,
  ttsCompleted,
}

class VoiceEvent {
  const VoiceEvent({
    required this.type,
    required this.sessionId,
    required this.occurredAt,
    this.requestId,
    this.durationMilliseconds,
    this.failureCode,
  });

  final VoiceEventType type;
  final String sessionId;
  final String? requestId;
  final DateTime occurredAt;
  final int? durationMilliseconds;
  final String? failureCode;
}

abstract interface class VoiceTelemetrySink {
  void record(VoiceEvent event);
}

class NoopVoiceTelemetrySink implements VoiceTelemetrySink {
  const NoopVoiceTelemetrySink();
  @override
  void record(VoiceEvent event) {}
}
