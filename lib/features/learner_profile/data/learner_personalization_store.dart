import 'dart:convert';

import '../../onboarding/domain/onboarding_preferences.dart';
import '../../sync/data/local_key_value_store.dart';
import '../../sync/domain/data_ownership.dart';
import '../domain/learner_personalization.dart';
import '../domain/learner_profile.dart';
import '../domain/learner_type.dart';

class LearnerPersonalizationStore {
  LearnerPersonalizationStore({LocalKeyValueStore? store, this.ownership})
    : _store = store ?? SharedPreferencesLocalKeyValueStore();

  static const key = 'again.learner_profile.v1';
  static const corruptBackupKey = 'again.learner_profile.corrupt_backup.v1';
  static const legacyTypeKey = 'again.learner_type';
  static const legacyNameKey = 'again.display_name';
  static const legacyUsernameKey = 'again.username';
  static const legacyAvatarKey = 'again.avatar';
  static const legacyOnboardingKey = 'again.onboarding_preferences';
  final LocalKeyValueStore _store;
  final DataOwnershipStore? ownership;

  Future<String> _key(String logical) async => ownership == null
      ? logical
      : (await ownership!.current()).storageKey(logical);

  Future<LearnerPersonalization> read() async {
    final owner = ownership == null ? null : await ownership!.current();
    final scopedKey = await _key(key);
    var raw = await _store.getString(scopedKey);
    if (raw == null && owner != null) {
      if (owner.kind == DataOwnerKind.guest) {
        raw = await _store.getString(key);
        if (raw != null) await _store.setString(scopedKey, raw);
      }
    }
    if (raw != null) {
      try {
        final decoded = LearnerPersonalization.tryFromJson(jsonDecode(raw));
        if (decoded != null) return decoded;
      } catch (_) {
        await _store.setString(await _key(corruptBackupKey), raw);
      }
    }
    // Old installation-wide fields are unclaimed and must not leak into an
    // authenticated account. Only the stable guest namespace may migrate them.
    if (owner?.kind == DataOwnerKind.user) {
      return const LearnerPersonalization();
    }
    final migrated = await _readLegacy();
    if (_hasData(migrated)) await save(migrated);
    return migrated;
  }

  Future<void> save(LearnerPersonalization value) async =>
      _store.setString(await _key(key), jsonEncode(value.toJson()));

  Future<LearnerPersonalization> _readLegacy() async {
    final name = await _store.getString(legacyNameKey);
    final legacyRaw = await _store.getString(legacyOnboardingKey);
    Map<String, Object?> onboarding = const {};
    if (legacyRaw != null) {
      try {
        onboarding = Map<String, Object?>.from(jsonDecode(legacyRaw) as Map);
      } catch (_) {}
    }
    return migrateLegacy(
      learnerType: await _store.getString(legacyTypeKey),
      displayName: name,
      username: await _store.getString(legacyUsernameKey),
      avatar: await _store.getString(legacyAvatarKey),
      onboarding: onboarding,
    );
  }

  static LearnerPersonalization migrateLegacy({
    String? learnerType,
    String? displayName,
    String? username,
    String? avatar,
    Map<String, Object?> onboarding = const {},
  }) {
    final levelName = onboarding['level'];
    final minutes = onboarding['dailyMinutes'];
    return LearnerPersonalization(
      identity: displayName == null || displayName.isEmpty
          ? null
          : LearnerProfile(
              displayName: displayName,
              username: username,
              avatar: LearnerAvatarCopy.fromStorage(avatar),
            ),
      learnerType: LearnerTypeCopy.fromStorage(learnerType),
      preferences: OnboardingPreferences(
        goals: _strings(onboarding['goals']),
        interests: _strings(onboarding['interests']),
        level: EnglishLevel.values
            .where((item) => item.name == levelName)
            .firstOrNull,
        dailyMinutes: minutes is int && minutes > 0 ? minutes : null,
      ),
    );
  }

  bool _hasData(LearnerPersonalization value) =>
      value.identity != null ||
      value.learnerType != null ||
      value.preferences.level != null ||
      value.preferences.goals.isNotEmpty ||
      value.preferences.interests.isNotEmpty ||
      value.preferences.dailyMinutes != null;

  static Set<String> _strings(Object? value) => value is List
      ? value.whereType<String>().where((item) => item.isNotEmpty).toSet()
      : const {};
}
