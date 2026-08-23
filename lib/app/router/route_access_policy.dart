import '../../features/auth/domain/auth_session.dart';

enum RouterAccessResolution { loading, ready }

/// Canonical, typed input consumed by every router access decision.
/// Loading is deliberately distinct from an unauthenticated session.
class RouterAccessSnapshot {
  const RouterAccessSnapshot.loading()
    : resolution = RouterAccessResolution.loading,
      session = null,
      onboardingComplete = false,
      ownerNamespace = null;

  const RouterAccessSnapshot.ready({
    required this.session,
    required this.onboardingComplete,
    required this.ownerNamespace,
  }) : resolution = RouterAccessResolution.ready;

  final RouterAccessResolution resolution;
  final AuthSession? session;
  final bool onboardingComplete;
  final String? ownerNamespace;

  bool get isReady => resolution == RouterAccessResolution.ready;

  @override
  bool operator ==(Object other) =>
      other is RouterAccessSnapshot &&
      resolution == other.resolution &&
      session?.status == other.session?.status &&
      session?.user?.id == other.session?.user?.id &&
      onboardingComplete == other.onboardingComplete &&
      ownerNamespace == other.ownerNamespace;

  @override
  int get hashCode => Object.hash(
    resolution,
    session?.status,
    session?.user?.id,
    onboardingComplete,
    ownerNamespace,
  );
}

/// Single access-decision authority for production and test routers.
/// Product progression locks are intentionally not authentication redirects.
abstract final class RouteAccessPolicy {
  static const publicOnboardingPaths = <String>{
    '/splash',
    '/huma-arrival',
    '/learner-profiles',
    '/profile-name',
    '/learning-goal',
  };

  static const authOnlyPaths = <String>{
    '/account-decision',
    '/login',
    '/register',
    '/password-reset',
  };

  static const emailVerificationPath = '/email-verification';

  static RouteAccessDecision decide({
    required String path,
    required RouterAccessSnapshot snapshot,
    String? pendingLocation,
  }) {
    if (!snapshot.isReady) {
      return RouteAccessDecision(
        redirect: path == '/splash' ? null : '/splash',
        pendingLocation: path == '/splash' ? pendingLocation : path,
      );
    }

    final session = snapshot.session!;
    if (session.status == AuthStatus.emailVerificationRequired) {
      return RouteAccessDecision(
        redirect: path == emailVerificationPath ? null : emailVerificationPath,
        pendingLocation: path == emailVerificationPath || path == '/splash'
            ? pendingLocation
            : path,
      );
    }

    if (!snapshot.onboardingComplete &&
        path == '/splash' &&
        pendingLocation != null &&
        publicOnboardingPaths.contains(pendingLocation)) {
      return RouteAccessDecision(
        redirect: pendingLocation,
        pendingLocation: null,
      );
    }

    if (!snapshot.onboardingComplete) {
      return RouteAccessDecision(
        redirect: publicOnboardingPaths.contains(path) ? null : '/splash',
        pendingLocation: publicOnboardingPaths.contains(path)
            ? pendingLocation
            : (pendingLocation ?? path),
      );
    }

    if (pendingLocation != null &&
        (path == '/splash' || path == emailVerificationPath)) {
      final resumeRedirect = _resolvedRedirect(
        path: pendingLocation,
        session: session,
      );
      return RouteAccessDecision(
        redirect: resumeRedirect ?? pendingLocation,
        pendingLocation: null,
      );
    }

    return RouteAccessDecision(
      redirect: _resolvedRedirect(path: path, session: session),
      pendingLocation: pendingLocation,
    );
  }

  static String? _resolvedRedirect({
    required String path,
    required AuthSession session,
  }) {
    if (path == emailVerificationPath) {
      return session.canUseLocalLearning ? '/home' : '/account-decision';
    }

    if (authOnlyPaths.contains(path)) {
      return session.status == AuthStatus.authenticated ? '/home' : null;
    }

    if (!session.canUseLocalLearning) return '/account-decision';
    return null;
  }
}

class RouteAccessDecision {
  const RouteAccessDecision({
    required this.redirect,
    required this.pendingLocation,
  });

  final String? redirect;
  final String? pendingLocation;
}
