import 'dart:io';

import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/story/data/story_repository.dart';
import 'package:again/features/story/domain/story_catalog.dart';
import 'package:again/features/story/domain/story_definition.dart';
import 'package:again/features/story/domain/story_entry.dart';
import 'package:again/features/world/domain/world_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedStoryIds = {
    'first-encounter',
    'ben-kimim',
    'gunluk-hayat',
    'sevdigim-seyler',
    'kucuk-bir-gun',
    'ormana-giris',
    'kaybolan-yol',
    'gece-sesleri',
    'duygular',
    'weather-storm',
    'ulasim-araclari',
    'yolculuk-hazirligi',
  };

  final unlocked = AgainProgress(
    unlockedWorldIds: const {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'},
    unlockedChapterIds: {
      for (final story in localStoryCatalog.all) story.chapter.id,
    },
  );

  test('all 12 playable entries resolve to their own generic story input', () {
    final resolver = StoryEntryResolver(localStoryCatalog);
    final resolvedIds = <String>{};
    for (final story in localStoryCatalog.all) {
      final result = resolver.resolve(
        worldId: story.worldId,
        chapterId: story.chapter.id,
        progress: unlocked,
      );
      expect(result.status, StoryEntryStatus.playable, reason: story.id);
      expect(result.story?.id, story.id, reason: story.chapter.id);
      resolvedIds.add(result.story!.id);
    }
    expect(resolvedIds, expectedStoryIds);
  });

  test('weather chapter preserves the stable weather-storm story ID', () {
    final result = StoryEntryResolver(localStoryCatalog).resolve(
      worldId: 'deniz-kralligi',
      chapterId: 'hava-durumu',
      progress: unlocked,
    );
    expect(result.status, StoryEntryStatus.playable);
    expect(result.story?.id, 'weather-storm');
  });

  test('first encounter owns typed cover and two data-driven scenes', () {
    final story = localStories['first-encounter']!;
    expect(story.id, 'first-encounter');
    expect(story.coverVisual?.assetPath, endsWith('cover_v1.webp'));
    expect(story.coverVisual?.accessibilityDescription, isNotEmpty);
    expect(story.nodes.values.map((node) => node.scene.id).toSet(), {
      'valley-arrival',
      'valley-meeting',
    });
    for (final scene in story.nodes.values.map((node) => node.scene).toSet()) {
      expect(scene.visual?.assetPath, endsWith('.webp'));
      expect(scene.visual?.accessibilityDescription, isNotEmpty);
      expect(scene.visual!.overlayStrength, inInclusiveRange(0, 1));
    }
  });

  test('all five valley stories expose resolvable visual metadata', () {
    const expected = {
      'first-encounter',
      'ben-kimim',
      'gunluk-hayat',
      'sevdigim-seyler',
      'kucuk-bir-gun',
    };
    final stories = localStoryCatalog.byWorld('yasam-vadisi');
    expect(stories.map((story) => story.id).toSet(), expected);
    for (final story in stories) {
      final cover = story.coverVisual;
      expect(cover, isNotNull, reason: '${story.id} cover');
      expect(
        File(cover!.assetPath).existsSync(),
        isTrue,
        reason: cover.assetPath,
      );
      expect(cover.accessibilityDescription, isNotEmpty);
      final scenes = story.nodes.values.map((node) => node.scene).toSet();
      for (final scene in scenes) {
        final visual = scene.visual;
        expect(visual, isNotNull, reason: '${story.id}:${scene.id}');
        expect(
          File(visual!.assetPath).existsSync(),
          isTrue,
          reason: visual.assetPath,
        );
        expect(visual.accessibilityDescription, isNotEmpty);
      }
    }
  });

  test('all three forest stories expose resolvable visual metadata', () {
    const expected = {'ormana-giris', 'kaybolan-yol', 'gece-sesleri'};
    final stories = localStoryCatalog.byWorld('sessiz-orman');
    expect(stories.map((story) => story.id).toSet(), expected);
    for (final story in stories) {
      final cover = story.coverVisual;
      expect(cover, isNotNull, reason: '${story.id} cover');
      expect(
        File(cover!.assetPath).existsSync(),
        isTrue,
        reason: cover.assetPath,
      );
      expect(cover.accessibilityDescription, isNotEmpty);
      for (final scene
          in story.nodes.values.map((node) => node.scene).toSet()) {
        final visual = scene.visual;
        expect(visual, isNotNull, reason: '${story.id}:${scene.id}');
        expect(
          File(visual!.assetPath).existsSync(),
          isTrue,
          reason: visual.assetPath,
        );
        expect(visual.accessibilityDescription, isNotEmpty);
      }
    }
  });

  test('all four sea stories expose resolvable visual metadata', () {
    const expected = {
      'duygular',
      'weather-storm',
      'ulasim-araclari',
      'yolculuk-hazirligi',
    };
    final stories = localStoryCatalog.byWorld('deniz-kralligi');
    expect(stories.map((story) => story.id).toSet(), expected);
    for (final story in stories) {
      final cover = story.coverVisual;
      expect(cover, isNotNull, reason: '${story.id} cover');
      expect(
        File(cover!.assetPath).existsSync(),
        isTrue,
        reason: cover.assetPath,
      );
      expect(cover.accessibilityDescription, isNotEmpty);
      for (final scene
          in story.nodes.values.map((node) => node.scene).toSet()) {
        final visual = scene.visual;
        expect(visual, isNotNull, reason: '${story.id}:${scene.id}');
        expect(
          File(visual!.assetPath).existsSync(),
          isTrue,
          reason: visual.assetPath,
        );
        expect(visual.accessibilityDescription, isNotEmpty);
      }
    }
  });

  test(
    'locked story cannot bypass progression and becomes enterable later',
    () {
      final resolver = StoryEntryResolver(localStoryCatalog);
      final locked = resolver.resolve(
        worldId: 'sessiz-orman',
        chapterId: 'kaybolan-yol',
        progress: const AgainProgress(
          unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman'},
          unlockedChapterIds: {'first-encounter', 'ormana-giris'},
        ),
      );
      expect(locked.status, StoryEntryStatus.locked);

      final available = resolver.resolve(
        worldId: 'sessiz-orman',
        chapterId: 'kaybolan-yol',
        progress: const AgainProgress(
          unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman'},
          unlockedChapterIds: {
            'first-encounter',
            'ormana-giris',
            'kaybolan-yol',
          },
        ),
      );
      expect(available.status, StoryEntryStatus.playable);
      expect(available.story?.id, 'kaybolan-yol');
    },
  );

  test('unknown, wrong-world and future chapters fail safely', () {
    final resolver = StoryEntryResolver(localStoryCatalog);
    for (final entry in [
      ('deniz-kralligi', 'unknown'),
      ('yasam-vadisi', 'hava-durumu'),
      ('deniz-kralligi', 'seyahat-plani'),
      ('deniz-kralligi', 'deniz-canlilari'),
      ('sessiz-orman', 'eski-kulube'),
    ]) {
      expect(
        resolver
            .resolve(worldId: entry.$1, chapterId: entry.$2, progress: unlocked)
            .status,
        StoryEntryStatus.unavailable,
        reason: entry.$2,
      );
    }
  });

  test('a thirteenth content definition needs no resolver case', () {
    const scene = StoryScene(id: 'test-scene', artKey: 'test');
    const extra = StoryDefinition(
      id: 'content-only-story',
      worldId: 'sessiz-orman',
      catalogOrder: 99,
      chapter: StoryChapter(
        id: 'content-only-chapter',
        number: 99,
        durationMinutes: 1,
        vocabularyCount: 0,
      ),
      title: 'Content only',
      description: 'Scalability fixture',
      startNodeId: 'done',
      nodes: {
        'done': StoryNode(
          id: 'done',
          scene: scene,
          kind: StoryNodeKind.completion,
          englishText: 'Done.',
        ),
      },
      reward: StoryReward(xp: 0),
      learning: StoryLearningMetadata(
        cefr: CefrLevel.a1,
        learningGoals: ['Prove content-only routing'],
        grammarTargets: [],
        skillFocus: {StorySkill.reading},
      ),
    );
    final catalog = StoryCatalog([...localStoryCatalog.all, extra]);
    final result = StoryEntryResolver(catalog).resolve(
      worldId: extra.worldId,
      chapterId: extra.chapter.id,
      progress: AgainProgress(
        unlockedChapterIds: const {'first-encounter', 'content-only-chapter'},
      ),
    );
    expect(result.status, StoryEntryStatus.playable);
    expect(result.story?.id, extra.id);
  });

  test('world detail chapter adapters expose every catalog story', () {
    for (final worldId in const [
      'yasam-vadisi',
      'sessiz-orman',
      'deniz-kralligi',
    ]) {
      final stories = localStoryCatalog.byWorld(worldId);
      final chapters = catalogChaptersForWorld(
        localStoryCatalog,
        worldId,
        unlocked,
      );
      expect(
        chapters.map((chapter) => chapter.id),
        stories.map((story) => story.chapter.id),
      );
      expect(chapters.every((chapter) => chapter.isSelectable), isTrue);
    }
  });

  test('first encounter cover reaches the generic chapter adapter', () {
    final chapter = catalogChaptersForWorld(
      localStoryCatalog,
      'yasam-vadisi',
      unlocked,
    ).first;
    expect(chapter.id, 'first-encounter');
    expect(
      chapter.coverAsset,
      localStories['first-encounter']!.coverVisual!.assetPath,
    );
  });
}
