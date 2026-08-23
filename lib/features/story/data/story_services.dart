import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../voice/application/voice_providers.dart';
import '../../voice/domain/voice_models.dart';
import '../../voice/domain/voice_services.dart';

abstract interface class StoryAudioService {
  Future<void> playPhrase(String phrase);
  Future<void> pause();
  Future<void> replayPhrase(String phrase);
}

class StoryAudioUnavailable implements Exception {
  const StoryAudioUnavailable();
}

/// Honest default until a real narrated-audio or TTS adapter is connected.
class UnconfiguredStoryAudioService implements StoryAudioService {
  @override
  Future<void> playPhrase(String phrase) async {
    throw const StoryAudioUnavailable();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> replayPhrase(String phrase) => playPhrase(phrase);
}

class TtsStoryAudioService implements StoryAudioService {
  const TtsStoryAudioService(this.tts);
  final TextToSpeechService tts;

  @override
  Future<void> playPhrase(String phrase) => tts.speak(
    TextToSpeechRequest(
      text: phrase,
      locale: 'en-US',
      speed: EducationalSpeechSpeed.normal,
      purpose: TextToSpeechPurpose.storyNarration,
    ),
  );

  @override
  Future<void> pause() => tts.stop();

  @override
  Future<void> replayPhrase(String phrase) => tts.speak(
    TextToSpeechRequest(
      text: phrase,
      locale: 'en-US',
      speed: EducationalSpeechSpeed.normal,
      purpose: TextToSpeechPurpose.sentenceReplay,
    ),
  );
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
    String? storyId,
    String? worldId,
    String? nextChapterId,
    int seedGrowth = 1,
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
    String? storyId,
    String? worldId,
    String? nextChapterId,
    int seedGrowth = 1,
  }) => ref
      .read(progressionProvider.notifier)
      .record(
        LearningEvent.storyCompleted(
          storyId: storyId ?? chapterId,
          chapterId: chapterId,
          worldId:
              worldId ??
              switch (chapterId) {
                'ormana-giris' ||
                'kaybolan-yol' ||
                'gece-sesleri' => 'sessiz-orman',
                'duygular' ||
                'hava-durumu' ||
                'ulasim-araclari' ||
                'yolculuk-hazirligi' => 'deniz-kralligi',
                _ => 'yasam-vadisi',
              },
          minutes: minutes,
          xp: xp,
          seedGrowth: seedGrowth,
          nextChapterId:
              nextChapterId ??
              switch (chapterId) {
                'first-encounter' => 'ben-kimim',
                'ben-kimim' => 'gunluk-hayat',
                'gunluk-hayat' => 'sevdigim-seyler',
                'sevdigim-seyler' => 'kucuk-bir-gun',
                'ormana-giris' => 'kaybolan-yol',
                'kaybolan-yol' => 'gece-sesleri',
                'duygular' => 'hava-durumu',
                'hava-durumu' => 'ulasim-araclari',
                'ulasim-araclari' => 'yolculuk-hazirligi',
                _ => null,
              },
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

final storyAudioServiceProvider = Provider<StoryAudioService>((ref) {
  final runtime = ref.watch(voicePlatformRuntimeProvider).value;
  return runtime?.capabilities.textToSpeech == VoiceAvailability.available
      ? TtsStoryAudioService(runtime!.textToSpeech)
      : UnconfiguredStoryAudioService();
});
final storyAudioAvailabilityProvider = Provider<bool>(
  (ref) =>
      ref.watch(voiceCapabilitiesProvider).textToSpeech ==
      VoiceAvailability.available,
);
final storyProgressRepositoryProvider = Provider<StoryProgressRepository>(
  (ref) => ProgressionStoryProgressRepository(ref),
);
