import '../domain/huma_ai_models.dart';

abstract interface class HumaAiBackend {
  HumaAiAvailability get availability;
  Future<HumaAiResponse> send(HumaAiRequest request);
}

class HumaAiUnavailable implements Exception {
  const HumaAiUnavailable(this.availability);
  final HumaAiAvailability availability;
}

/// Production-safe default until an authenticated AGAIN backend is configured.
/// It never calls a model provider and never presents scripted text as AI.
class UnconfiguredHumaAiBackend implements HumaAiBackend {
  const UnconfiguredHumaAiBackend();

  @override
  HumaAiAvailability get availability => HumaAiAvailability.providerUnavailable;

  @override
  Future<HumaAiResponse> send(HumaAiRequest request) async {
    throw const HumaAiUnavailable(HumaAiAvailability.providerUnavailable);
  }
}

class HumaAiResponseValidator {
  const HumaAiResponseValidator({this.policy = const HumaPolicyConfig()});
  final HumaPolicyConfig policy;

  bool isSafeForDisplay(HumaAiRequest request, HumaAiResponse response) {
    if (response.requestId != request.requestId ||
        response.responseSchemaVersion != request.responseSchemaVersion ||
        response.assistantText.trim().isEmpty ||
        response.assistantText.length > policy.maxAssistantCharacters) {
      return false;
    }
    if (response.safetyEvent == HumaSafetyEvent.blocked ||
        response.safetyEvent == HumaSafetyEvent.providerFailure) {
      return false;
    }
    final text = response.assistantText.toLowerCase();
    return !text.contains('http://') &&
        !text.contains('https://') &&
        !text.contains('whatsapp') &&
        !text.contains('telefon numaran');
  }
}

abstract final class HumaAiFallback {
  static const message =
      'Şu anda serbest sohbeti sürdüremiyorum. İstersen hazır bir konuşma pratiğiyle devam edebiliriz.';
}
