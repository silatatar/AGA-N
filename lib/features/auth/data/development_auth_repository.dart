import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

/// Development-only deterministic service. Replace via [AuthRepository]
/// injection when the production backend is configured.
class DevelopmentAuthRepository implements AuthRepository {
  AuthSession _session = const AuthSession(status: AuthStatus.unauthenticated);

  @override
  Future<AuthSession> getCurrentSession() async => _session;

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
  }) async {
    final result = await _simulate(email);
    if (!result.isSuccess) return result;
    final user = AuthUser(
      id: 'dev-${email.trim().toLowerCase().hashCode}',
      email: email.trim().toLowerCase(),
      displayName: name,
      emailVerified: false,
      createdAt: DateTime.now().toUtc(),
    );
    _session = AuthSession(
      status: AuthStatus.emailVerificationRequired,
      user: user,
    );
    return AuthResult.success(session: _session);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _simulate(email, credentials: password != 'Again123!');
    if (!result.isSuccess) return result;
    _session = AuthSession(
      status: AuthStatus.authenticated,
      user: AuthUser(
        id: 'dev-${email.trim().toLowerCase().hashCode}',
        email: email.trim().toLowerCase(),
        displayName: 'AGAIN Gezgini',
        emailVerified: true,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return AuthResult.success(session: _session);
  }

  @override
  Future<AuthResult> requestPasswordReset(String email) async {
    final result = await _simulate(email);
    if (!result.isSuccess) return result;
    return const AuthResult.failure(AuthFailure.providerUnavailable);
  }

  @override
  Future<AuthResult> resendVerification(String email) async {
    final result = await _simulate(email);
    if (!result.isSuccess) return result;
    return const AuthResult.failure(AuthFailure.providerUnavailable);
  }

  @override
  Future<void> signOut() async {
    _session = const AuthSession(status: AuthStatus.unauthenticated);
  }
}
