import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/progression/data/progression_repository.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/startup/startup_decision.dart';
import 'package:again/features/auth/domain/auth_session.dart';
import 'package:again/features/story/data/story_repository.dart';
import 'package:again/features/story/domain/story_definition.dart';
import 'package:again/features/world/domain/world_chapter.dart';
import 'package:again/features/world/domain/world_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 21 story definition validation', () {
    test('valid generic weather story passes', () {
      expect(
        validateStoryDefinition(localStories['weather-storm']!).isValid,
        isTrue,
      );
    });

    test('missing start node fails safely', () {
      final valid = localStories['weather-storm']!;
      final broken = StoryDefinition(
        id: 'broken',
        worldId: valid.worldId,
        chapter: valid.chapter,
        title: valid.title,
        description: valid.description,
        startNodeId: 'missing',
        nodes: valid.nodes,
        reward: valid.reward,
      );
      expect(
        validateStoryDefinition(broken).errors,
        contains('missing-start-node'),
      );
    });

    test('broken choice target is reported', () {
      const broken = StoryDefinition(
        id: 'broken-choice',
        worldId: 'test',
        chapter: StoryChapter(
          id: 'c',
          number: 1,
          durationMinutes: 1,
          vocabularyCount: 0,
        ),
        title: 'Broken',
        description: 'Broken',
        startNodeId: 'choice',
        reward: StoryReward(xp: 0),
        nodes: {
          'choice': StoryNode(
            id: 'choice',
            scene: valley,
            kind: StoryNodeKind.choice,
            englishText: '?',
            choices: [
              StoryChoice(
                id: 'x',
                label: 'X',
                outcome: StoryOutcome(nextNodeId: 'missing', feedback: ''),
              ),
            ],
          ),
        },
      );
      expect(
        validateStoryDefinition(broken).errors.single,
        contains('broken-choice'),
      );
    });
  });
  group('startup decision', () {
    const none = AuthSession(status: AuthStatus.unauthenticated),
        guest = AuthSession(status: AuthStatus.guest);
    test(
      '1 new user',
      () => expect(
        decideStartup(
          hasLearnerType: false,
          hasProfile: false,
          onboardingComplete: false,
          answersComplete: false,
          session: none,
        ),
        StartupDestination.humaArrival,
      ),
    );
    test(
      '2 learner resumes name',
      () => expect(
        decideStartup(
          hasLearnerType: true,
          hasProfile: false,
          onboardingComplete: false,
          answersComplete: false,
          session: none,
        ),
        StartupDestination.profileName,
      ),
    );
    test(
      '3 incomplete onboarding resumes',
      () => expect(
        decideStartup(
          hasLearnerType: true,
          hasProfile: true,
          onboardingComplete: false,
          answersComplete: false,
          session: none,
        ),
        StartupDestination.onboarding,
      ),
    );
    test(
      '4 completed onboarding asks account',
      () => expect(
        decideStartup(
          hasLearnerType: true,
          hasProfile: true,
          onboardingComplete: true,
          answersComplete: true,
          session: none,
        ),
        StartupDestination.accountDecision,
      ),
    );
    test(
      '5 guest resumes home',
      () => expect(
        decideStartup(
          hasLearnerType: true,
          hasProfile: true,
          onboardingComplete: true,
          answersComplete: true,
          session: guest,
        ),
        StartupDestination.home,
      ),
    );
    test(
      '6 verification-required session is explicit',
      () => expect(
        const AuthSession(status: AuthStatus.emailVerificationRequired).status,
        AuthStatus.emailVerificationRequired,
      ),
    );
    test(
      '6b verification-required startup routes to verification',
      () => expect(
        decideStartup(
          hasLearnerType: true,
          hasProfile: true,
          onboardingComplete: true,
          answersComplete: true,
          session: const AuthSession(
            status: AuthStatus.emailVerificationRequired,
          ),
        ),
        StartupDestination.emailVerification,
      ),
    );
  });
  group('story content repository', () {
    final repo = LocalStoryRepository();
    test(
      '7 story loads',
      () async => expect(
        (await repo.getStory('first-encounter'))?.title,
        contains('İlk Karşılaşma'),
      ),
    );
    test(
      '8 unknown story safe null',
      () async => expect(await repo.getStory('unknown'), isNull),
    );
    test(
      '9 world query',
      () async =>
          expect(await repo.getStoriesForWorld('deniz-kralligi'), hasLength(4)),
    );
    test(
      '10 chapter query',
      () async => expect(
        (await repo.getChaptersForWorld(
          'deniz-kralligi',
        )).map((chapter) => chapter.id),
        containsAll({
          'duygular',
          'hava-durumu',
          'ulasim-araclari',
          'yolculuk-hazirligi',
        }),
      ),
    );
    test('11 real branch paths differ', () async {
      final s = (await repo.getStory('weather-storm'))!;
      final choices = s.nodes['umbrella-choice']!.choices;
      expect(
        choices[0].outcome.nextNodeId,
        isNot(choices[1].outcome.nextNodeId),
      );
    });
    test('12 branch paths converge', () async {
      final s = (await repo.getStory('weather-storm'))!;
      expect(
        s.nodes['safe-harbour']!.nextNodeId,
        s.nodes['rainy-harbour']!.nextNodeId,
      );
    });
    test('13 learner eligibility', () async {
      final s = (await repo.getStory('first-encounter'))!;
      expect(s.isEligible(LearnerType.child, 1), isTrue);
    });
    test('14 metadata contains listening', () async {
      final s = (await repo.getStory('weather-storm'))!;
      expect(s.chapter.hasListening, isTrue);
    });
  });
  group('progression and acceptance', () {
    LearningEvent first({DateTime? date}) => LearningEvent.storyCompleted(
      storyId: 'first-encounter',
      chapterId: 'first-encounter',
      worldId: 'yasam-vadisi',
      minutes: 3,
      xp: 10,
      seedGrowth: 1,
      nextChapterId: 'hava-durumu',
      date: date,
    );
    LearningEvent weather({DateTime? date}) => LearningEvent.storyCompleted(
      storyId: 'weather-storm',
      chapterId: 'hava-durumu',
      worldId: 'deniz-kralligi',
      minutes: 15,
      xp: 25,
      seedGrowth: 1,
      nextChapterId: 'ulasim-araclari',
      date: date,
    );
    test('15 completion and seed', () {
      final p = const AgainProgress().apply(first());
      expect(
        [p.firstSeedEarned, p.completedChapterIds.contains('first-encounter')],
        [true, true],
      );
    });
    test('16 XP awarded once', () {
      final p = const AgainProgress().apply(first());
      expect(p.apply(first()).totalXp, 10);
    });
    test('17 chapter unlock', () {
      final p = const AgainProgress().apply(first());
      expect(p.unlockedChapterIds.contains('hava-durumu'), isTrue);
    });
    test('18 world unlock', () {
      final p = const AgainProgress().apply(first());
      expect(p.unlockedWorldIds.contains('deniz-kralligi'), isTrue);
    });
    test('19 weather completion updates activity', () {
      final p = const AgainProgress().apply(first()).apply(weather());
      expect([p.totalXp, p.dailyLearningMinutes()], [35, 18]);
    });
    test('20 world progress derivation', () {
      final p = const AgainProgress().apply(first()).apply(weather());
      expect(p.worldProgress(const ['hava-durumu']), 100);
    });
    test('21 partially completed world remains current', () {
      final p = const AgainProgress().apply(first()).apply(weather());
      expect(worldRegionsFrom(p).last.state, WorldRegionState.current);
      expect(worldRegionsFrom(p).last.progress, .25);
    });
    test('22 chapter completed derivation', () {
      final p = const AgainProgress().apply(first()).apply(weather());
      expect(
        denizChaptersFrom(p).where((c) => c.id == 'hava-durumu').single.state,
        ChapterState.completed,
      );
    });
    test('23 locked placeholder cannot start', () {
      expect(
        denizChaptersFrom(
          const AgainProgress(),
        ).where((c) => c.id == 'deniz-canlilari').single.isSelectable,
        isFalse,
      );
    });
    test('24 word save uses IDs', () {
      final p = const AgainProgress().apply(LearningEvent.wordSaved('cloudy'));
      expect(
        [
          p.savedWordIds.contains('cloudy'),
          p.learnedWordIds.contains('cloudy'),
        ],
        [true, true],
      );
    });
    test('25 review updates today task source', () {
      final p = const AgainProgress().apply(
        LearningEvent.vocabularyReviewed('cloudy'),
      );
      expect(p.activityFor(DateTime.now()).vocabularyReviews, 1);
    });
    test('26 listening is idempotent', () {
      final e = LearningEvent.listeningCompleted('weather-audio');
      final p = const AgainProgress().apply(e).apply(e);
      expect(p.activityFor(DateTime.now()).listeningCount, 1);
    });
    test('27 speaking requires real event', () {
      expect(const AgainProgress().speakingMinutes, 0);
    });
    test('28 daily reward idempotent', () {
      final e = LearningEvent.dailyRewardClaimed('daily', xp: 5, seedGrowth: 1);
      expect(const AgainProgress().apply(e).apply(e).totalXp, 5);
    });
    test('29 current streak from dates', () {
      final now = DateTime(2026, 8, 9);
      final p = AgainProgress(
        activityHistory: [
          DailyActivity(date: now, learningMinutes: 1),
          DailyActivity(
            date: now.subtract(const Duration(days: 1)),
            learningMinutes: 2,
          ),
        ],
      );
      expect(p.streakAt(now), 2);
    });
    test('30 longest streak from dates', () {
      final d = DateTime(2026, 8, 9);
      final p = AgainProgress(
        activityHistory: [
          for (var i in [0, 1, 3, 4, 5])
            DailyActivity(
              date: d.subtract(Duration(days: i)),
              learningMinutes: 1,
            ),
        ],
      );
      expect(p.longestStreak, 3);
    });
    test('31 weekly minutes', () {
      final d = DateTime(2026, 8, 9);
      final p = AgainProgress(
        activityHistory: [
          DailyActivity(date: d, learningMinutes: 4),
          DailyActivity(
            date: d.subtract(const Duration(days: 1)),
            learningMinutes: 6,
          ),
        ],
      );
      expect(p.weeklyMinutes(d), 10);
    });
    test('32 persistence restart round trip', () async {
      final repo = MemoryProgressionRepository();
      final p = const AgainProgress()
          .apply(first())
          .apply(weather())
          .apply(LearningEvent.wordSaved('rain'));
      await repo.save(p);
      final restarted = await repo.read();
      expect(
        [restarted.totalXp, restarted.savedWordIds.contains('rain')],
        [35, true],
      );
    });
    test('33 profile statistics source is consistent', () {
      final p = const AgainProgress()
          .apply(first())
          .apply(LearningEvent.wordSaved('hello'));
      expect(
        [p.totalXp, p.completedStoryIds.length, p.learnedWordIds.length],
        [10, 1, 1],
      );
    });
    test('34 task source reacts to story event', () {
      final p = const AgainProgress().apply(weather());
      expect(p.activityFor(DateTime.now()).storyCount, 1);
    });
    test('35 exact replay acceptance keeps rewards', () {
      final p = const AgainProgress()
          .apply(first())
          .apply(weather())
          .apply(weather());
      expect(
        [p.totalXp, p.seedGrowth, p.activityFor(DateTime.now()).storyCount],
        [35, 2, 2],
      );
    });
  });
}
