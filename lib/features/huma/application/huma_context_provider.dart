import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learner_profile/presentation/learner_personalization_provider.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../story/data/story_repository.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../domain/huma_models.dart';
import 'huma_guidance_engine.dart';

final humaGuidanceEngineProvider = Provider<HumaGuidanceEngine>(
  (_) => const HumaGuidanceEngine(),
);

final humaContextProvider = Provider.family<HumaContext, HumaScreen>((
  ref,
  screen,
) {
  final personalization = ref.watch(learnerPersonalizationProvider).value;
  final profile = personalization?.identity;
  final learner = personalization?.learnerType;
  final preferences =
      personalization?.preferences ?? const OnboardingPreferences();
  final progress =
      ref.watch(progressionProvider).value ?? const AgainProgress();
  final words = ref.watch(vocabularyProvider).value ?? const [];
  final today = progress.activityFor(DateTime.now());
  final chapter = progress.currentChapterId;
  final activeStories = localStoryCatalog
      .byChapter(chapter ?? '')
      .where(
        (story) =>
            story.worldId == progress.currentWorldId &&
            progress.unlockedWorldIds.contains(story.worldId) &&
            progress.unlockedChapterIds.contains(story.chapter.id) &&
            !progress.completedStoryIds.contains(story.id) &&
            !progress.completedChapterIds.contains(story.chapter.id),
      );
  final activeStory = activeStories.isEmpty ? null : activeStories.first;
  final activeRoute = activeStory == null
      ? null
      : '/world/${activeStory.worldId}/chapter/${activeStory.chapter.id}';
  return HumaContext(
    screen: screen,
    learnerName: profile?.displayName ?? 'Gezgin',
    learnerType: learner,
    level: preferences.level,
    firstTimeUser: profile == null && learner == null,
    returningUser: profile != null,
    currentWorldId: progress.currentWorldId,
    currentChapterId: chapter,
    activeStoryRoute: activeRoute,
    dailyMinutes: today.learningMinutes,
    dailyTarget: preferences.dailyMinutes ?? 0,
    currentStreak: progress.currentStreak,
    vocabularyCount: words.length,
    vocabularyDueCount: words.where((word) => word.isDue).length,
    storyCompletedToday: today.storyCount > 0,
    goals: preferences.goals,
    interests: preferences.interests,
  );
});

final humaMessageProvider = Provider.family<HumaMessage, HumaScreen>((
  ref,
  screen,
) {
  return ref
      .read(humaGuidanceEngineProvider)
      .select(ref.watch(humaContextProvider(screen)));
});
