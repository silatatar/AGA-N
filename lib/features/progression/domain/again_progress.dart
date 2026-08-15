import '../../learner_profile/domain/learner_type.dart';

DateTime activityDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class DailyActivity {
  const DailyActivity({
    required this.date,
    this.learningMinutes = 0,
    this.storyCount = 0,
    this.vocabularyReviews = 0,
    this.listeningCount = 0,
    this.speakingMinutes = 0,
    this.learnedWordIds = const {},
  });

  final DateTime date;
  final int learningMinutes;
  final int storyCount;
  final int vocabularyReviews;
  final int listeningCount;
  final int speakingMinutes;
  final Set<String> learnedWordIds;

  bool get isActive =>
      learningMinutes > 0 ||
      storyCount > 0 ||
      vocabularyReviews > 0 ||
      listeningCount > 0 ||
      speakingMinutes > 0;

  DailyActivity copyWith({
    int? learningMinutes,
    int? storyCount,
    int? vocabularyReviews,
    int? listeningCount,
    int? speakingMinutes,
    Set<String>? learnedWordIds,
  }) => DailyActivity(
    date: activityDay(date),
    learningMinutes: learningMinutes ?? this.learningMinutes,
    storyCount: storyCount ?? this.storyCount,
    vocabularyReviews: vocabularyReviews ?? this.vocabularyReviews,
    listeningCount: listeningCount ?? this.listeningCount,
    speakingMinutes: speakingMinutes ?? this.speakingMinutes,
    learnedWordIds: learnedWordIds ?? this.learnedWordIds,
  );

  Map<String, Object?> toJson() => {
    'date': activityDay(date).toIso8601String(),
    'learningMinutes': learningMinutes,
    'storyCount': storyCount,
    'vocabularyReviews': vocabularyReviews,
    'listeningCount': listeningCount,
    'speakingMinutes': speakingMinutes,
    'learnedWordIds': learnedWordIds.toList(),
  };

  factory DailyActivity.fromJson(Map<String, Object?> json) => DailyActivity(
    date: activityDay(DateTime.parse(json['date']! as String)),
    learningMinutes: json['learningMinutes'] as int? ?? 0,
    storyCount: json['storyCount'] as int? ?? 0,
    vocabularyReviews: json['vocabularyReviews'] as int? ?? 0,
    listeningCount: json['listeningCount'] as int? ?? 0,
    speakingMinutes: json['speakingMinutes'] as int? ?? 0,
    learnedWordIds: {
      ...(json['learnedWordIds'] as List? ?? const []).cast<String>(),
    },
  );
}

enum LearningEventType {
  storyCompleted,
  wordSaved,
  wordRemoved,
  vocabularyReviewed,
  listeningCompleted,
  speakingCompleted,
  dailyRewardClaimed,
  worldDiscovered,
}

class LearningEvent {
  const LearningEvent._(
    this.type, {
    this.id = '',
    this.storyId = '',
    this.chapterId = '',
    this.worldId = '',
    this.minutes = 0,
    this.xp = 0,
    this.seedGrowth = 0,
    this.nextChapterId,
    this.date,
  });

  final LearningEventType type;
  final String id;
  final String storyId;
  final String chapterId;
  final String worldId;
  final int minutes;
  final int xp;
  final int seedGrowth;
  final String? nextChapterId;
  final DateTime? date;

  factory LearningEvent.storyCompleted({
    required String storyId,
    required String chapterId,
    required String worldId,
    required int minutes,
    required int xp,
    int seedGrowth = 0,
    int listeningCount = 0,
    String? nextChapterId,
    DateTime? date,
  }) => LearningEvent._(
    LearningEventType.storyCompleted,
    id: storyId,
    storyId: storyId,
    chapterId: chapterId,
    worldId: worldId,
    minutes: minutes,
    xp: xp,
    seedGrowth: seedGrowth,
    nextChapterId: nextChapterId,
    date: date,
  );
  factory LearningEvent.wordSaved(String wordId, {DateTime? date}) =>
      LearningEvent._(LearningEventType.wordSaved, id: wordId, date: date);
  factory LearningEvent.wordRemoved(String wordId) =>
      LearningEvent._(LearningEventType.wordRemoved, id: wordId);
  factory LearningEvent.vocabularyReviewed(String wordId, {DateTime? date}) =>
      LearningEvent._(
        LearningEventType.vocabularyReviewed,
        id: wordId,
        date: date,
      );
  factory LearningEvent.listeningCompleted(
    String activityId, {
    DateTime? date,
  }) => LearningEvent._(
    LearningEventType.listeningCompleted,
    id: activityId,
    date: date,
  );
  factory LearningEvent.speakingCompleted(
    String activityId,
    int minutes, {
    DateTime? date,
  }) => LearningEvent._(
    LearningEventType.speakingCompleted,
    id: activityId,
    minutes: minutes,
    date: date,
  );
  factory LearningEvent.dailyRewardClaimed(
    String rewardId, {
    required int xp,
    required int seedGrowth,
    DateTime? date,
  }) => LearningEvent._(
    LearningEventType.dailyRewardClaimed,
    id: rewardId,
    xp: xp,
    seedGrowth: seedGrowth,
    date: date,
  );
  factory LearningEvent.worldDiscovered(String worldId) => LearningEvent._(
    LearningEventType.worldDiscovered,
    id: worldId,
    worldId: worldId,
  );
}

