import 'package:shared_preferences/shared_preferences.dart';

import '../../learner_profile/data/learner_personalization_store.dart';
import '../../sync/data/local_key_value_store.dart';
import '../../sync/domain/data_ownership.dart';
import '../domain/onboarding_preferences.dart';

abstract interface class OnboardingPreferencesRepository {
  Future<OnboardingPreferences> read();
  Future<void> save(OnboardingPreferences preferences);
}

class SharedPreferencesOnboardingRepository
    implements OnboardingPreferencesRepository {
  SharedPreferencesOnboardingRepository({
    SharedPreferencesAsync? preferences,
    LocalKeyValueStore? store,
    DataOwnershipStore? ownership,
  }) : _store = LearnerPersonalizationStore(
         store:
             store ??
             (preferences == null
                 ? null
                 : SharedPreferencesLocalKeyValueStore(preferences)),
         ownership: ownership,
       );
  final LearnerPersonalizationStore _store;

  @override
  Future<OnboardingPreferences> read() async {
    return (await _store.read()).preferences;
  }

  @override
  Future<void> save(OnboardingPreferences preferences) async {
    final current = await _store.read();
    await _store.save(current.copyWith(preferences: preferences));
  }
}
