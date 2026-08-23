import '../../learner_profile/domain/learner_type.dart';
import '../../progression/domain/again_progress.dart';
import '../../story/domain/story_catalog.dart';
import '../../story/domain/story_definition.dart';

enum HomeLearningPriorityKind {
  activeStory,
  nextStory,
  vocabulary,
  world,
  complete,
}

class HomeLearningPriority {
  const HomeLearningPriority({
    required this.kind,
    required this.route,
    this.story,
    this.worldId,
  });

  final HomeLearningPriorityKind kind;
  final String route;
  final StoryDefinition? story;
  final String? worldId;
}

HomeLearningPriority resolveHomeLearningPriority({
  required AgainProgress progress,
  required StoryCatalog catalog,
  required int dueWords,
  required LearnerType? learnerType,
  Set<String> goals = const {},
  Set<String> interests = const {},
  int learnerLevel = 1,
}) {
  bool eligible(StoryDefinition story) =>
      learnerType == null || story.isEligible(learnerType, learnerLevel);
  bool playable(StoryDefinition story) =>
      eligible(story) &&
      progress.unlockedWorldIds.contains(story.worldId) &&
      progress.unlockedChapterIds.contains(story.chapter.id) &&
      !progress.completedStoryIds.contains(story.id) &&
      !progress.completedChapterIds.contains(story.chapter.id);

  final current = catalog
      .byChapter(progress.currentChapterId ?? '')
      .where(
        (story) => story.worldId == progress.currentWorldId && playable(story),
      );
  if (current.isNotEmpty) {
    final story = current.first;
    return HomeLearningPriority(
      kind: HomeLearningPriorityKind.activeStory,
      story: story,
      worldId: story.worldId,
      route: _storyRoute(story),
    );
  }

  final accessible = catalog.all.where(playable).toList()
    ..sort((a, b) {
      final currentWorld = progress.currentWorldId;
      final aCurrent = a.worldId == currentWorld ? 0 : 1;
      final bCurrent = b.worldId == currentWorld ? 0 : 1;
      final byWorld = aCurrent.compareTo(bCurrent);
      if (byWorld != 0) return byWorld;
      final byPreference = _preferenceScore(
        b,
        goals,
        interests,
      ).compareTo(_preferenceScore(a, goals, interests));
      return byPreference != 0
          ? byPreference
          : a.catalogOrder.compareTo(b.catalogOrder);
    });
  if (accessible.isNotEmpty) {
    final story = accessible.first;
    return HomeLearningPriority(
      kind: HomeLearningPriorityKind.nextStory,
      story: story,
      worldId: story.worldId,
      route: _storyRoute(story),
    );
  }

  if (dueWords > 0) {
    return const HomeLearningPriority(
      kind: HomeLearningPriorityKind.vocabulary,
      route: '/vocabulary',
    );
  }

  final currentWorld = progress.currentWorldId;
  if (currentWorld != null &&
      progress.unlockedWorldIds.contains(currentWorld)) {
    return HomeLearningPriority(
      kind: HomeLearningPriorityKind.world,
      route: '/world/$currentWorld',
      worldId: currentWorld,
    );
  }
  return const HomeLearningPriority(
    kind: HomeLearningPriorityKind.complete,
    route: '/map',
  );
}

String _storyRoute(StoryDefinition story) =>
    '/world/${story.worldId}/chapter/${story.chapter.id}';

int _preferenceScore(
  StoryDefinition story,
  Set<String> goals,
  Set<String> interests,
) {
  final hints = <String>{
    for (final value in [...goals, ...interests])
      ...switch (value) {
        'Seyahat' ||
        'Seyahat etmek' ||
        'Yurt dışında yaşamak' => {'travel', 'transport', 'directions'},
        'Günlük yaşam' || 'Günlük konuşmak' => {'daily-life', 'introductions'},
        'Gizem' => {'mystery', 'exploration'},
        'Konuşma korkumu yenmek' => {'introductions', 'feelings'},
        _ => const <String>{},
      },
  };
  final tags = {...story.tags, ...?story.learning?.interestTags};
  return tags.intersection(hints).length;
}
