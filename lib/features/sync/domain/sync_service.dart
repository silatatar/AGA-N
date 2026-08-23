import '../../progression/domain/again_progress.dart';
import '../../learner_profile/domain/learner_personalization.dart';
import '../data/cloud_progress_repository.dart';
import 'progress_merge.dart';
import 'sync_models.dart';

class SyncService {
  const SyncService(this.cloud, {this.merge = const ProgressMerge()});
  final CloudProgressRepository cloud;
  final ProgressMerge merge;

  Future<SyncResult> synchronize({
    required String userId,
    required AgainProgress local,
    required DateTime localUpdatedAt,
    LearnerPersonalization? localPersonalization,
  }) async {
    if (!cloud.isConfigured) {
      return const SyncResult.failure(
        SyncPhase.localOnly,
        SyncFailure(SyncFailureKind.providerUnavailable),
      );
    }
    try {
      final remote = await cloud.fetch(userId);
      if (remote != null && !remote.isValidFor(userId)) {
        return const SyncResult.failure(
          SyncPhase.failed,
          SyncFailure(SyncFailureKind.invalidCloudData),
        );
      }
      final now = DateTime.now().toUtc();
      final merged = remote == null
          ? local
          : merge.merge(
              local: local,
              localUpdatedAt: localUpdatedAt,
              cloud: remote.progress,
              cloudUpdatedAt: remote.updatedAt,
            );
      await cloud.push(
        CloudProgressDocument(
          schemaVersion: CloudProgressDocument.currentSchemaVersion,
          userId: userId,
          updatedAt: now,
          progress: merged,
          personalization: localPersonalization ?? remote?.personalization,
        ),
      );
      return SyncResult.success(
        merged,
        now,
        personalization: localPersonalization ?? remote?.personalization,
      );
    } on CloudRepositoryException catch (error) {
      return SyncResult.failure(SyncPhase.failed, SyncFailure(error.kind));
    } catch (_) {
      return const SyncResult.failure(
        SyncPhase.failed,
        SyncFailure(SyncFailureKind.unknown),
      );
    }
  }
}
