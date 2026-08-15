import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/again_progress.dart';

abstract interface class ProgressionRepository {
  Future<AgainProgress> read();
  Future<void> save(AgainProgress progress);
}

class SharedPreferencesProgressionRepository implements ProgressionRepository {
  SharedPreferencesProgressionRepository([this._preferences]);

  static const storageKey = 'again.progression.v1';
  final SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get preferences =>
      _preferences ?? SharedPreferencesAsync();

  @override
  Future<AgainProgress> read() async {
    final stored = await preferences.getString(storageKey);
    if (stored != null) {
      try {
        return AgainProgress.fromJson(
          Map<String, Object?>.from(jsonDecode(stored) as Map),
        );
      } on FormatException {
        // Preserve recoverability: fall through to the legacy migration.
      }
    }
    final migrated = await _migrateLegacy();
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(AgainProgress progress) =>
      preferences.setString(storageKey, jsonEncode(progress.toJson()));

  Future<AgainProgress> _migrateLegacy() async {
    final now = DateTime.now();
    final day = now.toIso8601String().substring(0, 10);
    final chapters = {
      ...?await preferences.getStringList('again.completed_chapters'),
    };
    final legacyWords = {
      ...?await preferences.getStringList('again.saved_words'),
    };
    final hasSeed =
        await preferences.getBool('again.first_seed_awarded') ?? false;
    final minutes = await preferences.getInt('again.minutes.$day') ?? 0;
    final listening = await preferences.getInt('again.listening.$day') ?? 0;
    final reviews =
        await preferences.getInt('again.vocabulary_reviews.$day') ?? 0;
    final speaking =
        await preferences.getInt('again.speaking_minutes.$day') ?? 0;
    final rewards = {
      ...?await preferences.getStringList('again.claimed_rewards.$day'),
    };
    final activity = DailyActivity(
      date: now,
      learningMinutes: minutes,
      storyCount: chapters.length,
      vocabularyReviews: reviews,
      listeningCount: listening,
      speakingMinutes: speaking,
      learnedWordIds: legacyWords,
    );
    return AgainProgress(
      completedStoryIds: chapters,
      completedChapterIds: chapters,
      unlockedChapterIds: {'first-encounter', ...chapters},
      unlockedWorldIds: {
        'yasam-vadisi',
        if (chapters.contains('hava-durumu')) 'deniz-kralligi',
      },
      totalXp: await preferences.getInt('again.total_xp') ?? 0,
      speakingMinutes: speaking,
      listeningActivitiesCompleted: {
        for (var index = 0; index < listening; index++) 'legacy-$day-$index',
      },
      learnedWordIds: legacyWords,
      savedWordIds: legacyWords,
      firstSeedEarned: hasSeed,
      seedGrowth:
          (hasSeed ? 1 : 0) +
          chapters.length +
          (await preferences.getInt('again.reward_seed_growth') ?? 0),
      claimedDailyRewards: rewards,
      activityHistory: activity.isActive ? [activity] : const [],
    );
  }
}

class MemoryProgressionRepository implements ProgressionRepository {
  MemoryProgressionRepository([AgainProgress? initial])
    : value = initial ?? const AgainProgress();
  AgainProgress value;
  @override
  Future<AgainProgress> read() async => value;
  @override
  Future<void> save(AgainProgress progress) async => value = progress;
}
