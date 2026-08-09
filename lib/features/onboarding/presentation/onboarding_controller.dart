import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_preferences_repository.dart';
import '../domain/onboarding_preferences.dart';

final onboardingRepositoryProvider = Provider<OnboardingPreferencesRepository>(
  (ref) => SharedPreferencesOnboardingRepository(),
);

class OnboardingController extends AsyncNotifier<OnboardingPreferences> {
  @override
  Future<OnboardingPreferences> build() =>
      ref.read(onboardingRepositoryProvider).read();

  Future<void> setGoals(Set<String> goals) =>
      _persist(state.requireValue.copyWith(goals: goals));
  Future<void> setLevel(EnglishLevel level) =>
      _persist(state.requireValue.copyWith(level: level));
  Future<void> setInterests(Set<String> interests) =>
      _persist(state.requireValue.copyWith(interests: interests));
  Future<void> setDailyMinutes(int minutes) =>
      _persist(state.requireValue.copyWith(dailyMinutes: minutes));

  Future<void> _persist(OnboardingPreferences next) async {
    state = AsyncData(next);
    try {
      await ref.read(onboardingRepositoryProvider).save(next);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final onboardingProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingPreferences>(
      OnboardingController.new,
    );
