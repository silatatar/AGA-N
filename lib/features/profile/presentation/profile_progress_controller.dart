import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../vocabulary/domain/vocabulary_entry.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../domain/profile_progress.dart';

final profileProgressProvider = FutureProvider.autoDispose<ProfileProgress>((
  ref,
) async {
  final profile = await ref.watch(learnerProfileProvider.future);
  final learnerType = await ref.watch(learnerSelectionProvider.future);
  final onboarding = await ref.watch(onboardingProvider.future);
  final words = await ref.watch(vocabularyProvider.future);
  final progress = await ref.watch(progressionProvider.future);

  final masteredWords = words
      .where((word) => word.mastery == WordMastery.mastered)
      .length;
  final learnedWords = words
      .where((word) => word.mastery != WordMastery.newWord)
      .length;
  final storyCount = progress.completedChapterIds.length;
  final growth = progress.seedGrowth;
  final milestone = growth < 3
      ? 3
      : growth < 6
      ? 6
      : growth < 10
      ? 10
      : ((growth ~/ 5) + 1) * 5;
  final previousMilestone = milestone == 3
      ? 0
      : milestone == 6
      ? 3
      : milestone == 10
      ? 6
      : milestone - 5;
  final growthProgress =
      ((growth - previousMilestone) / (milestone - previousMilestone)).clamp(
        0.0,
        1.0,
      );
  final numericLevel = progress.totalXp ~/ 200 + 1;

  return ProfileProgress(
    profile: profile,
    learnerType: learnerType,
    levelName: _levelName(onboarding.level),
    numericLevel: numericLevel,
    totalXp: progress.totalXp,
    xpInLevel: progress.totalXp % 200,
    xpForNextLevel: 200,
    statistics: [
      ProfileStatistic(label: 'Öğrenilen kelime', value: '$learnedWords'),
      ProfileStatistic(
        label: 'Konuşma süresi',
        value: '${progress.speakingMinutes} dk',
      ),
      ProfileStatistic(label: 'Tamamlanan hikâye', value: '$storyCount'),
      ProfileStatistic(
        label: 'Haftalık süre',
        value: '${progress.weeklyMinutes()} dk',
      ),
      ProfileStatistic(
        label: 'Güncel seri',
        value: '${progress.currentStreak} gün',
      ),
    ],
    collections: [
      ProfileCollectionItem(
        title: 'Hüma yadigârları',
        count: growth > 0 ? 1 : 0,
        isUnlocked: growth > 0,
      ),
      ProfileCollectionItem(
        title: 'Hikâye kitapları',
        count: storyCount,
        isUnlocked: storyCount > 0,
      ),
      ProfileCollectionItem(
        title: 'Tüyler',
        count: storyCount + masteredWords,
        isUnlocked: storyCount + masteredWords > 0,
      ),
      ProfileCollectionItem(
        title: 'Kaydedilen kelimeler',
        count: progress.savedWordIds.length,
        isUnlocked: progress.savedWordIds.isNotEmpty,
      ),
      ProfileCollectionItem(
        title: 'Dünya eserleri',
        count: storyCount >= 2 ? 1 : 0,
        isUnlocked: storyCount >= 2,
      ),
    ],
    badges: [
      ProfileBadge(title: 'Hikâye', isUnlocked: storyCount > 0),
      ProfileBadge(title: 'Konuşma', isUnlocked: progress.speakingMinutes > 0),
      ProfileBadge(title: 'Kelime', isUnlocked: learnedWords > 0),
      ProfileBadge(title: 'İstikrar', isUnlocked: progress.currentStreak > 0),
      ProfileBadge(title: 'Keşif', isUnlocked: progress.firstSeedEarned),
    ],
    growth: ProfileGrowth(
      points: growth,
      stateName: growth == 0
          ? 'Uyuyan tohum'
          : growth < 3
          ? 'Uyanan tohum'
          : growth < 6
          ? 'İlk filiz'
          : growth < 10
          ? 'Genç fidan'
          : 'Işıklı ağaç',
      nextMilestone: milestone,
      progress: growthProgress,
    ),
  );
});

String _levelName(EnglishLevel? level) => switch (level) {
  EnglishLevel.beginner => 'Başlangıç',
  EnglishLevel.words => 'Temel kelimeler',
  EnglishLevel.simpleSentences => 'Basit cümleler',
  EnglishLevel.conversational => 'Konuşma',
  EnglishLevel.placementTest => 'Değerlendirilecek',
  null => 'Başlangıç',
};
