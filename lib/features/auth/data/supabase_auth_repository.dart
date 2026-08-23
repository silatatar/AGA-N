import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<AuthSession> getCurrentSession() async =>
      _mapSession(_client.auth.currentSession);

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final value = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': name.trim()},
    );
    return AuthResult.success(session: _mapSession(value.session, value.user));
  });

  @override
  Future<AuthResult> login({required String email, required String password}) =>
      _guard(() async {
        final value = await _client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        return AuthResult.success(
          session: _mapSession(value.session, value.user),
        );
      });

  @override
  Future<AuthResult> requestPasswordReset(String email) => _guard(() async {
    await _client.auth.resetPasswordForEmail(email.trim());
    return const AuthResult.success();
  });

  @override
  Future<AuthResult> resendVerification(String email) => _guard(() async {
    await _client.auth.resend(
      type: supabase.OtpType.signup,
      email: email.trim(),
    );
    return const AuthResult.success();
  });

  @override
  Future<void> signOut() => _client.auth.signOut();

  AuthSession _mapSession(
    supabase.Session? session, [
    supabase.User? fallback,
  ]) {
    final user = session?.user ?? fallback;
    if (user == null) {
      return const AuthSession(status: AuthStatus.unauthenticated);
    }
    final verified = user.emailConfirmedAt != null;
    final metadataName = user.userMetadata?['display_name'];
    return AuthSession(
      status: verified
          ? AuthStatus.authenticated
          : AuthStatus.emailVerificationRequired,
      user: AuthUser(
        id: user.id,
        email: user.email ?? '',
        displayName: metadataName is String && metadataName.trim().isNotEmpty
            ? metadataName
            : 'AGAIN Gezgini',
        emailVerified: verified,
        createdAt:
            DateTime.tryParse(user.createdAt)?.toUtc() ??
            DateTime.now().toUtc(),
      ),
    );
  }

  Future<AuthResult> _guard(Future<AuthResult> Function() action) async {
    try {
      return await action();
    } on supabase.AuthRetryableFetchException {
      return const AuthResult.failure(AuthFailure.network);
    } on supabase.AuthException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('already') || message.contains('registered')) {
        return const AuthResult.failure(AuthFailure.emailInUse);
      }
      if (message.contains('credential') ||
          message.contains('password') ||
          message.contains('invalid login')) {
        return const AuthResult.failure(AuthFailure.incorrectCredentials);
      }
      return const AuthResult.failure(AuthFailure.unknown);
    } on SocketException {
      return const AuthResult.failure(AuthFailure.offline);
    } catch (_) {
      return const AuthResult.failure(AuthFailure.network);
    }
  }
}
