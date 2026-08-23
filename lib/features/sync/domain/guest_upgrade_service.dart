import '../../progression/data/progression_repository.dart';
import 'data_ownership.dart';
import 'sync_models.dart';
import 'sync_service.dart';
import '../../learner_profile/data/learner_personalization_store.dart';

class GuestUpgradeService {
  const GuestUpgradeService({
    required this.ownership,
    required this.localProgress,
    required this.sync,
    this.personalization,
  });

  final DataOwnershipStore ownership;
  final ProgressionRepository localProgress;
  final SyncService sync;
  final LearnerPersonalizationStore? personalization;

  Future<SyncResult> adoptGuestProgress({required String userId}) async {
    if (await ownership.wasGuestAdoptedBy(userId)) {
      return SyncResult.success(
        await localProgress.read(),
        DateTime.now().toUtc(),
      );
    }
    final local = await localProgress.read();
    final localPersonalization = await personalization?.read();
    final result = await sync.synchronize(
      userId: userId,
      local: local,
      localUpdatedAt: DateTime.now().toUtc(),
      localPersonalization: localPersonalization,
    );
    if (!result.isSuccess || result.progress == null) return result;
    await ownership.switchTo(DataOwner.user(userId));
    try {
      await localProgress.save(result.progress!);
      final profile = result.personalization ?? localPersonalization;
      if (profile != null) await personalization?.save(profile);
      await ownership.markGuestAdoptedBy(userId);
    } catch (_) {
      await ownership.switchTo(await ownership.guest());
      rethrow;
    }
    return result;
  }
}
