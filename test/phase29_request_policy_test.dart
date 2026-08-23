import 'package:again/features/conversation/application/huma_ai_request_factory.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:again/features/conversation/domain/huma_ai_usage_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 29 request minimisation', () {
    test('factory includes only bounded relevant learning context', () {
      final request = const HumaAiRequestFactory().create(
        requestId: 'r1',
        sessionId: 's1',
        turnId: 't1',
        scenario: ConversationScenario.cafe,
        userMessage: 'Tea, please.',
        action: HumaResponseMode.conversation,
        context: HumaAiLearningContext(
          learnerType: 'adult',
          englishLevel: 'A1',
          safetyProfile: HumaSafetyProfile.adult,
          locale: 'tr-TR',
          activeLearningGoals: {'travel'},
          relevantVocabulary: [
            'tea',
            'please',
            'cup',
            'milk',
            'hot',
            'cold',
            'small',
            'large',
            'irrelevant',
          ],
          recentTurns: List.generate(
            10,
            (index) => HumaConversationTurn(
              author: ConversationAuthor.user,
              text: 'turn $index',
            ),
          ),
        ),
      );
      expect(request.targetVocabulary, hasLength(8));
      expect(request.targetVocabulary, isNot(contains('irrelevant')));
      expect(request.recentContext, hasLength(8));
      expect(request.policyVersion, 'huma-safety-v1');
    });

    test(
      'request contract has no password, token or arbitrary prompt field',
      () {
        final fields = HumaAiRequest(
          requestId: 'r',
          sessionId: 's',
          turnId: 't',
          learnerType: 'adult',
          englishLevel: 'A1',
          scenario: ConversationScenario.cafe,
          userMessage: 'Hello',
          requestedAction: HumaResponseMode.conversation,
          safetyProfile: HumaSafetyProfile.adult,
          locale: 'tr-TR',
          policyVersion: 'p',
          promptVersion: 'v',
        ).toString();
        expect(fields.toLowerCase(), isNot(contains('password')));
        expect(fields.toLowerCase(), isNot(contains('authtoken')));
        expect(fields.toLowerCase(), isNot(contains('systemprompt')));
      },
    );
  });

  group('Phase 29 usage policy', () {
    test('guest minute limit is stricter and deterministic', () {
      final limiter = InMemoryHumaAiRateLimiter(
        policy: const HumaAiUsagePolicy(guestRequestsPerMinute: 2),
      );
      const key = HumaAiUsageKey(
        kind: HumaAiUsageOwnerKind.guestDevice,
        ownerKey: 'device-a',
      );
      final now = DateTime.utc(2026);
      expect(limiter.checkAndRecord(key, now), HumaAiUsageDecision.allowed);
      expect(limiter.checkAndRecord(key, now), HumaAiUsageDecision.allowed);
      expect(
        limiter.checkAndRecord(key, now),
        HumaAiUsageDecision.minuteLimitReached,
      );
    });

    test('usage is isolated by owner key', () {
      final limiter = InMemoryHumaAiRateLimiter(
        policy: const HumaAiUsagePolicy(guestRequestsPerMinute: 1),
      );
      final now = DateTime.utc(2026);
      for (final owner in ['device-a', 'device-b']) {
        expect(
          limiter.checkAndRecord(
            HumaAiUsageKey(
              kind: HumaAiUsageOwnerKind.guestDevice,
              ownerKey: owner,
            ),
            now,
          ),
          HumaAiUsageDecision.allowed,
        );
      }
    });

    test('minute window recovers without bypassing daily accounting', () {
      final limiter = InMemoryHumaAiRateLimiter(
        policy: const HumaAiUsagePolicy(
          guestRequestsPerMinute: 1,
          guestRequestsPerDay: 2,
        ),
      );
      const key = HumaAiUsageKey(
        kind: HumaAiUsageOwnerKind.guestDevice,
        ownerKey: 'device-a',
      );
      final now = DateTime.utc(2026);
      expect(limiter.checkAndRecord(key, now), HumaAiUsageDecision.allowed);
      expect(
        limiter.checkAndRecord(key, now.add(const Duration(minutes: 2))),
        HumaAiUsageDecision.allowed,
      );
      expect(
        limiter.checkAndRecord(key, now.add(const Duration(minutes: 4))),
        HumaAiUsageDecision.dailyLimitReached,
      );
    });
  });
}
