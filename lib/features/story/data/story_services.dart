import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';

abstract interface class StoryAudioService {
  Future<void> playPhrase(String phrase);
  Future<void> pause();
  Future<void> replayPhrase(String phrase);
}

/// Development adapter until narrated audio assets are connected.
class DevelopmentStoryAudioService implements StoryAudioService {
  @override
  Future<void> playPhrase(String phrase) =>
      Future<void>.delayed(const Duration(milliseconds: 850));

  @override
  Future<void> pause() async {}

  @override
  Future<void> replayPhrase(String phrase) => playPhrase(phrase);
}

abstract interface class StoryProgressRepository {
  Future<void> awardFirstSeed();
  Future<bool> hasFirstSeed();
  Future<void> saveWord(String word);
  Future<void> removeWord(String word);
  Future<void> completeChapter({
    required String chapterId,
    required int minutes,
    required int xp,
  });
  Future<void> completeVocabularyReview();
  Future<void> claimDailyReward({
    required String taskId,
    required int xp,
    required int seedGrowth,
  });
  Future<StoryProgressSnapshot> readSnapshot();
}

class StoryProgressSnapshot {
  const StoryProgressSnapshot({
    required this.hasFirstSeed,
    required this.savedWords,
    required this.completedChapters,
    required this.minutesToday,
    required this.totalXp,
    required this.listeningActivities,
    required this.speakingMinutes,
    required this.vocabularyReviews,
    required this.claimedTaskRewards,
    required this.rewardSeedGrowth,
  });

  final bool hasFirstSeed;
  final Set<String> savedWords;
  final Set<String> completedChapters;
  final int minutesToday;
  final int totalXp;
  final int listeningActivities;
  final int speakingMinutes;
  final int vocabularyReviews;
  final Set<String> claimedTaskRewards;
  final int rewardSeedGrowth;

  int get seedGrowth =>
      (hasFirstSeed ? 1 : 0) + completedChapters.length + rewardSeedGrowth;
}

class ProgressionStoryProgressRepository implements StoryProgressRepository {
  ProgressionStoryProgressRepository(this.ref);
  final Ref ref;
  Future<AgainProgress> get _progress => ref.read(progressionProvider.future);
  @override
  Future<void> awardFirstSeed() async {}
  @override
  Future<bool> hasFirstSeed() async => (await _progress).firstSeedEarned;
  @override
  Future<void> saveWord(String word) => ref
      .read(progressionProvider.notifier)
      .record(LearningEvent.wordSaved(word));
  @override
  Future<void> removeWord(String word) => ref
      .read(progressionProvider.notifier)
      .record(LearningEvent.wordRemoved(word));
  @override
  Future<void> completeChapter({
    required String chapterId,
    required int minutes,
    required int xp,
  }) => ref
      .read(progressionProvider.notifier)
      .record(
        LearningEvent.storyCompleted(
          storyId: chapterId,
          chapterId: chapterId,
          worldId: chapterId == 'hava-durumu'
              ? 'deniz-kralligi'
              : 'yasam-vadisi',
          minutes: minutes,
          xp: xp,
          seedGrowth: 1,
          nextChapterId: chapterId == 'first-encounter'
              ? 'hava-durumu'
              : chapterId == 'hava-durumu'
              ? 'ulasim-araclari'
              : null,
        ),
      );
  @override
  Future<void> completeVocabularyReview() => ref
      .read(progressionProvider.notifier)
      .record(LearningEvent.vocabularyReviewed('review'));
  @override
  Future<void> claimDailyReward({
    required String taskId,
    required int xp,
    required int seedGrowth,
  }) => ref
      .read(progressionProvider.notifier)
      .record(
        LearningEvent.dailyRewardClaimed(
          taskId,
          xp: xp,
          seedGrowth: seedGrowth,
        ),
      );
  @override
  Future<StoryProgressSnapshot> readSnapshot() async {
    final p = await _progress;
    final today = p.activityFor(DateTime.now());
    return StoryProgressSnapshot(
      hasFirstSeed: p.firstSeedEarned,
      savedWords: p.savedWordIds,
      completedChapters: p.completedChapterIds,
      minutesToday: today.learningMinutes,
      totalXp: p.totalXp,
      listeningActivities: today.listeningCount,
      speakingMinutes: today.speakingMinutes,
      vocabularyReviews: today.vocabularyReviews,
      claimedTaskRewards: p.claimedDailyRewards,
      rewardSeedGrowth:
          p.seedGrowth -
          (p.firstSeedEarned ? 1 : 0) -
          p.completedChapterIds.length,
    );
  }
}

final storyAudioServiceProvider = Provider<StoryAudioService>(
  (ref) => DevelopmentStoryAudioService(),
);
final storyProgressRepositoryProvider = Provider<StoryProgressRepository>(
  (ref) => ProgressionStoryProgressRepository(ref),
);
