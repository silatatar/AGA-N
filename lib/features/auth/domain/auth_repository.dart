import 'auth_session.dart';

enum AuthFailure {
  network,
  incorrectCredentials,
  offline,
  emailInUse,
  providerUnavailable,
  unknown,
}

class AuthResult {
  const AuthResult.success({this.session}) : failure = null;
  const AuthResult.failure(this.failure) : session = null;
  final AuthFailure? failure;
  final AuthSession? session;
  bool get isSuccess => failure == null;
}

abstract interface class AuthRepository {
  Future<AuthSession> getCurrentSession();
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> requestPasswordReset(String email);
  Future<AuthResult> resendVerification(String email);
  Future<void> signOut();
}
