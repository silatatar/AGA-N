import 'package:again/app/router/app_router.dart';
import 'package:again/app/router/route_access_policy.dart';
import 'package:again/features/auth/domain/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Phase 28.1 real GoRouter redirect harness', () {
    testWidgets('unresolved loading is splash, never signed out', (
      tester,
    ) async {
      final harness = _RouterHarness(const RouterAccessSnapshot.loading());
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/home', '/splash');
      expect(harness.location, isNot('/account-decision'));
      harness.setSnapshot(_ready(AuthStatus.guest, owner: 'guest:g'));
      await tester.pumpAndSettle();
      expect(harness.location, '/home');
      harness.dispose();
    });

    testWidgets('loading resolves to guest, signed-out and authenticated', (
      tester,
    ) async {
      for (final scenario in [
        (
          snapshot: _ready(AuthStatus.guest, owner: 'guest:g'),
          target: '/world-map',
          expected: '/world-map',
        ),
        (
          snapshot: _ready(AuthStatus.unauthenticated, owner: 'guest:g'),
          target: '/profile',
          expected: '/account-decision',
        ),
        (
          snapshot: _ready(AuthStatus.authenticated, owner: 'user:a'),
          target: '/profile',
          expected: '/profile',
        ),
        (
          snapshot: _ready(
            AuthStatus.emailVerificationRequired,
            owner: 'user:a',
          ),
          target: '/world-map',
          expected: '/email-verification',
        ),
      ]) {
        final harness = _RouterHarness(const RouterAccessSnapshot.loading());
        await tester.pumpWidget(harness.app);
        await _expectLocation(tester, harness, scenario.target, '/splash');
        harness.setSnapshot(scenario.snapshot);
        await tester.pumpAndSettle();
        expect(harness.location, scenario.expected);
        harness.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('verification required is distinct and later authenticates', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.emailVerificationRequired, owner: 'user:a'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(
        tester,
        harness,
        '/world-map',
        '/email-verification',
      );
      harness.setSnapshot(_ready(AuthStatus.authenticated, owner: 'user:a'));
      await tester.pumpAndSettle();
      expect(harness.location, '/world-map');
      harness.dispose();
    });

    testWidgets('onboarding incomplete becomes complete without a loop', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.guest, complete: false, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/home', '/splash');
      harness.setSnapshot(_ready(AuthStatus.guest, owner: 'guest:g'));
      await tester.pumpAndSettle();
      expect(harness.location, '/home');
      harness.dispose();
    });

    testWidgets('loading resumes a safe onboarding destination when ready', (
      tester,
    ) async {
      final harness = _RouterHarness(const RouterAccessSnapshot.loading());
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/profile-name', '/splash');
      harness.setSnapshot(
        _ready(AuthStatus.unauthenticated, complete: false, owner: 'guest:g'),
      );
      await tester.pumpAndSettle();
      expect(harness.location, '/profile-name');
      expect(harness.bridge.pendingLocation, isNull);
      harness.dispose();
    });

    testWidgets('guest can use every offline-first product destination', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.guest, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      for (final path in const [
        '/home',
        '/world-map',
        '/story/playable',
        '/vocabulary',
        '/profile',
        '/atlas',
        '/huma',
      ]) {
        await _expectLocation(tester, harness, path, path);
      }
      harness.dispose();
    });

    testWidgets('auth-only routes distinguish signed-out and authenticated', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.unauthenticated, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      for (final path in const [
        '/account-decision',
        '/login',
        '/register',
        '/password-reset',
      ]) {
        await _expectLocation(tester, harness, path, path);
      }
      harness.setSnapshot(_ready(AuthStatus.authenticated, owner: 'user:a'));
      await _expectLocation(tester, harness, '/login', '/home');
      harness.dispose();
    });

    testWidgets('logout leaves protected content for account decision', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.authenticated, owner: 'user:a'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/home', '/home');
      harness.setSnapshot(_ready(AuthStatus.unauthenticated, owner: 'guest:g'));
      await tester.pumpAndSettle();
      expect(harness.location, '/account-decision');
      harness.dispose();
    });

    testWidgets('owner transitions never leak into access decisions', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.guest, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/vocabulary', '/vocabulary');
      for (final snapshot in [
        _ready(AuthStatus.authenticated, owner: 'user:a'),
        _ready(AuthStatus.guest, owner: 'guest:g'),
        _ready(AuthStatus.authenticated, owner: 'user:b'),
      ]) {
        harness.setSnapshot(snapshot);
        await tester.pumpAndSettle();
        expect(harness.location, '/vocabulary');
      }
      harness.dispose();
    });

    testWidgets('product locks and future chapters are not auth redirects', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.guest, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(
        tester,
        harness,
        '/world/sessiz-orman',
        '/world/sessiz-orman',
      );
      expect(find.text('locked-world'), findsOneWidget);
      await _expectLocation(
        tester,
        harness,
        '/world/deniz-kralligi/chapter/future-deniz',
        '/world/deniz-kralligi/chapter/future-deniz',
      );
      expect(find.text('future-chapter'), findsOneWidget);
      harness.dispose();
    });

    testWidgets('unknown and invalid dynamic paths are branded not found', (
      tester,
    ) async {
      final harness = _RouterHarness(
        _ready(AuthStatus.guest, owner: 'guest:g'),
      );
      await tester.pumpWidget(harness.app);
      await _expectLocation(
        tester,
        harness,
        '/does-not-exist',
        '/does-not-exist',
      );
      expect(find.text('branded-not-found'), findsOneWidget);
      await _expectLocation(
        tester,
        harness,
        '/world/not-a-world',
        '/world/not-a-world',
      );
      expect(find.text('branded-not-found'), findsOneWidget);
      harness.dispose();
    });

    testWidgets('identical snapshots cause no churn or redirect loop', (
      tester,
    ) async {
      final bridge = RouterAccessRefreshBridge();
      var notifications = 0;
      bridge.addListener(() => notifications++);
      final ready = _ready(AuthStatus.guest, owner: 'guest:g');
      bridge.update(AsyncData(ready));
      bridge.update(AsyncData(ready));
      expect(notifications, 1);

      final harness = _RouterHarness(ready);
      await tester.pumpWidget(harness.app);
      await _expectLocation(tester, harness, '/home', '/home');
      harness.setSnapshot(ready);
      await tester.pumpAndSettle();
      expect(harness.location, '/home');
      expect(tester.takeException(), isNull);
      harness.dispose();
      bridge.dispose();
    });
  });
}

