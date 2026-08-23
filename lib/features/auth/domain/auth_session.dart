enum AuthStatus {
  unauthenticated,
  guest,
  authenticated,
  emailVerificationRequired,
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerified;
  final DateTime createdAt;
}

class AuthSession {
  const AuthSession({required this.status, this.user});

  final AuthStatus status;
  final AuthUser? user;

  bool get canUseLocalLearning =>
      status == AuthStatus.guest || status == AuthStatus.authenticated;

  bool get canSync =>
      status == AuthStatus.authenticated && user?.emailVerified == true;
}

abstract interface class SessionStore {
  Future<AuthSession> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}
