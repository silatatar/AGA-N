enum AuthFailure { network, incorrectCredentials, offline, emailInUse, unknown }

class AuthResult {
  const AuthResult.success() : failure = null;
  const AuthResult.failure(this.failure);
  final AuthFailure? failure;
  bool get isSuccess => failure == null;
}

abstract interface class AuthRepository {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> requestPasswordReset(String email);
  Future<AuthResult> resendVerification(String email);
}