RouterAccessSnapshot _ready(
  AuthStatus status, {
  bool complete = true,
  required String owner,
}) => RouterAccessSnapshot.ready(
  session: AuthSession(status: status, user: _userFor(status)),
  onboardingComplete: complete,
  ownerNamespace: owner,
);

AuthUser? _userFor(AuthStatus status) {
  if (status != AuthStatus.authenticated &&
      status != AuthStatus.emailVerificationRequired) {
    return null;
  }
  return AuthUser(
    id: 'trusted-user',
    email: 'learner@example.test',
    displayName: 'Learner',
    emailVerified: status == AuthStatus.authenticated,
    createdAt: DateTime.utc(2026),
  );
}

Future<void> _expectLocation(
  WidgetTester tester,
  _RouterHarness harness,
  String requested,
  String expected,
) async {
  harness.router.go(requested);
  await tester.pumpAndSettle();
  expect(harness.location, expected, reason: 'requested $requested');
  expect(tester.takeException(), isNull);
}

class _RouterHarness {
  _RouterHarness(RouterAccessSnapshot initial)
    : bridge = RouterAccessRefreshBridge() {
    bridge.update(AsyncData(initial));
    router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: bridge,
      redirect: (_, state) => bridge.redirect(state.uri.path),
      routes: [
        for (final path in const [
          '/splash',
          '/profile-name',
          '/home',
          '/world-map',
          '/story/:storyId',
          '/vocabulary',
          '/profile',
          '/atlas',
          '/huma',
          '/account-decision',
          '/login',
          '/register',
          '/password-reset',
          '/email-verification',
        ])
          GoRoute(path: path, builder: (_, state) => Text(state.uri.path)),
        GoRoute(
          path: '/world/:slug',
          builder: (_, state) => Text(
            state.pathParameters['slug'] == 'sessiz-orman'
                ? 'locked-world'
                : 'branded-not-found',
          ),
        ),
        GoRoute(
          path: '/world/:slug/chapter/:chapterId',
          builder: (_, state) => Text(
            state.pathParameters['chapterId'] == 'future-deniz'
                ? 'future-chapter'
                : 'chapter',
          ),
        ),
      ],
      errorBuilder: (_, _) => const Text('branded-not-found'),
    );
  }

  final RouterAccessRefreshBridge bridge;
  late final GoRouter router;
  String get location => router.routeInformationProvider.value.uri.path;
  Widget get app => MaterialApp.router(routerConfig: router);

  void setSnapshot(RouterAccessSnapshot value) {
    bridge.update(AsyncData(value));
  }

  void dispose() {
    router.dispose();
    bridge.dispose();
  }
}
