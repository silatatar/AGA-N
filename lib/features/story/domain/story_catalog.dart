import '../../learner_profile/domain/learner_type.dart';
import 'story_definition.dart';

class StoryCatalog {
  StoryCatalog(Iterable<StoryDefinition> stories)
    : _stories = List.unmodifiable(stories);

  final List<StoryDefinition> _stories;
  List<StoryDefinition> get all => _stories;

  StoryDefinition? byId(String id) {
    for (final story in _stories) {
      if (story.id == id) return story;
    }
    return null;
  }

  List<StoryDefinition> byWorld(String worldId) =>
      _stories.where((story) => story.worldId == worldId).toList()
        ..sort((a, b) => a.catalogOrder.compareTo(b.catalogOrder));
  List<StoryDefinition> byChapter(String chapterId) =>
      _stories.where((story) => story.chapter.id == chapterId).toList();
  List<StoryDefinition> byLevel(CefrLevel level) =>
      _stories.where((story) => story.learning?.cefr == level).toList();
  List<StoryDefinition> byLearnerType(LearnerType type) => _stories
      .where((story) => story.allowedLearnerTypes.contains(type))
      .toList();
  List<StoryDefinition> byTag(String tag) => _stories
      .where(
        (story) =>
            story.tags.contains(tag) ||
            (story.learning?.interestTags.contains(tag) ?? false),
      )
      .toList();
}

class StoryCatalogValidationResult {
  const StoryCatalogValidationResult(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

StoryCatalogValidationResult validateStoryCatalog(
  StoryCatalog catalog, {
  required Set<String> worldIds,
}) {
  final errors = <String>[];
  final storyIds = <String>{};
  for (final story in catalog.all) {
    if (!storyIds.add(story.id)) errors.add('duplicate-story:${story.id}');
    if (!worldIds.contains(story.worldId)) {
      errors.add('invalid-world:${story.id}:${story.worldId}');
    }
    if (story.chapter.id.isEmpty) errors.add('missing-chapter:${story.id}');
    if (story.allowedLearnerTypes.isEmpty) {
      errors.add('missing-learner-eligibility:${story.id}');
    }
    final learning = story.learning;
    if (learning == null) {
      errors.add('missing-learning-metadata:${story.id}');
    } else {
      if (learning.learningGoals.isEmpty) {
        errors.add('missing-learning-goals:${story.id}');
      }
      if (learning.skillFocus.isEmpty) {
        errors.add('missing-skill-focus:${story.id}');
      }
      if (learning.locale.isEmpty) errors.add('missing-locale:${story.id}');
    }
    for (final error in validateStoryDefinition(story).errors) {
      errors.add('${story.id}:$error');
    }
  }
  return StoryCatalogValidationResult(List.unmodifiable(errors));
}
