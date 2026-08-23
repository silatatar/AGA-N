import '../../progression/domain/again_progress.dart';
import '../../learner_profile/domain/learner_personalization.dart';

enum SyncPhase { idle, localOnly, syncing, synced, offline, failed }

enum SyncFailureKind {
  network,
  permission,
  conflict,
  providerUnavailable,
  invalidCloudData,
  unknown,
}

class SyncFailure {
  const SyncFailure(this.kind, {this.safeMessage});
  final SyncFailureKind kind;
  final String? safeMessage;
}

class CloudProgressDocument {
  const CloudProgressDocument({
    required this.schemaVersion,
    required this.userId,
    required this.updatedAt,
    required this.progress,
    this.personalization,
  });

  static const currentSchemaVersion = 1;
  final int schemaVersion;
  final String userId;
  final DateTime updatedAt;
  final AgainProgress progress;
  final LearnerPersonalization? personalization;

  bool isValidFor(String expectedUserId) =>
      schemaVersion == currentSchemaVersion &&
      userId == expectedUserId &&
      !updatedAt.isAfter(DateTime.now().add(const Duration(minutes: 5)));
}

class SyncResult {
  const SyncResult.success(this.progress, this.syncedAt, {this.personalization})
    : failure = null,
      phase = SyncPhase.synced;
  const SyncResult.failure(this.phase, this.failure)
    : progress = null,
      personalization = null,
      syncedAt = null;

  final SyncPhase phase;
  final AgainProgress? progress;
  final LearnerPersonalization? personalization;
  final DateTime? syncedAt;
  final SyncFailure? failure;
  bool get isSuccess => phase == SyncPhase.synced;
}
