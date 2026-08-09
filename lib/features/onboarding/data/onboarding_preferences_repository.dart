import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_preferences.dart';

abstract interface class OnboardingPreferencesRepository {
  Future<OnboardingPreferences> read();
  Future<void> save(OnboardingPreferences preferences);
}

class SharedPreferencesOnboardingRepository
    implements OnboardingPreferencesRepository {
  SharedPreferencesOnboardingRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'again.onboarding_preferences';
  final SharedPreferencesAsync _preferences;

  @override
  Future<OnboardingPreferences> read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return const OnboardingPreferences();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final levelName = json['level'] as String?;
    return OnboardingPreferences(
      goals: Set<String>.from(json['goals'] as List? ?? const []),
      level: EnglishLevel.values
          .where((level) => level.name == levelName)
          .firstOrNull,
      interests: Set<String>.from(json['interests'] as List? ?? const []),
      dailyMinutes: json['dailyMinutes'] as int?,
    );
  }

  @override
  Future<void> save(OnboardingPreferences preferences) =>
      _preferences.setString(
        _key,
        jsonEncode({
          'goals': preferences.goals.toList(),
          'level': preferences.level?.name,
          'interests': preferences.interests.toList(),
          'dailyMinutes': preferences.dailyMinutes,
        }),
      );
}
