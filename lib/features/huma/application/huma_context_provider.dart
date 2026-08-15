import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
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
  final profile = ref.watch(learnerProfileProvider).value;
  final learner = ref.watch(learnerSelectionProvider).value;
  final preferences =
      ref.watch(onboardingProvider).value ?? const OnboardingPreferences();
  final progress =
      ref.watch(progressionProvider).value ?? const AgainProgress();
  final words = ref.watch(vocabularyProvider).value ?? const [];
  final today = progress.activityFor(DateTime.now());
  final chapter = progress.currentChapterId;
  final activeRoute =
      chapter == 'hava-durumu' &&
          !progress.completedChapterIds.contains(chapter)
      ? '/world/deniz-kralligi/chapter/hava-durumu'
      : null;
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
    dailyTarget: preferences.dailyMinutes ?? 15,
    currentStreak: progress.currentStreak,
    vocabularyCount: words.length,
    vocabularyDueCount: words.where((word) => word.isDue).length,
    storyCompletedToday: today.storyCount > 0,
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
