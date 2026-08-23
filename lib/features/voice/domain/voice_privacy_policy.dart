enum VoiceLearnerSafetyProfile { child, teen, adult }

class VoicePrivacyPolicy {
  const VoicePrivacyPolicy({
    required this.profile,
    required this.rawAudioTemporaryOnly,
    required this.allowCommunityVoiceUpload,
    required this.allowStrangerVoiceChat,
    required this.allowPermanentRawAudio,
    required this.requireGuardianReviewForFutureRemoteProcessing,
  });

  final VoiceLearnerSafetyProfile profile;
  final bool rawAudioTemporaryOnly;
  final bool allowCommunityVoiceUpload;
  final bool allowStrangerVoiceChat;
  final bool allowPermanentRawAudio;
  final bool requireGuardianReviewForFutureRemoteProcessing;

  static VoicePrivacyPolicy forProfile(VoiceLearnerSafetyProfile profile) =>
      VoicePrivacyPolicy(
        profile: profile,
        rawAudioTemporaryOnly: true,
        allowCommunityVoiceUpload: false,
        allowStrangerVoiceChat: false,
        allowPermanentRawAudio: false,
        requireGuardianReviewForFutureRemoteProcessing:
            profile == VoiceLearnerSafetyProfile.child,
      );
}

abstract interface class TemporaryRecordingStore {
  Future<void> delete(String temporaryRecordingReference);
}

class VoiceRecordingRetention {
  const VoiceRecordingRetention({required this.store});
  final TemporaryRecordingStore store;

  Future<void> deleteAfterProcessing(String? temporaryReference) async {
    if (temporaryReference == null || temporaryReference.trim().isEmpty) return;
    await store.delete(temporaryReference);
  }

  Future<void> deleteAfterCancellation(String? temporaryReference) =>
      deleteAfterProcessing(temporaryReference);
}
