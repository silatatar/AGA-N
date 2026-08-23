import '../../learner_profile/domain/learner_profile.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../onboarding/domain/onboarding_preferences.dart';

class ProfileStatistic {
  const ProfileStatistic({required this.label, required this.value});
  final String label;
  final String value;
}

class ProfileCollectionItem {
  const ProfileCollectionItem({
    required this.title,
    required this.count,
    required this.isUnlocked,
  });
  final String title;
  final int count;
  final bool isUnlocked;
}

class ProfileBadge {
  const ProfileBadge({required this.title, required this.isUnlocked});
  final String title;
  final bool isUnlocked;
}

class ProfileGrowth {
  const ProfileGrowth({
    required this.points,
    required this.stateName,
    required this.nextMilestone,
    required this.progress,
  });
  final int points;
  final String stateName;
  final int nextMilestone;
  final double progress;
}

class ProfileProgress {
  const ProfileProgress({
    required this.profile,
    required this.learnerType,
    required this.levelName,
    required this.numericLevel,
    required this.totalXp,
    required this.xpInLevel,
    required this.xpForNextLevel,
    required this.statistics,
    required this.collections,
    required this.badges,
    required this.growth,
    required this.preferences,
  });

  final LearnerProfile? profile;
  final LearnerType? learnerType;
  final String levelName;
  final int numericLevel;
  final int totalXp;
  final int xpInLevel;
  final int xpForNextLevel;
  final List<ProfileStatistic> statistics;
  final List<ProfileCollectionItem> collections;
  final List<ProfileBadge> badges;
  final ProfileGrowth growth;
  final OnboardingPreferences preferences;
}
