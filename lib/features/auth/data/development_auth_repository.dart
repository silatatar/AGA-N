import '../domain/auth_repository.dart';

/// Development-only deterministic service. Replace via [AuthRepository]
/// injection when the production backend is configured.
class DevelopmentAuthRepository implements AuthRepository {
  Future<AuthResult> _simulate(String email, {bool credentials = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (email.toLowerCase().startsWith('offline')) {
      return const AuthResult.failure(AuthFailure.offline);
    }
    if (email.toLowerCase().startsWith('network')) {
      return const AuthResult.failure(AuthFailure.network);
    }
    if (credentials) {
      return const AuthResult.failure(AuthFailure.incorrectCredentials);
    }
    return const AuthResult.success();
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) => _simulate(email);

  @override
  Future<AuthResult> login({required String email, required String password}) =>
      _simulate(email, credentials: password != 'Again123!');

  @override
  Future<AuthResult> requestPasswordReset(String email) => _simulate(email);

  @override
  Future<AuthResult> resendVerification(String email) => _simulate(email);
}
