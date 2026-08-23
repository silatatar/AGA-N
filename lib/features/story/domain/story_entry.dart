import '../../progression/domain/again_progress.dart';
import 'story_catalog.dart';
import 'story_definition.dart';

enum StoryEntryStatus { playable, locked, unavailable }

class StoryEntryResolution {
  const StoryEntryResolution(this.status, {this.story});

  final StoryEntryStatus status;
  final StoryDefinition? story;
}

class StoryEntryResolver {
  const StoryEntryResolver(this.catalog);

  final StoryCatalog catalog;

  StoryEntryResolution resolve({
    required String worldId,
    required String chapterId,
    required AgainProgress progress,
  }) {
    final matches = catalog
        .byChapter(chapterId)
        .where((story) => story.worldId == worldId)
        .toList();
    if (matches.length != 1) {
      return const StoryEntryResolution(StoryEntryStatus.unavailable);
    }
    final story = matches.single;
    final accessible =
        progress.unlockedChapterIds.contains(story.chapter.id) ||
        progress.completedChapterIds.contains(story.chapter.id);
    return StoryEntryResolution(
      accessible ? StoryEntryStatus.playable : StoryEntryStatus.locked,
      story: story,
    );
  }
}
