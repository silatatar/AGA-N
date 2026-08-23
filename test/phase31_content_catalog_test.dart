import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/story/data/story_repository.dart';
import 'package:again/features/story/domain/story_catalog.dart';
import 'package:again/features/story/domain/story_definition.dart';
import 'package:again/features/world/domain/world_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const currentWorldIds = {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'};

  group('Phase 31 content catalog foundation', () {
    test('current bundled content passes catalog validation', () {
      final result = validateStoryCatalog(
        localStoryCatalog,
        worldIds: currentWorldIds,
      );
      expect(result.errors, isEmpty);
    });

    test('stable legacy story IDs remain available', () {
      expect(localStoryCatalog.byId('first-encounter'), isNotNull);
      expect(localStoryCatalog.byId('weather-storm'), isNotNull);
    });

    test('catalog queries by world, level, learner type and tag', () {
      expect(
        localStoryCatalog.byWorld('deniz-kralligi').map((story) => story.id),
        contains('weather-storm'),
      );
      expect(
        localStoryCatalog.byLevel(CefrLevel.a1).map((story) => story.id),
        containsAll({'first-encounter', 'weather-storm'}),
      );
      expect(
        localStoryCatalog
            .byLearnerType(LearnerType.child)
            .map((story) => story.id),
        contains('first-encounter'),
      );
      expect(
        localStoryCatalog.byTag('weather').map((story) => story.id),
        contains('weather-storm'),
      );
    });

    test('every current story has explicit learning metadata', () {
      for (final story in localStoryCatalog.all) {
        expect(story.learning, isNotNull, reason: story.id);
        expect(story.learning!.learningGoals, isNotEmpty, reason: story.id);
        expect(story.learning!.skillFocus, isNotEmpty, reason: story.id);
        expect(story.learning!.locale, 'en-US', reason: story.id);
      }
    });

    test('Yaşam Vadisi has five stories in explicit learning order', () {
      final stories = localStoryCatalog.byWorld('yasam-vadisi');
      expect(stories.map((story) => story.id), [
        'first-encounter',
        'ben-kimim',
        'gunluk-hayat',
        'sevdigim-seyler',
        'kucuk-bir-gun',
      ]);
      expect(stories.map((story) => story.catalogOrder), [1, 2, 3, 4, 5]);
    });

    test('Yaşam Vadisi meets branching and writing quality minimums', () {
      final stories = localStoryCatalog.byWorld('yasam-vadisi');
      final branching = stories.where(
        (story) => story.nodes.values.any(
          (node) =>
              node.choices
                  .map((choice) => choice.outcome.nextNodeId)
                  .toSet()
                  .length >
              1,
        ),
      );
      final writing = stories.where(
        (story) => story.nodes.values.any(
          (node) => node.kind == StoryNodeKind.writing,
        ),
      );
      expect(branching.length, greaterThanOrEqualTo(3));
      expect(writing.length, greaterThanOrEqualTo(2));
    });

    test('Yaşam Vadisi stories remain fully text-completable', () {
      for (final story in localStoryCatalog.byWorld('yasam-vadisi')) {
        expect(
          validateStoryDefinition(story).isValid,
          isTrue,
          reason: story.id,
        );
        expect(
          story.nodes.values.where(
            (node) => node.kind == StoryNodeKind.speaking,
          ),
          isEmpty,
          reason: '${story.id} must not require unverified voice',
        );
      }
    });
  });

  group('Phase 31 Yaşam Vadisi progression', () {
    AgainProgress complete(AgainProgress progress, String storyId) {
      final story = localStoryCatalog.byId(storyId)!;
      return progress.apply(
        LearningEvent.storyCompleted(
          storyId: story.id,
          chapterId: story.chapter.id,
          worldId: story.worldId,
          minutes: story.chapter.durationMinutes,
          xp: story.reward.xp,
          seedGrowth: story.reward.seedGrowth,
          nextChapterId: story.chapter.nextChapterId,
          date: DateTime(2026, 8, 17),
        ),
      );
    }

    test('new chapters unlock in the catalog sequence', () {
      var progress = const AgainProgress();
      for (final story in localStoryCatalog.byWorld('yasam-vadisi')) {
        expect(progress.unlockedChapterIds, contains(story.chapter.id));
        progress = complete(progress, story.id);
      }
      expect(
        progress.completedChapterIds,
        containsAll({
          'first-encounter',
          'ben-kimim',
          'gunluk-hayat',
          'sevdigim-seyler',
          'kucuk-bir-gun',
        }),
      );
      expect(worldRegionsFrom(progress).first.progress, 1);
    });

    test('replaying a new story does not duplicate XP or seed growth', () {
      var progress = const AgainProgress(
        unlockedChapterIds: {'first-encounter', 'ben-kimim'},
      );
      progress = complete(progress, 'ben-kimim');
      final xp = progress.totalXp;
      final growth = progress.seedGrowth;
      progress = complete(progress, 'ben-kimim');
      expect(progress.totalXp, xp);
      expect(progress.seedGrowth, growth);
      expect(
        progress.completedStoryIds.where((id) => id == 'ben-kimim'),
        hasLength(1),
      );
    });

    test('progress and new vocabulary survive persistence round trip', () {
      var progress = complete(const AgainProgress(), 'first-encounter');
      progress = complete(progress, 'ben-kimim');
      progress = progress.apply(
        LearningEvent.wordSaved('music', date: DateTime(2026, 8, 17)),
      );
      final restored = AgainProgress.fromJson(progress.toJson());

      expect(
        restored.completedChapterIds,
        containsAll({'first-encounter', 'ben-kimim'}),
      );
      expect(restored.unlockedChapterIds, contains('gunluk-hayat'));
      expect(restored.savedWordIds, contains('music'));
      expect(restored.totalXp, progress.totalXp);
      expect(localStoryCatalog.byId('ben-kimim')!.worldId, 'yasam-vadisi');

      final replayed = complete(restored, 'ben-kimim');
      expect(replayed.totalXp, restored.totalXp);
    });

    test('legacy first encounter completion remains valid', () {
      final legacy = const AgainProgress(
        completedStoryIds: {'first-encounter'},
        completedChapterIds: {'first-encounter'},
        unlockedChapterIds: {'first-encounter'},
        totalXp: 10,
      );
      expect(localStoryCatalog.byId('first-encounter'), isNotNull);
      expect(legacy.completedChapterIds, contains('first-encounter'));
      expect(complete(legacy, 'first-encounter').totalXp, 10);
      final restored = AgainProgress.fromJson(legacy.toJson());
      expect(restored.unlockedChapterIds, contains('ben-kimim'));
    });

    test('Slice 2 catalogs have explicit order and valid content', () {
      final forest = localStoryCatalog.byWorld('sessiz-orman');
      final sea = localStoryCatalog.byWorld('deniz-kralligi');
      expect(forest.map((story) => story.id), [
        'ormana-giris',
        'kaybolan-yol',
        'gece-sesleri',
      ]);
      expect(sea.map((story) => story.id), [
        'duygular',
        'weather-storm',
        'ulasim-araclari',
        'yolculuk-hazirligi',
      ]);
      for (final story in [...forest, ...sea]) {
        expect(
          validateStoryDefinition(story).isValid,
          isTrue,
          reason: story.id,
        );
        expect(story.learning, isNotNull, reason: story.id);
        expect(
          story.chapter.vocabularyCount,
          inInclusiveRange(5, 10),
          reason: story.id,
        );
      }
    });

    test('Slice 2 meets genuine branching and writing targets', () {
      final stories = [
        ...localStoryCatalog.byWorld('sessiz-orman'),
        ...localStoryCatalog.byWorld('deniz-kralligi'),
      ];
      final branching = stories.where(
        (story) => story.nodes.values.any(
          (node) =>
              node.choices
                  .map((choice) => choice.outcome.nextNodeId)
                  .toSet()
                  .length >
              1,
        ),
      );
      final writing = stories.where(
        (story) => story.nodes.values.any(
          (node) => node.kind == StoryNodeKind.writing,
        ),
      );
      expect(branching.length, greaterThanOrEqualTo(5));
      expect(writing.length, greaterThanOrEqualTo(2));
    });

    test('forest and sea progression chains complete once', () {
      var progress = const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'},
        unlockedChapterIds: {'first-encounter', 'ormana-giris', 'duygular'},
      );
      for (final story in localStoryCatalog.byWorld('sessiz-orman')) {
        expect(progress.unlockedChapterIds, contains(story.chapter.id));
        progress = complete(progress, story.id);
      }
      for (final story in localStoryCatalog.byWorld('deniz-kralligi')) {
        expect(progress.unlockedChapterIds, contains(story.chapter.id));
        progress = complete(progress, story.id);
      }
      expect(worldRegionsFrom(progress)[1].progress, 1);
      expect(worldRegionsFrom(progress)[2].progress, 1);
      final beforeReplay = progress.totalXp;
      progress = complete(progress, 'weather-storm');
      expect(progress.totalXp, beforeReplay);
    });

    test('Slice 2 completion and vocabulary persist on restart', () {
      var progress = const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman'},
        unlockedChapterIds: {'first-encounter', 'ormana-giris'},
      );
      progress = complete(progress, 'ormana-giris');
      progress = complete(progress, 'kaybolan-yol');
      progress = progress.apply(
        LearningEvent.wordSaved('bridge', date: DateTime(2026, 8, 17)),
      );
      final restored = AgainProgress.fromJson(progress.toJson());
      expect(
        restored.completedChapterIds,
        containsAll({'ormana-giris', 'kaybolan-yol'}),
      );
      expect(restored.unlockedChapterIds, contains('gece-sesleri'));
      expect(restored.savedWordIds, contains('bridge'));
      expect(restored.totalXp, progress.totalXp);
    });
  });
}
