import '../../learner_profile/domain/learner_type.dart';
import '../../onboarding/domain/onboarding_preferences.dart';

enum HumaScreen {
  opening,
  onboarding,
  home,
  map,
  worldDetail,
  story,
  vocabulary,
  tasks,
  square,
  conversation,
  profile,
}

enum HumaMessageType {
  welcome,
  guidance,
  progress,
  vocabulary,
  story,
  world,
  task,
  celebration,
  help,
  warning,
  emptyState,
  returningUser,
}

enum HumaVisualState { idle, guiding, explaining, celebrating }

class HumaAction {
  const HumaAction({required this.label, required this.route});
  final String label, route;
}

class HumaMessage {
  const HumaMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.priority,
    this.action,
  });
  final String id, text;
  final HumaMessageType type;
  final int priority;
  final HumaAction? action;
  bool get isMajorCelebration =>
      type == HumaMessageType.celebration && priority >= 90;
}

class HumaContext {
  const HumaContext({
    required this.screen,
    this.learnerName = 'Gezgin',
    this.learnerType,
    this.level,
    this.firstTimeUser = false,
    this.returningUser = true,
    this.currentWorldId,
    this.currentChapterId,
    this.activeStoryRoute,
    this.dailyMinutes = 0,
    this.dailyTarget = 0,
    this.currentStreak = 0,
    this.vocabularyCount = 0,
    this.vocabularyDueCount = 0,
    this.newGrowthWord,
    this.newlyUnlockedWorldId,
    this.newlyUnlockedChapterId,
    this.storyCompletedToday = false,
    this.taskCount = 0,
    this.completedTaskCount = 0,
    this.goals = const {},
    this.interests = const {},
  });

  final HumaScreen screen;
  final String learnerName;
  final LearnerType? learnerType;
  final EnglishLevel? level;
  final bool firstTimeUser, returningUser, storyCompletedToday;
  final String? currentWorldId, currentChapterId, activeStoryRoute;
  final int dailyMinutes, dailyTarget, currentStreak;
  final int vocabularyCount, vocabularyDueCount;
  final String? newGrowthWord, newlyUnlockedWorldId, newlyUnlockedChapterId;
  final int taskCount, completedTaskCount;
  final Set<String> goals, interests;

  HumaContext copyWith({
    HumaScreen? screen,
    String? currentWorldId,
    String? currentChapterId,
    String? newGrowthWord,
    String? newlyUnlockedWorldId,
    String? newlyUnlockedChapterId,
  }) => HumaContext(
    screen: screen ?? this.screen,
    learnerName: learnerName,
    learnerType: learnerType,
    level: level,
    firstTimeUser: firstTimeUser,
    returningUser: returningUser,
    currentWorldId: currentWorldId ?? this.currentWorldId,
    currentChapterId: currentChapterId ?? this.currentChapterId,
    activeStoryRoute: activeStoryRoute,
    dailyMinutes: dailyMinutes,
    dailyTarget: dailyTarget,
    currentStreak: currentStreak,
    vocabularyCount: vocabularyCount,
    vocabularyDueCount: vocabularyDueCount,
    newGrowthWord: newGrowthWord ?? this.newGrowthWord,
    newlyUnlockedWorldId: newlyUnlockedWorldId ?? this.newlyUnlockedWorldId,
    newlyUnlockedChapterId:
        newlyUnlockedChapterId ?? this.newlyUnlockedChapterId,
    storyCompletedToday: storyCompletedToday,
    taskCount: taskCount,
    completedTaskCount: completedTaskCount,
    goals: goals,
    interests: interests,
  );
}

enum HumaMemoryKind { product, session, futureOptionalAi }

class HumaProductMemory {
  const HumaProductMemory({
    required this.learnerName,
    required this.learnerType,
    required this.level,
    required this.goals,
    required this.interests,
  });
  final String learnerName;
  final LearnerType? learnerType;
  final EnglishLevel? level;
  final Set<String> goals, interests;
}

class HumaSessionMemory {
  const HumaSessionMemory({
    required this.startedAt,
    this.messageIds = const [],
  });
  final DateTime startedAt;
  final List<String> messageIds;
}
