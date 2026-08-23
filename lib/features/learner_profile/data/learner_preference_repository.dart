import 'package:shared_preferences/shared_preferences.dart';

import '../domain/learner_type.dart';
import '../domain/learner_profile.dart';
import 'learner_personalization_store.dart';
import '../../sync/data/local_key_value_store.dart';
import '../../sync/domain/data_ownership.dart';

abstract interface class LearnerPreferenceRepository {
  Future<LearnerType?> readLearnerType();
  Future<void> saveLearnerType(LearnerType type);
  Future<LearnerProfile?> readProfile();
  Future<void> saveProfile(LearnerProfile profile);
}

class SharedPreferencesLearnerPreferenceRepository
    implements LearnerPreferenceRepository {
  SharedPreferencesLearnerPreferenceRepository({
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
  Future<LearnerType?> readLearnerType() async =>
      (await _store.read()).learnerType;

  @override
  Future<void> saveLearnerType(LearnerType type) async {
    final current = await _store.read();
    await _store.save(current.copyWith(learnerType: type));
  }

  @override
  Future<LearnerProfile?> readProfile() async {
    return (await _store.read()).identity;
  }

  @override
  Future<void> saveProfile(LearnerProfile profile) async {
    final current = await _store.read();
    await _store.save(current.copyWith(identity: profile));
  }
}
