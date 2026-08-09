enum EnglishLevel {
  beginner,
  words,
  simpleSentences,
  conversational,
  placementTest,
}

class OnboardingPreferences {
  const OnboardingPreferences({
    this.goals = const {},
    this.level,
    this.interests = const {},
    this.dailyMinutes,
  });

  final Set<String> goals;
  final EnglishLevel? level;
  final Set<String> interests;
  final int? dailyMinutes;

  OnboardingPreferences copyWith({
    Set<String>? goals,
    EnglishLevel? level,
    Set<String>? interests,
    int? dailyMinutes,
  }) => OnboardingPreferences(
    goals: goals ?? this.goals,
    level: level ?? this.level,
    interests: interests ?? this.interests,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
  );
}
