import 'package:again/features/auth/domain/auth_session.dart';
import 'package:again/features/startup/startup_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 36 production truth', () {
    test('development legacy marker cannot restore authentication', () {
      final state = StartupState.fromJson({
        'auth': 'developmentAuthenticated',
        'userId': 'dev-user',
        'emailVerified': true,
      });
      expect(state.auth.status, AuthStatus.unauthenticated);
      expect(state.auth.user, isNull);
    });

    test('legacy authenticated session is not verified by default', () {
      final state = StartupState.fromJson({
        'auth': 'authenticated',
        'userId': 'user-1',
      });
      expect(state.auth.status, AuthStatus.emailVerificationRequired);
      expect(state.auth.canSync, isFalse);
    });
  });
}
