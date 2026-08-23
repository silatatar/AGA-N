import 'voice_models.dart';

class VoiceAudioCacheKey {
  const VoiceAudioCacheKey({
    required this.text,
    required this.locale,
    required this.voiceProfile,
    required this.speed,
    required this.contentVersion,
  });

  final String text;
  final String locale;
  final String voiceProfile;
  final EducationalSpeechSpeed speed;
  final String contentVersion;

  String get stableKey =>
      [contentVersion, locale, voiceProfile, speed.name, text.trim()].join('|');

  @override
  bool operator ==(Object other) =>
      other is VoiceAudioCacheKey && other.stableKey == stableKey;

  @override
  int get hashCode => stableKey.hashCode;
}

abstract interface class VoiceAudioCache {
  Future<String?> find(VoiceAudioCacheKey key);
  Future<void> storeTemporary(VoiceAudioCacheKey key, String audioReference);
  Future<void> evict(VoiceAudioCacheKey key);
  Future<void> clearTemporary();
}
