import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_runtime.dart';
import '../data/huma_ai_backend.dart';
import '../data/supabase_huma_ai_backend.dart';
import '../domain/huma_ai_capability.dart';

const _edgeFunctionEnabled = bool.fromEnvironment('HUMA_EDGE_FUNCTION_ENABLED');

final humaRemoteAiReadinessProvider = Provider<HumaRemoteAiReadiness>(
  (ref) => HumaRemoteAiReadiness(
    backendConfig: SupabaseRuntime.config,
    phase28Point1Resolved: false,
    endpointConfigured: _edgeFunctionEnabled,
    safetyValidationReady: true,
    rateLimitReady: true,
  ),
);

final humaAiBackendProvider = Provider<HumaAiBackend>((ref) {
  final readiness = ref.watch(humaRemoteAiReadinessProvider);
  if (!readiness.remoteUiAvailable || SupabaseRuntime.client == null) {
    return const UnconfiguredHumaAiBackend();
  }
  return SupabaseHumaAiBackend(SupabaseRuntime.client!);
});
