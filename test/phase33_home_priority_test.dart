import 'package:flutter_test/flutter_test.dart';

import 'package:again/features/home/domain/home_learning_priority.dart';
import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/story/data/story_repository.dart';

void main() {
  group('Phase 33 home learning priority', () {
    test('continues the real active catalog story first', () {
      final result = resolveHomeLearningPriority(
        progress: const AgainProgress(),
        catalog: localStoryCatalog,
        dueWords: 3,
        learnerType: LearnerType.adult,
      );

      expect(result.kind, HomeLearningPriorityKind.activeStory);
      expect(result.story?.id, 'first-encounter');
      expect(result.route, '/world/yasam-vadisi/chapter/first-encounter');
    });

    test('selects the next accessible story before vocabulary review', () {
      final result = resolveHomeLearningPriority(
        progress: const AgainProgress(
          completedStoryIds: {'first-encounter'},
          completedChapterIds: {'first-encounter'},
          unlockedChapterIds: {'first-encounter', 'ben-kimim'},
          unlockedWorldIds: {'yasam-vadisi'},
          currentWorldId: 'yasam-vadisi',
          currentChapterId: null,
        ),
        catalog: localStoryCatalog,
        dueWords: 2,
        learnerType: LearnerType.teen,
      );

      expect(result.kind, HomeLearningPriorityKind.nextStory);
      expect(result.story?.chapter.id, 'ben-kimim');
    });

    test('uses due vocabulary when no unfinished story is accessible', () {
      final allStoryIds = localStoryCatalog.all
          .map((story) => story.id)
          .toSet();
      final allChapterIds = localStoryCatalog.all
          .map((story) => story.chapter.id)
          .toSet();
      final result = resolveHomeLearningPriority(
        progress: AgainProgress(
          completedStoryIds: allStoryIds,
          completedChapterIds: allChapterIds,
          unlockedChapterIds: allChapterIds,
          unlockedWorldIds: const {
            'yasam-vadisi',
            'sessiz-orman',
            'deniz-kralligi',
          },
          currentWorldId: 'deniz-kralligi',
          currentChapterId: null,
        ),
        catalog: localStoryCatalog,
        dueWords: 4,
        learnerType: LearnerType.adult,
      );

      expect(result.kind, HomeLearningPriorityKind.vocabulary);
      expect(result.route, '/vocabulary');
    });

    test('never recommends locked future catalog content', () {
      final result = resolveHomeLearningPriority(
        progress: const AgainProgress(
          unlockedWorldIds: {'yasam-vadisi'},
          unlockedChapterIds: {},
          currentWorldId: 'yasam-vadisi',
          currentChapterId: null,
        ),
        catalog: localStoryCatalog,
        dueWords: 0,
        learnerType: LearnerType.child,
      );

      expect(result.kind, HomeLearningPriorityKind.world);
      expect(result.story, isNull);
      expect(result.route, '/world/yasam-vadisi');
    });

    test('interest breaks a tie only between already playable stories', () {
      final result = resolveHomeLearningPriority(
        progress: const AgainProgress(
          completedStoryIds: {'ormana-giris'},
          completedChapterIds: {'ormana-giris'},
          unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman'},
          unlockedChapterIds: {'kaybolan-yol', 'gece-sesleri'},
          currentWorldId: 'sessiz-orman',
          currentChapterId: null,
        ),
        catalog: localStoryCatalog,
        dueWords: 0,
        learnerType: LearnerType.adult,
        interests: const {'Gizem'},
      );

      expect(result.kind, HomeLearningPriorityKind.nextStory);
      expect(result.story?.id, 'gece-sesleri');
    });
  });
}
