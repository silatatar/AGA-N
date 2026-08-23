import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learner_preference_repository.dart';
import '../domain/learner_type.dart';
import '../../sync/application/data_ownership_provider.dart';

final learnerPreferenceRepositoryProvider =
    Provider<LearnerPreferenceRepository>(
      (ref) => SharedPreferencesLearnerPreferenceRepository(
        ownership: ref.watch(dataOwnershipStoreProvider),
      ),
    );

class LearnerSelectionController extends AsyncNotifier<LearnerType?> {
  @override
  Future<LearnerType?> build() =>
      ref.read(learnerPreferenceRepositoryProvider).readLearnerType();

  Future<void> select(LearnerType type) async {
    state = AsyncData(type);
    try {
      await ref.read(learnerPreferenceRepositoryProvider).saveLearnerType(type);
    } catch (error, stackTrace) {
      state = AsyncError<LearnerType?>(error, stackTrace);
    }
  }
}

final learnerSelectionProvider =
    AsyncNotifierProvider<LearnerSelectionController, LearnerType?>(
      LearnerSelectionController.new,
    );
