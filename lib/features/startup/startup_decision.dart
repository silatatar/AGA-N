import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../learner_profile/presentation/learner_selection_controller.dart';
import '../onboarding/presentation/onboarding_controller.dart';

enum AuthSessionKind {
  unauthenticated,
  guest,
  developmentAuthenticated,
  productionAuthenticated,
}

class AuthSession {
  const AuthSession(this.kind, {this.userId});
  final AuthSessionKind kind;
  final String? userId;
  bool get canEnterProduct => kind != AuthSessionKind.unauthenticated;
}

enum StartupDestination {
  humaArrival,
  learnerProfiles,
  profileName,
  onboarding,
  accountDecision,
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
  if (!session.canEnterProduct) {
    return StartupDestination.accountDecision;
  }
  return StartupDestination.home;
}

class StartupState {
  const StartupState({
    this.schemaVersion = 1,
    this.auth = const AuthSession(AuthSessionKind.unauthenticated),
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
    'auth': auth.kind.name,
    'userId': auth.userId,
    'onboardingComplete': onboardingComplete,
  };
  factory StartupState.fromJson(Map<String, Object?> j) => StartupState(
    schemaVersion: j['schemaVersion'] as int? ?? 1,
    auth: AuthSession(
      AuthSessionKind.values.where((e) => e.name == j['auth']).firstOrNull ??
          AuthSessionKind.unauthenticated,
      userId: j['userId'] as String?,
    ),
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
      auth: const AuthSession(AuthSessionKind.guest),
    ),
  );
  Future<void> developmentAuthenticated(String userId) async => _save(
    (state.value ?? const StartupState()).copyWith(
      onboardingComplete: true,
      auth: AuthSession(
        AuthSessionKind.developmentAuthenticated,
        userId: userId,
      ),
    ),
  );
  Future<void> _save(StartupState value) async {
    state = AsyncData(value);
    await ref.read(startupRepositoryProvider).save(value);
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
