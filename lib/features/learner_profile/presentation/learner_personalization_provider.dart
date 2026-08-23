import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/presentation/onboarding_controller.dart';
import '../../startup/startup_decision.dart';
import '../domain/learner_personalization.dart';
import 'learner_profile_controller.dart';
import 'learner_selection_controller.dart';

final learnerPersonalizationProvider = FutureProvider<LearnerPersonalization>((
  ref,
) async {
  final values = await (
    ref.watch(learnerProfileProvider.future),
    ref.watch(learnerSelectionProvider.future),
    ref.watch(onboardingProvider.future),
    ref.watch(startupControllerProvider.future),
  ).wait;
  return LearnerPersonalization(
    identity: values.$1,
    learnerType: values.$2,
    preferences: values.$3,
    onboardingComplete: values.$4.onboardingComplete,
  );
});
