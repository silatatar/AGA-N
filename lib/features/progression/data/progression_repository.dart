import 'dart:convert';

import '../domain/again_progress.dart';
import '../../sync/data/local_key_value_store.dart';
import '../../sync/domain/data_ownership.dart';

abstract interface class ProgressionRepository {
  Future<AgainProgress> read();
  Future<void> save(AgainProgress progress);
}

class SharedPreferencesProgressionRepository implements ProgressionRepository {
  SharedPreferencesProgressionRepository({
    LocalKeyValueStore? store,
    this.ownership,
  }) : _store = store ?? SharedPreferencesLocalKeyValueStore();

  static const storageKey = 'again.progression.v1';
  static const corruptBackupKey = 'again.progression.corrupt_backup.v1';
  final LocalKeyValueStore _store;
  final DataOwnershipStore? ownership;

  Future<String> _key(String logical) async => ownership == null
      ? logical
      : (await ownership!.current()).storageKey(logical);

  @override
  Future<AgainProgress> read() async {
    final owner = ownership == null ? null : await ownership!.current();
    final scopedKey = await _key(storageKey);
    var stored = await _store.getString(scopedKey);
    if (stored == null && owner != null) {
      if (owner.kind == DataOwnerKind.guest) {
        stored = await _store.getString(storageKey);
        if (stored != null) await _store.setString(scopedKey, stored);
      }
    }
    if (stored != null) {
      try {
        return AgainProgress.fromJson(
          Map<String, Object?>.from(jsonDecode(stored) as Map),
        );
      } catch (_) {
        // Preserve the exact unreadable payload before any recovery write.
        await _store.setString(await _key(corruptBackupKey), stored);
      }
    }
    // Installation-wide legacy fields are unclaimed. They may only be adopted
    // by the stable guest owner, never guessed to belong to a signed-in user.
    if (owner?.kind == DataOwnerKind.user) return const AgainProgress();
    final migrated = await _migrateLegacy();
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(AgainProgress progress) async =>
      _store.setString(await _key(storageKey), jsonEncode(progress.toJson()));

  Future<AgainProgress> _migrateLegacy() async {
    final now = DateTime.now();
    final day = now.toIso8601String().substring(0, 10);
    final chapters = {
      ...?await _store.getStringList('again.completed_chapters'),
    };
    final legacyWords = {...?await _store.getStringList('again.saved_words')};
    final hasSeed = await _store.getBool('again.first_seed_awarded') ?? false;
    final minutes = await _store.getInt('again.minutes.$day') ?? 0;
    final listening = await _store.getInt('again.listening.$day') ?? 0;
    final reviews = await _store.getInt('again.vocabulary_reviews.$day') ?? 0;
    final speaking = await _store.getInt('again.speaking_minutes.$day') ?? 0;
    final rewards = {
      ...?await _store.getStringList('again.claimed_rewards.$day'),
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
      totalXp: await _store.getInt('again.total_xp') ?? 0,
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
          (await _store.getInt('again.reward_seed_growth') ?? 0),
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
