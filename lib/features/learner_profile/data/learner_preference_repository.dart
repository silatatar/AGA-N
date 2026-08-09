import 'package:shared_preferences/shared_preferences.dart';

import '../domain/learner_type.dart';
import '../domain/learner_profile.dart';

abstract interface class LearnerPreferenceRepository {
  Future<LearnerType?> readLearnerType();
  Future<void> saveLearnerType(LearnerType type);
  Future<LearnerProfile?> readProfile();
  Future<void> saveProfile(LearnerProfile profile);
}

class SharedPreferencesLearnerPreferenceRepository
    implements LearnerPreferenceRepository {
  SharedPreferencesLearnerPreferenceRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _learnerTypeKey = 'again.learner_type';
  static const _displayNameKey = 'again.display_name';
  static const _usernameKey = 'again.username';
  static const _avatarKey = 'again.avatar';
  final SharedPreferencesAsync _preferences;

  @override
  Future<LearnerType?> readLearnerType() async => LearnerTypeCopy.fromStorage(
    await _preferences.getString(_learnerTypeKey),
  );

  @override
  Future<void> saveLearnerType(LearnerType type) =>
      _preferences.setString(_learnerTypeKey, type.storageValue);

  @override
  Future<LearnerProfile?> readProfile() async {
    final displayName = await _preferences.getString(_displayNameKey);
    if (displayName == null || displayName.isEmpty) return null;
    return LearnerProfile(
      displayName: displayName,
      username: await _preferences.getString(_usernameKey),
      avatar: LearnerAvatarCopy.fromStorage(
        await _preferences.getString(_avatarKey),
      ),
    );
  }

  @override
  Future<void> saveProfile(LearnerProfile profile) async {
    await _preferences.setString(_displayNameKey, profile.displayName);
    if (profile.username case final username? when username.isNotEmpty) {
      await _preferences.setString(_usernameKey, username);
    } else {
      await _preferences.remove(_usernameKey);
    }
    await _preferences.setString(_avatarKey, profile.avatar.name);
  }
}
