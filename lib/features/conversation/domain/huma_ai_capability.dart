import '../../../core/backend/backend_config.dart';

enum HumaRemoteAiCapability {
  unconfigured,
  available,
  temporarilyUnavailable,
  rateLimited,
  maintenance,
  blockedByReleaseGate,
}

enum HumaRemoteBackendState {
  operational,
  temporarilyUnavailable,
  rateLimited,
  maintenance,
}

class HumaRemoteAiReadiness {
  const HumaRemoteAiReadiness({
    required this.backendConfig,
    required this.phase28Point1Resolved,
    required this.endpointConfigured,
    required this.safetyValidationReady,
    required this.rateLimitReady,
    this.backendState = HumaRemoteBackendState.operational,
  });

  final BackendConfig backendConfig;
  final bool phase28Point1Resolved;
  final bool endpointConfigured;
  final bool safetyValidationReady;
  final bool rateLimitReady;
  final HumaRemoteBackendState backendState;

  HumaRemoteAiCapability get capability {
    if (!backendConfig.hasProductionBackend || !endpointConfigured) {
      return HumaRemoteAiCapability.unconfigured;
    }
    if (!phase28Point1Resolved || !safetyValidationReady || !rateLimitReady) {
      return HumaRemoteAiCapability.blockedByReleaseGate;
    }
    return switch (backendState) {
      HumaRemoteBackendState.operational => HumaRemoteAiCapability.available,
      HumaRemoteBackendState.temporarilyUnavailable =>
        HumaRemoteAiCapability.temporarilyUnavailable,
      HumaRemoteBackendState.rateLimited => HumaRemoteAiCapability.rateLimited,
      HumaRemoteBackendState.maintenance => HumaRemoteAiCapability.maintenance,
    };
  }

  bool get remoteUiAvailable => capability == HumaRemoteAiCapability.available;
  bool get localScriptedAvailable => true;
}
