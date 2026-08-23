import 'package:again/core/backend/backend_config.dart';
import 'package:again/features/conversation/data/huma_ai_backend.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/conversation/domain/huma_ai_capability.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

const _configuredBackend = BackendConfig(
  environment: AppEnvironment.production,
  provider: BackendProvider.supabase,
  supabaseUrl: 'https://example.supabase.co',
  supabasePublishableKey: 'test-publishable-key',
);

HumaRemoteAiReadiness _readiness({
  BackendConfig backend = BackendConfig.development,
  bool phase28Point1Resolved = false,
  bool endpointConfigured = false,
  bool safetyValidationReady = false,
  bool rateLimitReady = false,
  HumaRemoteBackendState state = HumaRemoteBackendState.operational,
}) => HumaRemoteAiReadiness(
  backendConfig: backend,
  phase28Point1Resolved: phase28Point1Resolved,
  endpointConfigured: endpointConfigured,
  safetyValidationReady: safetyValidationReady,
  rateLimitReady: rateLimitReady,
  backendState: state,
);

HumaAiRequest _request() => HumaAiRequest(
  requestId: 'r1',
  sessionId: 's1',
  turnId: 't1',
  learnerType: 'adult',
  englishLevel: 'A1',
  scenario: ConversationScenario.cafe,
  userMessage: 'Hello',
  requestedAction: HumaResponseMode.conversation,
  safetyProfile: HumaSafetyProfile.adult,
  locale: 'tr-TR',
  policyVersion: 'policy-v1',
  promptVersion: 'prompt-v1',
  responseSchemaVersion: 'schema-v1',
);

void main() {
  group('Phase 29 remote readiness closeout', () {
    test(
      'remote AI is unconfigured by default while local remains available',
      () {
        final readiness = _readiness();
        expect(readiness.capability, HumaRemoteAiCapability.unconfigured);
        expect(readiness.remoteUiAvailable, isFalse);
        expect(readiness.localScriptedAvailable, isTrue);
      },
    );

    test('Phase 28.1 blocks an otherwise configured backend', () {
      final readiness = _readiness(
        backend: _configuredBackend,
        endpointConfigured: true,
        safetyValidationReady: true,
        rateLimitReady: true,
      );
      expect(readiness.capability, HumaRemoteAiCapability.blockedByReleaseGate);
      expect(readiness.remoteUiAvailable, isFalse);
    });

    test('all trusted readiness conditions permit remote capability', () {
      final readiness = _readiness(
        backend: _configuredBackend,
        phase28Point1Resolved: true,
        endpointConfigured: true,
        safetyValidationReady: true,
        rateLimitReady: true,
      );
      expect(readiness.capability, HumaRemoteAiCapability.available);
      expect(readiness.remoteUiAvailable, isTrue);
    });

    test('operational states map without pretending availability', () {
      for (final entry in {
        HumaRemoteBackendState.temporarilyUnavailable:
            HumaRemoteAiCapability.temporarilyUnavailable,
        HumaRemoteBackendState.rateLimited: HumaRemoteAiCapability.rateLimited,
        HumaRemoteBackendState.maintenance: HumaRemoteAiCapability.maintenance,
      }.entries) {
        final readiness = _readiness(
          backend: _configuredBackend,
          phase28Point1Resolved: true,
          endpointConfigured: true,
          safetyValidationReady: true,
          rateLimitReady: true,
          state: entry.key,
        );
        expect(readiness.capability, entry.value);
        expect(readiness.remoteUiAvailable, isFalse);
      }
    });
  });

  group('Phase 29 schema closeout', () {
    test('policy prompt and response schema versions propagate', () {
      const policy = HumaPolicyConfig(
        policyVersion: 'policy-v2',
        promptVersion: 'prompt-v3',
        responseSchemaVersion: 'schema-v4',
      );
      expect(policy.policyVersion, 'policy-v2');
      expect(policy.promptVersion, 'prompt-v3');
      expect(policy.responseSchemaVersion, 'schema-v4');
    });

    test('response schema mismatch is rejected before presentation', () {
      expect(
        const HumaAiResponseValidator().isSafeForDisplay(
          _request(),
          const HumaAiResponse(
            requestId: 'r1',
            assistantText: 'Hello.',
            responseMode: HumaResponseMode.conversation,
            safetyEvent: HumaSafetyEvent.safe,
            responseSchemaVersion: 'schema-v2',
          ),
        ),
        isFalse,
      );
    });
  });
}
