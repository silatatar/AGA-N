enum EnglishLevel {
  beginner,
  words,
  simpleSentences,
  conversational,
  placementTest,
}

abstract final class OnboardingOptions {
  static const goals = [
    'Günlük konuşmak',
    'Seyahat etmek',
    'Film ve dizileri anlamak',
    'İş hayatında kullanmak',
    'Okul veya sınav',
    'Yurt dışında yaşamak',
    'Konuşma korkumu yenmek',
    'Kendimi geliştirmek',
  ];
  static const interests = [
    'Mitoloji',
    'Seyahat',
    'Kültür',
    'Tarih',
    'Gizem',
    'Fantastik',
    'Sanat',
    'Müzik',
    'Sinema',
    'Bilim',
    'Teknoloji',
    'Günlük yaşam',
    'İş dünyası',
  ];
  static const dailyMinutes = [5, 10, 15, 20, 30];
  static const levelLabels = {
    EnglishLevel.beginner: 'Yeni başlıyorum',
    EnglishLevel.words: 'Biraz kelime biliyorum',
    EnglishLevel.simpleSentences: 'Basit cümleleri anlayabiliyorum',
    EnglishLevel.conversational: 'Konuşabiliyorum ama geliştirmek istiyorum',
    EnglishLevel.placementTest: 'Seviyemi test et',
  };
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
