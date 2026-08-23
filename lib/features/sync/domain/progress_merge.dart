import '../../progression/domain/again_progress.dart';

class ProgressMerge {
  const ProgressMerge();

  /// Phase 28 merges idempotent sets and date-keyed activity. XP and seed
  /// growth use the value from the document with the newest trusted timestamp;
  /// they are never added together, which prevents retry duplication.
  AgainProgress merge({
    required AgainProgress local,
    required DateTime localUpdatedAt,
    required AgainProgress cloud,
    required DateTime cloudUpdatedAt,
  }) {
    final newest = cloudUpdatedAt.isAfter(localUpdatedAt) ? cloud : local;
    final activityByDate = <DateTime, DailyActivity>{};
    for (final activity in [
      ...local.activityHistory,
      ...cloud.activityHistory,
    ]) {
      final day = activityDay(activity.date);
      final existing = activityByDate[day];
      if (existing == null ||
          activity.learningMinutes > existing.learningMinutes) {
        activityByDate[day] = activity;
      }
    }
    return AgainProgress(
      schemaVersion: AgainProgress.currentSchemaVersion,
      completedStoryIds: {
        ...local.completedStoryIds,
        ...cloud.completedStoryIds,
      },
      completedChapterIds: {
        ...local.completedChapterIds,
        ...cloud.completedChapterIds,
      },
      unlockedChapterIds: {
        ...local.unlockedChapterIds,
        ...cloud.unlockedChapterIds,
      },
      unlockedWorldIds: {...local.unlockedWorldIds, ...cloud.unlockedWorldIds},
      currentWorldId: newest.currentWorldId,
      currentChapterId: newest.currentChapterId,
      totalXp: newest.totalXp,
      speakingMinutes: newest.speakingMinutes,
      listeningActivitiesCompleted: {
        ...local.listeningActivitiesCompleted,
        ...cloud.listeningActivitiesCompleted,
      },
      learnedWordIds: {...local.learnedWordIds, ...cloud.learnedWordIds},
      savedWordIds: {...local.savedWordIds, ...cloud.savedWordIds},
      firstSeedEarned: local.firstSeedEarned || cloud.firstSeedEarned,
      seedGrowth: newest.seedGrowth,
      claimedDailyRewards: {
        ...local.claimedDailyRewards,
        ...cloud.claimedDailyRewards,
      },
      activityHistory: activityByDate.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date)),
      learnerType: newest.learnerType ?? local.learnerType ?? cloud.learnerType,
    );
  }
}
