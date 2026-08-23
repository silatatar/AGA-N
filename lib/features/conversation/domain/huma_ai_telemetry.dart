import 'huma_ai_models.dart';

enum HumaAiEventType {
  requestStarted,
  requestSucceeded,
  fallbackUsed,
  unsafeOutputRejected,
}

class HumaAiEvent {
  const HumaAiEvent({
    required this.type,
    required this.requestId,
    required this.sessionId,
    required this.responseMode,
    required this.interactionMode,
    required this.occurredAt,
    this.failureKind,
  });

  final HumaAiEventType type;
  final String requestId;
  final String sessionId;
  final HumaResponseMode responseMode;
  final HumaInteractionMode interactionMode;
  final DateTime occurredAt;
  final HumaAiFailureKind? failureKind;
}

abstract interface class HumaAiTelemetrySink {
  void record(HumaAiEvent event);
}

class NoopHumaAiTelemetrySink implements HumaAiTelemetrySink {
  const NoopHumaAiTelemetrySink();

  @override
  void record(HumaAiEvent event) {}
}
