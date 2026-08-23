import '../../onboarding/domain/onboarding_preferences.dart';
import 'learner_profile.dart';
import 'learner_type.dart';

class LearnerPersonalization {
  const LearnerPersonalization({
    this.schemaVersion = currentSchemaVersion,
    this.identity,
    this.learnerType,
    this.preferences = const OnboardingPreferences(),
    this.onboardingComplete = false,
  });

  static const currentSchemaVersion = 1;
  final int schemaVersion;
  final LearnerProfile? identity;
  final LearnerType? learnerType;
  final OnboardingPreferences preferences;
  final bool onboardingComplete;

  LearnerPersonalization copyWith({
    LearnerProfile? identity,
    LearnerType? learnerType,
    OnboardingPreferences? preferences,
    bool? onboardingComplete,
  }) => LearnerPersonalization(
    identity: identity ?? this.identity,
    learnerType: learnerType ?? this.learnerType,
    preferences: preferences ?? this.preferences,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': currentSchemaVersion,
    'displayName': identity?.displayName,
    'username': identity?.username,
    'avatar': identity?.avatar.name,
    'learnerType': learnerType?.name,
    'level': preferences.level?.name,
    'goals': preferences.goals.toList()..sort(),
    'interests': preferences.interests.toList()..sort(),
    'dailyMinutes': preferences.dailyMinutes,
    'onboardingComplete': onboardingComplete,
  };

  static LearnerPersonalization? tryFromJson(Object? value) {
    if (value is! Map) return null;
    try {
      final json = Map<String, Object?>.from(value);
      final version = json['schemaVersion'];
      if (version is! int || version < 1 || version > currentSchemaVersion) {
        return null;
      }
      final displayName = json['displayName'];
      final dailyMinutes = json['dailyMinutes'];
      final safeMinutes = dailyMinutes is int && dailyMinutes > 0
          ? dailyMinutes
          : null;
      final levelName = json['level'];
      final typeName = json['learnerType'];
      return LearnerPersonalization(
        identity: displayName is String && displayName.trim().isNotEmpty
            ? LearnerProfile(
                displayName: displayName,
                username: json['username'] is String
                    ? json['username'] as String
                    : null,
                avatar: LearnerAvatarCopy.fromStorage(
                  json['avatar'] as String?,
                ),
              )
            : null,
        learnerType: LearnerTypeCopy.fromStorage(typeName as String?),
        preferences: OnboardingPreferences(
          goals: _strings(json['goals']),
          interests: _strings(json['interests']),
          level: EnglishLevel.values
              .where((item) => item.name == levelName)
              .firstOrNull,
          dailyMinutes: safeMinutes,
        ),
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  static Set<String> _strings(Object? value) => value is List
      ? value.whereType<String>().where((item) => item.isNotEmpty).toSet()
      : const {};
}
