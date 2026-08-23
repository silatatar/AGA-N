import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();
  static const _failure = AuthResult.failure(AuthFailure.providerUnavailable);
  @override
  Future<AuthSession> getCurrentSession() async =>
      const AuthSession(status: AuthStatus.unauthenticated);
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async => _failure;
  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async => _failure;
  @override
  Future<AuthResult> requestPasswordReset(String email) async => _failure;
  @override
  Future<AuthResult> resendVerification(String email) async => _failure;
  @override
  Future<void> signOut() async {}
}
