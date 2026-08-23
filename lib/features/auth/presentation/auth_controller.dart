import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/development_auth_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../data/unconfigured_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../../startup/startup_decision.dart';
import '../../../core/backend/backend_config.dart';
import '../../../core/backend/supabase_runtime.dart';
import '../../sync/application/data_ownership_provider.dart';
import '../../sync/domain/data_ownership.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../onboarding/presentation/onboarding_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => switch (SupabaseRuntime.config.status) {
    BackendStatus.developmentLocal => DevelopmentAuthRepository(),
    BackendStatus.supabaseConfigured => SupabaseAuthRepository(
      SupabaseRuntime.client!,
    ),
    BackendStatus.supabaseUnconfigured => const UnconfiguredAuthRepository(),
  },
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) => _run(
    () => ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password),
  );

  Future<AuthResult> login({required String email, required String password}) =>
      _run(
        () => ref
            .read(authRepositoryProvider)
            .login(email: email, password: password),
      );

  Future<AuthResult> reset(String email) =>
      _run(() => ref.read(authRepositoryProvider).requestPasswordReset(email));

  Future<AuthResult> resend(String email) =>
      _run(() => ref.read(authRepositoryProvider).resendVerification(email));

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      final ownership = ref.read(dataOwnershipStoreProvider);
      await ownership.switchTo(await ownership.guest());
      await ref.read(startupControllerProvider.notifier).signOut();
      await _reloadOwnerState();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthResult> _run(Future<AuthResult> Function() action) async {
    state = const AsyncLoading();
    try {
      final result = await action();
      if (result.session case final session?) {
        final userId = session.user?.id;
        if (userId != null && userId.isNotEmpty) {
          await ref
              .read(dataOwnershipStoreProvider)
              .switchTo(DataOwner.user(userId));
        }
        await ref
            .read(startupControllerProvider.notifier)
            .setAuthSession(session);
        await _reloadOwnerState();
      }
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return const AuthResult.failure(AuthFailure.unknown);
    }
  }

  Future<void> _reloadOwnerState() async {
    ref.invalidate(learnerSelectionProvider);
    ref.invalidate(learnerProfileProvider);
    ref.invalidate(onboardingProvider);
    await ref.read(progressionProvider.notifier).reload();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

final guestModeAllowedProvider = Provider<bool>((ref) => true);
