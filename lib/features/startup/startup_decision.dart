import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/domain/auth_session.dart';
import '../learner_profile/presentation/learner_selection_controller.dart';
import '../learner_profile/data/learner_personalization_store.dart';
import '../onboarding/presentation/onboarding_controller.dart';
import '../sync/application/data_ownership_provider.dart';

enum StartupDestination {
  humaArrival,
  learnerProfiles,
  profileName,
  onboarding,
  accountDecision,
  emailVerification,
  home,
}

StartupDestination decideStartup({
  required bool hasLearnerType,
  required bool hasProfile,
  required bool onboardingComplete,
  required bool answersComplete,
  required AuthSession session,
}) {
  if (!hasLearnerType) {
    return StartupDestination.humaArrival;
  }
  if (!hasProfile) {
    return StartupDestination.profileName;
  }
  if (!onboardingComplete && !answersComplete) {
    return StartupDestination.onboarding;
  }
  if (session.status == AuthStatus.emailVerificationRequired) {
    return StartupDestination.emailVerification;
  }
  if (!session.canUseLocalLearning) {
    return StartupDestination.accountDecision;
  }
  return StartupDestination.home;
}

class StartupState {
  const StartupState({
    this.schemaVersion = 1,
    this.auth = const AuthSession(status: AuthStatus.unauthenticated),
    this.onboardingComplete = false,
  });
  final int schemaVersion;
  final AuthSession auth;
  final bool onboardingComplete;
  StartupState copyWith({AuthSession? auth, bool? onboardingComplete}) =>
      StartupState(
        schemaVersion: schemaVersion,
        auth: auth ?? this.auth,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'auth': auth.status.name,
    'userId': auth.user?.id,
    'email': auth.user?.email,
    'displayName': auth.user?.displayName,
    'emailVerified': auth.user?.emailVerified,
    'createdAt': auth.user?.createdAt.toIso8601String(),
    'onboardingComplete': onboardingComplete,
  };
  factory StartupState.fromJson(Map<String, Object?> j) => StartupState(
    schemaVersion: j['schemaVersion'] as int? ?? 1,
    auth: _sessionFromJson(j),
    onboardingComplete: j['onboardingComplete'] as bool? ?? false,
  );
}

abstract interface class StartupRepository {
  Future<StartupState> read();
  Future<void> save(StartupState value);
}

class SharedPreferencesStartupRepository implements StartupRepository {
  SharedPreferencesStartupRepository({SharedPreferencesAsync? preferences})
    : _prefs = preferences;
  static const key = 'again.startup.v1';
  final SharedPreferencesAsync? _prefs;
  SharedPreferencesAsync get preferences => _prefs ?? SharedPreferencesAsync();
  @override
  Future<StartupState> read() async {
    final raw = await preferences.getString(key);
    if (raw == null) return const StartupState();
    return StartupState.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  Future<void> save(StartupState value) =>
      preferences.setString(key, jsonEncode(value.toJson()));
}

class MemoryStartupRepository implements StartupRepository {
  MemoryStartupRepository([this.value = const StartupState()]);
  StartupState value;
  @override
  Future<StartupState> read() async => value;
  @override
  Future<void> save(StartupState v) async => value = v;
}

final startupRepositoryProvider = Provider<StartupRepository>(
  (ref) => SharedPreferencesStartupRepository(),
);
final startupControllerProvider =
    AsyncNotifierProvider<StartupController, StartupState>(
      StartupController.new,
    );

class StartupController extends AsyncNotifier<StartupState> {
  @override
  Future<StartupState> build() async {
    try {
      return await ref.read(startupRepositoryProvider).read();
    } catch (_) {
      return const StartupState();
    }
  }

  Future<void> completeOnboarding() async => _save(
    (state.value ?? const StartupState()).copyWith(onboardingComplete: true),
  );
  Future<void> continueAsGuest() async => _save(
    (state.value ?? const StartupState()).copyWith(
      onboardingComplete: true,
      auth: const AuthSession(status: AuthStatus.guest),
    ),
  );
  Future<void> setAuthSession(AuthSession session) async => _save(
    (state.value ?? const StartupState()).copyWith(
      onboardingComplete: true,
      auth: session,
    ),
  );

  Future<void> signOut() async => _save(
    (state.value ?? const StartupState()).copyWith(
      auth: const AuthSession(status: AuthStatus.unauthenticated),
    ),
  );
  Future<void> _save(StartupState value) async {
    state = AsyncData(value);
    await ref.read(startupRepositoryProvider).save(value);
    try {
      final store = LearnerPersonalizationStore(
        ownership: ref.read(dataOwnershipStoreProvider),
      );
      final profile = await store.read();
      await store.save(
        profile.copyWith(onboardingComplete: value.onboardingComplete),
      );
    } catch (_) {
      // Startup remains authoritative if the optional migration mirror cannot
      // be reached on an unsupported local-storage platform.
    }
  }

  Future<StartupDestination> decide() async {
    final startup = state.value ?? await build();
    final learner = ref.read(learnerPreferenceRepositoryProvider);
    final type = await learner.readLearnerType();
    final profile = await learner.readProfile();
    final onboarding = await ref.read(onboardingRepositoryProvider).read();
    final answersComplete =
        onboarding.goals.isNotEmpty &&
        onboarding.level != null &&
        onboarding.interests.isNotEmpty &&
        onboarding.dailyMinutes != null;
    return decideStartup(
      hasLearnerType: type != null,
      hasProfile: profile != null,
      onboardingComplete: startup.onboardingComplete,
      answersComplete: answersComplete,
      session: startup.auth,
    );
  }
}

AuthSession _sessionFromJson(Map<String, Object?> json) {
  final legacy = json['auth'] as String?;
  final status = switch (legacy) {
    'guest' => AuthStatus.guest,
    'authenticated' => AuthStatus.authenticated,
    'emailVerificationRequired' => AuthStatus.emailVerificationRequired,
    _ => AuthStatus.unauthenticated,
  };
  final userId = json['userId'] as String?;
  if (userId == null ||
      status == AuthStatus.guest ||
      status == AuthStatus.unauthenticated) {
    return AuthSession(status: status);
  }
  final verified = json['emailVerified'] == true;
  return AuthSession(
    status: verified
        ? AuthStatus.authenticated
        : AuthStatus.emailVerificationRequired,
    user: AuthUser(
      id: userId,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      emailVerified: verified,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    ),
  );
}
