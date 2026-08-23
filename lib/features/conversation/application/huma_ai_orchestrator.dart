import 'dart:async';

import '../data/huma_ai_backend.dart';
import '../domain/huma_ai_models.dart';
import '../domain/huma_ai_telemetry.dart';

class HumaAiOrchestrator {
  HumaAiOrchestrator({
    required this.backend,
    this.validator = const HumaAiResponseValidator(),
    this.telemetry = const NoopHumaAiTelemetrySink(),
    this.timeout = const Duration(seconds: 12),
  });

  final HumaAiBackend backend;
  final HumaAiResponseValidator validator;
  final HumaAiTelemetrySink telemetry;
  final Duration timeout;
  final Map<String, HumaAiOrchestrationResult> _completedRequests = {};
  final Map<String, Future<HumaAiOrchestrationResult>> _inFlight = {};

  Future<HumaAiOrchestrationResult> send(HumaAiRequest request) {
    final completed = _completedRequests[request.requestId];
    if (completed != null) return Future.value(completed);
    return _inFlight.putIfAbsent(request.requestId, () => _execute(request));
  }

  Future<HumaAiOrchestrationResult> _execute(HumaAiRequest request) async {
    telemetry.record(
      HumaAiEvent(
        type: HumaAiEventType.requestStarted,
        requestId: request.requestId,
        sessionId: request.sessionId,
        responseMode: request.requestedAction,
        interactionMode: HumaInteractionMode.remoteAi,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
    try {
      if (backend.availability != HumaAiAvailability.available) {
        return _fallback(request, _availabilityFailure(backend.availability));
      }
      final response = await backend.send(request).timeout(timeout);
      if (!validator.isSafeForDisplay(request, response)) {
        return _fallback(request, HumaAiFailureKind.unsafeResponse);
      }
      final result = _remember(
        request.requestId,
        HumaAiOrchestrationResult.success(response),
      );
      telemetry.record(
        HumaAiEvent(
          type: HumaAiEventType.requestSucceeded,
          requestId: request.requestId,
          sessionId: request.sessionId,
          responseMode: request.requestedAction,
          interactionMode: HumaInteractionMode.remoteAi,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
      return result;
    } on TimeoutException {
      return _fallback(request, HumaAiFailureKind.timeout);
    } on HumaAiUnavailable catch (error) {
      return _fallback(request, _availabilityFailure(error.availability));
    } on FormatException {
      return _fallback(request, HumaAiFailureKind.malformedResponse);
    } catch (_) {
      return _fallback(request, HumaAiFailureKind.unknown);
    } finally {
      _inFlight.remove(request.requestId);
    }
  }

  HumaAiOrchestrationResult _fallback(
    HumaAiRequest request,
    HumaAiFailureKind failure,
  ) {
    final result = _remember(
      request.requestId,
      HumaAiOrchestrationResult.fallback(failure),
    );
    telemetry.record(
      HumaAiEvent(
        type: failure == HumaAiFailureKind.unsafeResponse
            ? HumaAiEventType.unsafeOutputRejected
            : HumaAiEventType.fallbackUsed,
        requestId: request.requestId,
        sessionId: request.sessionId,
        responseMode: request.requestedAction,
        interactionMode: HumaInteractionMode.remoteAi,
        occurredAt: DateTime.now().toUtc(),
        failureKind: failure,
      ),
    );
    return result;
  }

  HumaAiOrchestrationResult _remember(
    String requestId,
    HumaAiOrchestrationResult result,
  ) {
    _completedRequests[requestId] = result;
    return result;
  }

  HumaAiFailureKind _availabilityFailure(HumaAiAvailability availability) =>
      switch (availability) {
        HumaAiAvailability.providerUnavailable =>
          HumaAiFailureKind.providerUnavailable,
        HumaAiAvailability.offline => HumaAiFailureKind.offline,
        HumaAiAvailability.rateLimited => HumaAiFailureKind.rateLimited,
        HumaAiAvailability.available => HumaAiFailureKind.unknown,
      };
}
