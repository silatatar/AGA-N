import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SharedPreferencesStoryProgressRepository
    implements StoryProgressRepository {
  SharedPreferencesStoryProgressRepository({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();
  static const _seedKey = 'again.first_seed_awarded';
  static const _wordsKey = 'again.saved_words';
  static const _chaptersKey = 'again.completed_chapters';
  static const _xpKey = 'again.total_xp';
  static const _rewardSeedKey = 'again.reward_seed_growth';
  final SharedPreferencesAsync _prefs;

  String get _minutesKey =>
      'again.minutes.${DateTime.now().toIso8601String().substring(0, 10)}';
  String get _listeningKey =>
      'again.listening.${DateTime.now().toIso8601String().substring(0, 10)}';
  String get _speakingKey =>
      'again.speaking_minutes.${DateTime.now().toIso8601String().substring(0, 10)}';
  String get _reviewsKey =>
      'again.vocabulary_reviews.${DateTime.now().toIso8601String().substring(0, 10)}';
  String get _claimedRewardsKey =>
      'again.claimed_rewards.${DateTime.now().toIso8601String().substring(0, 10)}';

  @override
  Future<void> awardFirstSeed() => _prefs.setBool(_seedKey, true);
  @override
  Future<bool> hasFirstSeed() async => await _prefs.getBool(_seedKey) ?? false;

  @override
  Future<void> saveWord(String word) async {
    final words = {...?await _prefs.getStringList(_wordsKey), word};
    await _prefs.setStringList(_wordsKey, words.toList());
  }

  @override
  Future<void> removeWord(String word) async {
    final words = {...?await _prefs.getStringList(_wordsKey)}..remove(word);
    await _prefs.setStringList(_wordsKey, words.toList());
  }

  @override
  Future<void> completeChapter({
    required String chapterId,
    required int minutes,
    required int xp,
  }) async {
    final chapters = {...?await _prefs.getStringList(_chaptersKey), chapterId};
    await _prefs.setStringList(_chaptersKey, chapters.toList());
    final currentMinutes = await _prefs.getInt(_minutesKey) ?? 0;
    await _prefs.setInt(_minutesKey, currentMinutes + minutes);
    final currentXp = await _prefs.getInt(_xpKey) ?? 0;
    await _prefs.setInt(_xpKey, currentXp + xp);
    final listening = await _prefs.getInt(_listeningKey) ?? 0;
    await _prefs.setInt(_listeningKey, listening + 1);
  }

  @override
  Future<void> completeVocabularyReview() async {
    final reviews = await _prefs.getInt(_reviewsKey) ?? 0;
    await _prefs.setInt(_reviewsKey, reviews + 1);
  }

  @override
  Future<void> claimDailyReward({
    required String taskId,
    required int xp,
    required int seedGrowth,
  }) async {
    final claimed = {...?await _prefs.getStringList(_claimedRewardsKey)};
    if (claimed.contains(taskId)) return;
    claimed.add(taskId);
    await _prefs.setStringList(_claimedRewardsKey, claimed.toList());
    final currentXp = await _prefs.getInt(_xpKey) ?? 0;
    await _prefs.setInt(_xpKey, currentXp + xp);
    final currentGrowth = await _prefs.getInt(_rewardSeedKey) ?? 0;
    await _prefs.setInt(_rewardSeedKey, currentGrowth + seedGrowth);
  }

  @override
  Future<StoryProgressSnapshot> readSnapshot() async => StoryProgressSnapshot(
    hasFirstSeed: await hasFirstSeed(),
    savedWords: {...?await _prefs.getStringList(_wordsKey)},
    completedChapters: {...?await _prefs.getStringList(_chaptersKey)},
    minutesToday: await _prefs.getInt(_minutesKey) ?? 0,
    totalXp: await _prefs.getInt(_xpKey) ?? 0,
    listeningActivities: await _prefs.getInt(_listeningKey) ?? 0,
    speakingMinutes: await _prefs.getInt(_speakingKey) ?? 0,
    vocabularyReviews: await _prefs.getInt(_reviewsKey) ?? 0,
    claimedTaskRewards: {...?await _prefs.getStringList(_claimedRewardsKey)},
    rewardSeedGrowth: await _prefs.getInt(_rewardSeedKey) ?? 0,
  );
}

final storyAudioServiceProvider = Provider<StoryAudioService>(
  (ref) => DevelopmentStoryAudioService(),
);
final storyProgressRepositoryProvider = Provider<StoryProgressRepository>(
  (ref) => SharedPreferencesStoryProgressRepository(),
);
