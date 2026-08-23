import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/huma_ai_models.dart';
import 'huma_ai_backend.dart';

/// Real remote adapter. Provider credentials and the system prompt never enter
/// Flutter; the authenticated Supabase Edge Function owns those concerns.
class SupabaseHumaAiBackend implements HumaAiBackend {
  SupabaseHumaAiBackend(this._client, {this.functionName = 'huma-chat'});

  final SupabaseClient _client;
  final String functionName;

  @override
  HumaAiAvailability get availability => _client.auth.currentSession == null
      ? HumaAiAvailability.providerUnavailable
      : HumaAiAvailability.available;

  @override
  Future<HumaAiResponse> send(HumaAiRequest request) async {
    if (_client.auth.currentSession == null) {
      throw const HumaAiUnavailable(HumaAiAvailability.providerUnavailable);
    }
    final response = await _client.functions.invoke(
      functionName,
      body: _requestJson(request),
    );
    if (response.status == 429) {
      throw const HumaAiUnavailable(HumaAiAvailability.rateLimited);
    }
    if (response.status == 401 || response.status == 403) {
      throw const HumaAiUnavailable(HumaAiAvailability.providerUnavailable);
    }
    if (response.status < 200 || response.status >= 300) {
      throw const HumaAiUnavailable(HumaAiAvailability.providerUnavailable);
    }
    return _responseJson(response.data);
  }

  Map<String, Object?> _requestJson(HumaAiRequest value) => {
    'requestSchemaVersion': 'huma-request-v1',
    'requestId': value.requestId,
    'sessionId': value.sessionId,
    'turnId': value.turnId,
    'learnerType': value.learnerType,
    'englishLevel': value.englishLevel,
    'scenario': value.scenario.name,
    'userMessage': value.userMessage,
    'recentContext': value.recentContext
        .map((turn) => {'author': turn.author.name, 'text': turn.text})
        .toList(),
    'activeLearningGoals': value.activeLearningGoals.toList(),
    'targetVocabulary': value.targetVocabulary,
    'storyContext': value.storyContext,
    'requestedAction': value.requestedAction.name,
    'safetyProfile': value.safetyProfile.name,
    'locale': value.locale,
    'policyVersion': value.policyVersion,
    'promptVersion': value.promptVersion,
    'responseSchemaVersion': value.responseSchemaVersion,
  };

  HumaAiResponse _responseJson(Object? raw) {
    if (raw is! Map) throw const FormatException('Malformed response.');
    final json = Map<String, Object?>.from(raw);
    T enumValue<T extends Enum>(List<T> values, String key) {
      final name = json[key];
      return values.where((value) => value.name == name).firstOrNull ??
          (throw FormatException('Invalid $key.'));
    }

    List<String> strings(String key) {
      final value = json[key];
      if (value == null) return const [];
      if (value is! List || value.any((item) => item is! String)) {
        throw FormatException('Invalid $key.');
      }
      return value.cast<String>();
    }

    final correctionsRaw = json['corrections'];
    if (correctionsRaw != null && correctionsRaw is! List) {
      throw const FormatException('Invalid corrections.');
    }
    return HumaAiResponse(
      requestId:
          json['requestId'] as String? ??
          (throw const FormatException('Missing requestId.')),
      assistantText:
          json['assistantText'] as String? ??
          (throw const FormatException('Missing assistantText.')),
      responseMode: enumValue(HumaResponseMode.values, 'responseMode'),
      safetyEvent: enumValue(HumaSafetyEvent.values, 'safetyEvent'),
      responseSchemaVersion: json['responseSchemaVersion'] as String? ?? '',
      suggestedReplies: strings('suggestedReplies'),
      vocabularySuggestions: strings('vocabularySuggestions'),
      explanation: json['explanation'] as String?,
      encouragement: json['encouragement'] as String?,
      sessionSummaryDelta: json['sessionSummaryDelta'] as String?,
      corrections: (correctionsRaw as List? ?? const []).map((rawCorrection) {
        if (rawCorrection is! Map) {
          throw const FormatException('Invalid correction.');
        }
        final correction = Map<String, Object?>.from(rawCorrection);
        final category = HumaCorrectionCategory.values
            .where((item) => item.name == correction['category'])
            .firstOrNull;
        if (category == null) throw const FormatException('Invalid category.');
        return HumaCorrection(
          category: category,
          original: correction['original'] as String? ?? '',
          suggestion: correction['suggestion'] as String? ?? '',
          shortExplanation: correction['shortExplanation'] as String? ?? '',
          severity: correction['severity'] as int? ?? 1,
        );
      }).toList(),
    );
  }
}