class AgainProgress {
  const AgainProgress({
    this.schemaVersion = currentSchemaVersion,
    this.completedStoryIds = const {},
    this.completedChapterIds = const {},
    this.unlockedChapterIds = const {'first-encounter'},
    this.unlockedWorldIds = const {'yasam-vadisi'},
    this.currentWorldId = 'yasam-vadisi',
    this.currentChapterId = 'first-encounter',
    this.totalXp = 0,
    this.speakingMinutes = 0,
    this.listeningActivitiesCompleted = const {},
    this.learnedWordIds = const {},
    this.savedWordIds = const {},
    this.firstSeedEarned = false,
    this.seedGrowth = 0,
    this.claimedDailyRewards = const {},
    this.activityHistory = const [],
    this.learnerType,
  });
  static const currentSchemaVersion = 1;
  final int schemaVersion;
  final Set<String> completedStoryIds,
      completedChapterIds,
      unlockedChapterIds,
      unlockedWorldIds,
      listeningActivitiesCompleted,
      learnedWordIds,
      savedWordIds,
      claimedDailyRewards;
  final String? currentWorldId, currentChapterId;
  final int totalXp, speakingMinutes, seedGrowth;
  final bool firstSeedEarned;
  final List<DailyActivity> activityHistory;
  final LearnerType? learnerType;

  int dailyLearningMinutes([DateTime? now]) =>
      activityFor(now ?? DateTime.now()).learningMinutes;
  DailyActivity activityFor(DateTime date) => activityHistory.firstWhere(
    (item) => activityDay(item.date) == activityDay(date),
    orElse: () => DailyActivity(date: activityDay(date)),
  );
  int weeklyMinutes([DateTime? now]) {
    final today = activityDay(now ?? DateTime.now());
    final start = today.subtract(Duration(days: today.weekday - 1));
    return activityHistory
        .where((a) => !a.date.isBefore(start) && !a.date.isAfter(today))
        .fold(0, (sum, a) => sum + a.learningMinutes);
  }

  int get currentStreak => streakAt(DateTime.now());
  int streakAt(DateTime now) {
    var day = activityDay(now);
    if (!activityFor(day).isActive) day = day.subtract(const Duration(days: 1));
    var value = 0;
    while (activityFor(day).isActive) {
      value++;
      day = day.subtract(const Duration(days: 1));
    }
    return value;
  }

  int get longestStreak {
    final days =
        activityHistory
            .where((a) => a.isActive)
            .map((a) => activityDay(a.date))
            .toSet()
            .toList()
          ..sort();
    var best = 0, run = 0;
    DateTime? prior;
    for (final day in days) {
      run = prior != null && day.difference(prior).inDays == 1 ? run + 1 : 1;
      if (run > best) best = run;
      prior = day;
    }
    return best;
  }

  int worldProgress(Iterable<String> requiredChapterIds) {
    final ids = requiredChapterIds.toSet();
    return ids.isEmpty
        ? 0
        : ((ids.intersection(completedChapterIds).length / ids.length) * 100)
              .round();
  }

