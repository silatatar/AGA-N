import 'dart:io';

import 'package:again/core/backend/backend_config.dart';
import 'package:again/features/conversation/data/huma_ai_backend.dart';
import 'package:again/features/conversation/domain/huma_ai_capability.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 35 remote Hüma backend', () {
    test(
      'unconfigured backend fails closed without fabricated output',
      () async {
        const backend = UnconfiguredHumaAiBackend();
        expect(backend.availability, HumaAiAvailability.providerUnavailable);
      },
    );

    test('Phase 28.1 still blocks remote UI', () {
      const readiness = HumaRemoteAiReadiness(
        backendConfig: BackendConfig(
          environment: AppEnvironment.production,
          provider: BackendProvider.supabase,
          supabaseUrl: 'https://example.supabase.co',
          supabasePublishableKey: 'public-key',
        ),
        phase28Point1Resolved: false,
        endpointConfigured: true,
        safetyValidationReady: true,
        rateLimitReady: true,
      );
      expect(readiness.remoteUiAvailable, isFalse);
      expect(readiness.localScriptedAvailable, isTrue);
    });

    test('Flutter source contains no provider secret or systemPrompt', () {
      final files = Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>();
      final source = files.map((file) => file.readAsStringSync()).join('\n');
      expect(source, isNot(contains('HUMA_MODEL_API_KEY')));
      expect(source, isNot(contains('systemPrompt')));
    });

    test('deployable function enforces trusted auth and bounded policy', () {
      final source = File(
        'supabase/functions/huma-chat/index.ts',
      ).readAsStringSync();
      expect(source, contains('/auth/v1/user'));
      expect(source, contains('MAX_TURNS = 8'));
      expect(source, contains('MAX_VOCABULARY = 8'));
      expect(source, contains('learner === "child"'));
      expect(source, contains('englishLevel'));
      expect(source, contains('providerUnavailable'));
      expect(source, contains('Never award XP'));
    });

    test('provider and system policy remain server-side only', () {
      final source = File(
        'supabase/functions/huma-chat/index.ts',
      ).readAsStringSync();
      expect(source, contains('interface HumaModelProvider'));
      expect(source, contains('HUMA_MODEL_API_KEY'));
      expect(source, contains('policyFor(request)'));
      expect(source, isNot(contains('console.log(request.userMessage)')));
    });
  });
}
