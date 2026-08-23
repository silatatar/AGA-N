import 'package:again/features/conversation/application/huma_ai_orchestrator.dart';
import 'package:again/features/conversation/data/huma_ai_backend.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:again/features/conversation/domain/huma_ai_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBackend implements HumaAiBackend {
  _FakeBackend({this.delay = Duration.zero, this.response, this.error});

  @override
  HumaAiAvailability get availability => HumaAiAvailability.available;
  final Duration delay;
  final HumaAiResponse? response;
  final Object? error;
  int calls = 0;

  @override
  Future<HumaAiResponse> send(HumaAiRequest request) async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error case final value?) throw value;
    return response ??
        HumaAiResponse(
          requestId: request.requestId,
          assistantText: 'Hello. How are you?',
          responseMode: request.requestedAction,
          safetyEvent: HumaSafetyEvent.safe,
        );
  }
}

class _MemoryTelemetry implements HumaAiTelemetrySink {
  final List<HumaAiEvent> events = [];

  @override
  void record(HumaAiEvent event) => events.add(event);
}

HumaAiRequest _request([String id = 'request-1']) => HumaAiRequest(
  requestId: id,
  sessionId: 'session-1',
  turnId: 'turn-1',
  learnerType: 'child',
  englishLevel: 'A1',
  scenario: ConversationScenario.cafe,
  userMessage: 'Hello',
  requestedAction: HumaResponseMode.conversation,
  safetyProfile: HumaSafetyProfile.child,
  locale: 'tr-TR',
  policyVersion: 'policy-v1',
  promptVersion: 'prompt-v1',
);

void main() {
  group('Phase 29 safe orchestration', () {
    test('A1 is materially stricter than B2', () {
      final a1 = HumaAiPolicyAssembler.forLearner(
        cefrLevel: 'A1',
        safetyProfile: HumaSafetyProfile.child,
      );
      final b2 = HumaAiPolicyAssembler.forLearner(
        cefrLevel: 'B2',
        safetyProfile: HumaSafetyProfile.adult,
      );
      expect(a1.maxSentenceWords, lessThan(b2.maxSentenceWords));
      expect(a1.allowHighRiskAdvice, isFalse);
      expect(b2.allowHighRiskAdvice, isFalse);
      expect(a1.allowOffPlatformContact, isFalse);
    });

    test('same request id invokes backend once', () async {
      final backend = _FakeBackend(delay: const Duration(milliseconds: 5));
      final telemetry = _MemoryTelemetry();
      final orchestrator = HumaAiOrchestrator(
        backend: backend,
        telemetry: telemetry,
      );
      final results = await Future.wait([
        orchestrator.send(_request()),
        orchestrator.send(_request()),
      ]);
      expect(backend.calls, 1);
      expect(results.every((result) => !result.usedFallback), isTrue);
      await orchestrator.send(_request());
      expect(backend.calls, 1);
      expect(telemetry.events.map((event) => event.type), [
        HumaAiEventType.requestStarted,
        HumaAiEventType.requestSucceeded,
      ]);
    });

    test('timeout becomes safe typed fallback without retry storm', () async {
      final backend = _FakeBackend(delay: const Duration(milliseconds: 30));
      final orchestrator = HumaAiOrchestrator(
        backend: backend,
        timeout: const Duration(milliseconds: 1),
      );
      final result = await orchestrator.send(_request());
      expect(result.failure, HumaAiFailureKind.timeout);
      expect(result.usedFallback, isTrue);
      expect(backend.calls, 1);
    });

    test('malformed provider response becomes typed fallback', () async {
      final backend = _FakeBackend(error: const FormatException('bad json'));
      final result = await HumaAiOrchestrator(
        backend: backend,
      ).send(_request());
      expect(result.failure, HumaAiFailureKind.malformedResponse);
    });

    test('unsafe output is never returned to presentation', () async {
      final telemetry = _MemoryTelemetry();
      final backend = _FakeBackend(
        response: const HumaAiResponse(
          requestId: 'request-1',
          assistantText: 'Message me on WhatsApp.',
          responseMode: HumaResponseMode.conversation,
          safetyEvent: HumaSafetyEvent.safe,
        ),
      );
      final result = await HumaAiOrchestrator(
        backend: backend,
        telemetry: telemetry,
      ).send(_request());
      expect(result.response, isNull);
      expect(result.failure, HumaAiFailureKind.unsafeResponse);
      expect(telemetry.events.last.type, HumaAiEventType.unsafeOutputRejected);
    });

    test('telemetry schema cannot contain raw conversation text', () {
      final event = HumaAiEvent(
        type: HumaAiEventType.fallbackUsed,
        requestId: 'request-1',
        sessionId: 'session-1',
        responseMode: HumaResponseMode.conversation,
        interactionMode: HumaInteractionMode.remoteAi,
        occurredAt: DateTime.utc(2026),
        failureKind: HumaAiFailureKind.offline,
      );
      expect(event.requestId, 'request-1');
      expect(event.failureKind, HumaAiFailureKind.offline);
      expect(event.toString().toLowerCase(), isNot(contains('usertext')));
      expect(event.toString().toLowerCase(), isNot(contains('assistanttext')));
    });

    test('session turn is separate from permanent progression', () {
      final session = HumaAiSession(
        sessionId: 'session-1',
        ownerId: 'user-1',
        learnerType: 'adult',
        scenario: ConversationScenario.cafe,
        startedAt: DateTime.utc(2026),
        turns: const [],
        targetVocabulary: const ['coffee'],
        policyVersion: 'policy-v1',
        promptVersion: 'prompt-v1',
      );
      final updated = session.addTurn(
        HumaAiTurnRecord(
          turnId: 'turn-1',
          requestId: 'request-1',
          userText: 'Coffee, please.',
          assistantText: 'Of course.',
          createdAt: DateTime.utc(2026),
          safetyEvent: HumaSafetyEvent.safe,
        ),
      );
      expect(updated.turns, hasLength(1));
      expect(updated.ownerId, 'user-1');
    });
  });
}
