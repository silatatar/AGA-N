import 'package:again/features/conversation/data/huma_ai_backend.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 29 Hüma AI foundation', () {
    HumaAiRequest request({
      List<HumaConversationTurn> history = const [],
      List<String> vocabulary = const [],
      HumaSafetyProfile safety = HumaSafetyProfile.adult,
    }) => HumaAiRequest(
      requestId: 'request-1',
      sessionId: 'session-1',
      turnId: 'turn-1',
      learnerType: safety.name,
      englishLevel: 'A1',
      scenario: ConversationScenario.cafe,
      userMessage: 'Can I have tea?',
      recentContext: history,
      activeLearningGoals: const {'daily-speaking'},
      targetVocabulary: vocabulary,
      requestedAction: HumaResponseMode.conversation,
      safetyProfile: safety,
      locale: 'tr-TR',
      policyVersion: 'huma-safety-v1',
      promptVersion: 'huma-personality-v1',
    );

    test('three interaction modes remain explicit', () {
      expect(HumaInteractionMode.values, hasLength(3));
      expect(
        HumaInteractionMode.values,
        contains(HumaInteractionMode.remoteAi),
      );
    });

    test('recent session context and vocabulary are bounded', () {
      final value = request(
        history: List.generate(
          12,
          (index) => HumaConversationTurn(
            author: ConversationAuthor.user,
            text: 'turn $index',
          ),
        ),
        vocabulary: List.generate(12, (index) => 'word$index'),
      );
      expect(value.recentContext, hasLength(8));
      expect(value.recentContext.first.text, 'turn 4');
      expect(value.targetVocabulary, hasLength(8));
    });

    test('child, teen and adult safety profiles stay typed', () {
      for (final profile in HumaSafetyProfile.values) {
        expect(request(safety: profile).safetyProfile, profile);
      }
    });

    test('empty and oversized messages are rejected before backend', () {
      expect(
        () => HumaAiRequest(
          requestId: 'r',
          sessionId: 's',
          turnId: 't',
          learnerType: 'adult',
          englishLevel: 'A1',
          scenario: ConversationScenario.cafe,
          userMessage: '',
          requestedAction: HumaResponseMode.conversation,
          safetyProfile: HumaSafetyProfile.adult,
          locale: 'tr-TR',
          policyVersion: 'p1',
          promptVersion: 'v1',
        ),
        throwsArgumentError,
      );
    });

    test('unconfigured backend never claims remote AI success', () async {
      const backend = UnconfiguredHumaAiBackend();
      expect(backend.availability, HumaAiAvailability.providerUnavailable);
      await expectLater(
        backend.send(request()),
        throwsA(isA<HumaAiUnavailable>()),
      );
    });

    test(
      'validator rejects mismatched request and unsupported contact link',
      () {
        const validator = HumaAiResponseValidator();
        final input = request();
        expect(
          validator.isSafeForDisplay(
            input,
            const HumaAiResponse(
              requestId: 'different',
              assistantText: 'Hello.',
              responseMode: HumaResponseMode.conversation,
              safetyEvent: HumaSafetyEvent.safe,
            ),
          ),
          isFalse,
        );
        expect(
          validator.isSafeForDisplay(
            input,
            const HumaAiResponse(
              requestId: 'request-1',
              assistantText: 'Write to me on WhatsApp.',
              responseMode: HumaResponseMode.conversation,
              safetyEvent: HumaSafetyEvent.safe,
            ),
          ),
          isFalse,
        );
      },
    );

    test('safe structured response passes validation', () {
      expect(
        const HumaAiResponseValidator().isSafeForDisplay(
          request(),
          const HumaAiResponse(
            requestId: 'request-1',
            assistantText: 'Of course. Would you like milk?',
            suggestedReplies: ['Yes, please.', 'No, thank you.'],
            responseMode: HumaResponseMode.conversation,
            safetyEvent: HumaSafetyEvent.safe,
          ),
        ),
        isTrue,
      );
    });
  });
}