  AgainProgress apply(LearningEvent event) {
    final completedStories = {...completedStoryIds};
    final completedChapters = {...completedChapterIds};
    final unlockedChapters = {...unlockedChapterIds};
    final unlockedWorlds = {...unlockedWorldIds};
    final listening = {...listeningActivitiesCompleted};
    final learned = {...learnedWordIds};
    final saved = {...savedWordIds};
    final claimed = {...claimedDailyRewards};
    var xp = totalXp, speaking = speakingMinutes, growth = seedGrowth;
    var seed = firstSeedEarned;
    var currentWorld = currentWorldId;
    var currentChapter = currentChapterId;
    final date = activityDay(event.date ?? DateTime.now());
    var daily = activityFor(date);
    var shouldWriteDay = false;
    switch (event.type) {
      case LearningEventType.storyCompleted:
        if (completedStories.add(event.storyId)) {
          completedChapters.add(event.chapterId);
          unlockedWorlds.add(event.worldId);
          if (event.nextChapterId != null) {
            unlockedChapters.add(event.nextChapterId!);
          }
          if (event.storyId == 'first-encounter') {
            unlockedWorlds.add('deniz-kralligi');
          }
          xp += event.xp;
          growth += event.seedGrowth;
          seed |= event.seedGrowth > 0;
          currentWorld = event.worldId;
          currentChapter = event.nextChapterId;
          daily = daily.copyWith(
            learningMinutes: daily.learningMinutes + event.minutes,
            storyCount: daily.storyCount + 1,
          );
          shouldWriteDay = true;
        }
      case LearningEventType.wordSaved:
        saved.add(event.id);
        learned.add(event.id);
        daily = daily.copyWith(
          learnedWordIds: {...daily.learnedWordIds, event.id},
        );
        shouldWriteDay = true;
      case LearningEventType.wordRemoved:
        saved.remove(event.id);
      case LearningEventType.vocabularyReviewed:
        daily = daily.copyWith(vocabularyReviews: daily.vocabularyReviews + 1);
        shouldWriteDay = true;
      case LearningEventType.listeningCompleted:
        if (listening.add(event.id)) {
          daily = daily.copyWith(listeningCount: daily.listeningCount + 1);
          shouldWriteDay = true;
        }
      case LearningEventType.speakingCompleted:
        speaking += event.minutes;
        daily = daily.copyWith(
          speakingMinutes: daily.speakingMinutes + event.minutes,
        );
        shouldWriteDay = true;
      case LearningEventType.dailyRewardClaimed:
        if (claimed.add(event.id)) {
          xp += event.xp;
          growth += event.seedGrowth;
        }
      case LearningEventType.worldDiscovered:
        unlockedWorlds.add(event.worldId);
        currentWorld = event.worldId;
    }
    final history = [...activityHistory];
    if (shouldWriteDay) {
      history.removeWhere((a) => activityDay(a.date) == date);
      history.add(daily);
      history.sort((a, b) => a.date.compareTo(b.date));
    }
    return AgainProgress(
      schemaVersion: schemaVersion,
      completedStoryIds: completedStories,
      completedChapterIds: completedChapters,
      unlockedChapterIds: unlockedChapters,
      unlockedWorldIds: unlockedWorlds,
      currentWorldId: currentWorld,
      currentChapterId: currentChapter,
      totalXp: xp,
      speakingMinutes: speaking,
      listeningActivitiesCompleted: listening,
      learnedWordIds: learned,
      savedWordIds: saved,
      firstSeedEarned: seed,
      seedGrowth: growth,
      claimedDailyRewards: claimed,
      activityHistory: history,
      learnerType: learnerType,
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'completedStoryIds': completedStoryIds.toList(),
    'completedChapterIds': completedChapterIds.toList(),
    'unlockedChapterIds': unlockedChapterIds.toList(),
    'unlockedWorldIds': unlockedWorldIds.toList(),
    'currentWorldId': currentWorldId,
    'currentChapterId': currentChapterId,
    'totalXp': totalXp,
    'speakingMinutes': speakingMinutes,
    'listeningActivitiesCompleted': listeningActivitiesCompleted.toList(),
    'learnedWordIds': learnedWordIds.toList(),
    'savedWordIds': savedWordIds.toList(),
    'firstSeedEarned': firstSeedEarned,
    'seedGrowth': seedGrowth,
    'claimedDailyRewards': claimedDailyRewards.toList(),
    'activityHistory': activityHistory.map((a) => a.toJson()).toList(),
    'learnerType': learnerType?.name,
  };
  factory AgainProgress.fromJson(Map<String, Object?> j) {
    Set<String> set(String key) => {
      ...(j[key] as List? ?? const []).cast<String>(),
    };
    final learnerName = j['learnerType'] as String?;
    return AgainProgress(
      schemaVersion: j['schemaVersion'] as int? ?? 1,
      completedStoryIds: set('completedStoryIds'),
      completedChapterIds: set('completedChapterIds'),
      unlockedChapterIds: set('unlockedChapterIds'),
      unlockedWorldIds: set('unlockedWorldIds'),
      currentWorldId: j['currentWorldId'] as String?,
      currentChapterId: j['currentChapterId'] as String?,
      totalXp: j['totalXp'] as int? ?? 0,
      speakingMinutes: j['speakingMinutes'] as int? ?? 0,
      listeningActivitiesCompleted: set('listeningActivitiesCompleted'),
      learnedWordIds: set('learnedWordIds'),
      savedWordIds: set('savedWordIds'),
      firstSeedEarned: j['firstSeedEarned'] as bool? ?? false,
      seedGrowth: j['seedGrowth'] as int? ?? 0,
      claimedDailyRewards: set('claimedDailyRewards'),
      activityHistory: (j['activityHistory'] as List? ?? const [])
          .map(
            (e) => DailyActivity.fromJson(Map<String, Object?>.from(e as Map)),
          )
          .toList(),
      learnerType: learnerName == null
          ? null
          : LearnerType.values.where((e) => e.name == learnerName).firstOrNull,
    );
  }
}
