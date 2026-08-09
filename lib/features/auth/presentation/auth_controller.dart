import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/development_auth_repository.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DevelopmentAuthRepository(),
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

  Future<AuthResult> _run(Future<AuthResult> Function() action) async {
    state = const AsyncLoading();
    try {
      final result = await action();
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return const AuthResult.failure(AuthFailure.unknown);
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

final guestModeAllowedProvider = Provider<bool>((ref) => true);
