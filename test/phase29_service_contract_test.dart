import 'package:again/features/conversation/data/conversation_repository.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:flutter_test/flutter_test.dart';

HumaConversationRequest _conversationRequest() => const HumaConversationRequest(
  userMessage: 'I want coffee please',
  learnerLevel: 'A1',
  learnerType: 'adult',
  scenario: ConversationScenario.cafe,
  history: [
    HumaConversationTurn(
      author: ConversationAuthor.user,
      text: 'I want coffee please',
    ),
  ],
  safetyProfile: HumaSafetyProfile.adult,
  targetVocabulary: ['coffee', 'please'],
);

void main() {
  group('Phase 29 conversation service contract', () {
    test(
      'local session identifies itself as scripted, never remote AI',
      () async {
        final service = LocalHumaConversationService();
        final handle = await service.startSession(
          const HumaSessionStartRequest(
            sessionId: 'session-1',
            learnerType: 'adult',
            learnerLevel: 'A1',
            scenario: ConversationScenario.cafe,
            safetyProfile: HumaSafetyProfile.adult,
            targetVocabulary: ['coffee'],
          ),
        );
        expect(handle.sessionId, 'session-1');
        expect(handle.interactionMode, 'localScripted');
        expect(service.isLocalDeterministic, isTrue);
        await service.endSession(handle.sessionId);
      },
    );

    test('empty session identifier is rejected', () async {
      await expectLater(
        LocalHumaConversationService().startSession(
          const HumaSessionStartRequest(
            sessionId: '',
            learnerType: 'adult',
            learnerLevel: 'A1',
            scenario: ConversationScenario.cafe,
            safetyProfile: HumaSafetyProfile.adult,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('correction returns structured calm learning feedback', () async {
      final correction = await LocalHumaConversationService().requestCorrection(
        'I want coffee please',
      );
      expect(correction, isNotNull);
      expect(correction!.original, 'I want coffee please');
      expect(correction.suggestion, 'I’d like a coffee, please.');
      expect(correction.category, CorrectionKind.moreNatural);
      expect(correction.shortExplanation, isNotEmpty);
    });

    test('explanation remains structured and safety-aware', () async {
      final response = await LocalHumaConversationService().requestExplanation(
        _conversationRequest(),
      );
      expect(response.explanation, isNotEmpty);
      expect(response.safetyState, HumaSafetyState.safe);
      expect(response.suggestedReplies, isNotEmpty);
    });
  });
}
