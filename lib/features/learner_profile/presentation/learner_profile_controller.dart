import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/learner_profile.dart';
import 'learner_selection_controller.dart';

class LearnerProfileController extends AsyncNotifier<LearnerProfile?> {
  @override
  Future<LearnerProfile?> build() =>
      ref.read(learnerPreferenceRepositoryProvider).readProfile();

  Future<bool> save(LearnerProfile profile) async {
    state = AsyncData(profile);
    try {
      await ref.read(learnerPreferenceRepositoryProvider).saveProfile(profile);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

final learnerProfileProvider =
    AsyncNotifierProvider<LearnerProfileController, LearnerProfile?>(
      LearnerProfileController.new,
    );
