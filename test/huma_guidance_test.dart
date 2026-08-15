import 'package:again/features/conversation/data/conversation_repository.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/huma/application/huma_guidance_engine.dart';
import 'package:again/features/huma/domain/huma_models.dart';
import 'package:again/features/huma/presentation/huma_components.dart';
import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = HumaGuidanceEngine();

  group('Phase 24 deterministic guidance', () {
    test('first-time user receives introduction', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.opening,
          firstTimeUser: true,
          returningUser: false,
        ),
      );
      expect(message.id, 'first-welcome');
      expect(message.text, contains('Merhaba, ben Hüma'));
    });

    test('returning user does not receive first-time introduction', () {
      final message = engine.select(
        const HumaContext(screen: HumaScreen.opening, learnerName: 'Sıla'),
      );
      expect(message.type, HumaMessageType.returningUser);
      expect(message.text, contains('Sıla'));
    });

    test('active story has priority over due vocabulary', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          activeStoryRoute: '/story',
          currentChapterId: 'hava-durumu',
          vocabularyDueCount: 5,
        ),
      );
      expect(message.type, HumaMessageType.story);
      expect(message.action?.route, '/story');
    });

    test('due vocabulary is recommended without active story', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          vocabularyCount: 8,
          vocabularyDueCount: 5,
        ),
      );
      expect(message.type, HumaMessageType.vocabulary);
      expect(message.text, contains('5'));
    });

    test('almost-complete daily goal is contextual', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          dailyMinutes: 7,
          dailyTarget: 10,
        ),
      );
      expect(message.type, HumaMessageType.progress);
      expect(message.text, contains('3'));
    });

    test('newly unlocked world is named', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.map,
          dailyMinutes: 0,
          dailyTarget: 20,
          newlyUnlockedWorldId: 'deniz-kralligi',
        ),
      );
      expect(message.text, contains('Deniz Krallığı'));
    });

    test('child wording stays short and concrete', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          learnerType: LearnerType.child,
          vocabularyCount: 3,
          vocabularyDueCount: 3,
        ),
      );
      expect(
        message.text,
        '3 kelimen tekrar bekliyor. Hazırsan birlikte bakalım.',
      );
    });

    test('teen wording is discovery-focused without slang', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          learnerType: LearnerType.teen,
          dailyMinutes: 8,
          dailyTarget: 10,
        ),
      );
      expect(message.text, contains('keşifle'));
      expect(message.text, isNot(contains('kanka')));
    });

    test('adult wording includes useful target context', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          learnerType: LearnerType.adult,
          dailyMinutes: 7,
          dailyTarget: 10,
        ),
      );
      expect(message.text, contains('10 dakikalık'));
      expect(message.text, contains('3 dakikası'));
    });

    test('same state returns stable guidance', () {
      const context = HumaContext(
        screen: HumaScreen.home,
        vocabularyCount: 4,
        vocabularyDueCount: 2,
      );
      expect(engine.select(context).id, engine.select(context).id);
      expect(engine.select(context).text, engine.select(context).text);
    });

    test('completed goal never claims minutes remain', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.home,
          dailyMinutes: 15,
          dailyTarget: 15,
        ),
      );
      expect(message.text, contains('tamamlandı'));
      expect(message.text, isNot(contains('kaldı')));
    });

    test('zero due words never claims reviews are due', () {
      final message = engine.select(
        const HumaContext(screen: HumaScreen.home, vocabularyCount: 5),
      );
      expect(message.type, isNot(HumaMessageType.vocabulary));
    });

    test('locked-world state is not invented', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.map,
          currentWorldId: 'yasam-vadisi',
        ),
      );
      expect(message.text, isNot(contains('artık açık')));
    });

    test('empty vocabulary receives honest guidance', () {
      final message = engine.select(
        const HumaContext(screen: HumaScreen.vocabulary, vocabularyCount: 0),
      );
      expect(message.type, HumaMessageType.emptyState);
    });

    test('real growth stage can take high priority', () {
      final message = engine.select(
        const HumaContext(
          screen: HumaScreen.vocabulary,
          newGrowthWord: 'cloudy',
        ),
      );
      expect(message.text, contains('cloudy'));
      expect(message.priority, 95);
    });

    test('ordinary exploration is not major celebration', () {
      final message = engine.select(const HumaContext(screen: HumaScreen.home));
      expect(message.isMajorCelebration, isFalse);
    });
  });

  group('AI-ready local conversation service', () {
    test('service truthfully identifies local and no voice', () {
      final service = LocalHumaConversationService();
      expect(service.isLocalDeterministic, isTrue);
      expect(service.supportsVoice, isFalse);
    });

    test('same scripted request returns deterministic reply', () async {
      final service = LocalHumaConversationService();
      final request = cafeRequest('I’d like a coffee, please.');
      final first = await service.respond(request);
      final second = await service.respond(request);
      expect(first.assistantText, second.assistantText);
      expect(first.suggestedReplies, isNotEmpty);
      expect(first.safetyState, HumaSafetyState.safe);
    });

    test('request keeps safety profile typed', () {
      final request = cafeRequest('Hello', profile: HumaSafetyProfile.child);
      expect(request.safetyProfile, HumaSafetyProfile.child);
      expect(request.history, hasLength(2));
    });

    test('correction is calm natural alternative', () async {
      final correction = await LocalHumaConversationService().correctSentence(
        'I want coffee please',
      );
      expect(correction, 'I’d like a coffee, please.');
      expect(correction, isNot(contains('WRONG')));
    });
  });

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(412, 915),
    Size(1366, 768),
  ]) {
    testWidgets(
      'Hüma component family fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    HumaHero(height: 180),
                    HumaGuideCard(
                      message: HumaMessage(
                        id: 'test',
                        type: HumaMessageType.guidance,
                        text: 'Kısa bir yolculukla devam edebiliriz.',
                        priority: 10,
                      ),
                    ),
                    HumaSpeechBubble(
                      text: 'Bu ifade biraz zorladı. Bir kez daha görelim.',
                    ),
                    HumaHelpSheet(
                      title: 'Cümleyi açıkla',
                      explanation: 'Bu yerel ve güvenilir açıklamadır.',
                    ),
                    HumaListeningState(),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.text('Kısa bir yolculukla devam edebiliriz.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

HumaConversationRequest cafeRequest(
  String text, {
  HumaSafetyProfile profile = HumaSafetyProfile.adult,
}) => HumaConversationRequest(
  userMessage: text,
  learnerLevel: 'A1',
  learnerType: profile.name,
  scenario: ConversationScenario.cafe,
  history: [
    const HumaConversationTurn(
      author: ConversationAuthor.huma,
      text: 'What would you like?',
    ),
    HumaConversationTurn(author: ConversationAuthor.user, text: text),
  ],
  safetyProfile: profile,
  targetVocabulary: const ['coffee', 'please'],
);
