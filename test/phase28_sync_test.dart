import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/sync/data/cloud_progress_repository.dart';
import 'package:again/features/sync/domain/progress_merge.dart';
import 'package:again/features/sync/domain/sync_models.dart';
import 'package:again/features/sync/domain/sync_service.dart';
import 'package:again/features/sync/domain/data_ownership.dart';
import 'package:again/features/sync/domain/guest_upgrade_service.dart';
import 'package:again/features/progression/data/progression_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 28 sync foundation', () {
    test('unconfigured cloud remains truthful local-only', () async {
      const service = SyncService(UnconfiguredCloudProgressRepository());
      final result = await service.synchronize(
        userId: 'user-a',
        local: const AgainProgress(totalXp: 20),
        localUpdatedAt: DateTime.utc(2026, 1, 1),
      );
      expect(result.phase, SyncPhase.localOnly);
      expect(result.isSuccess, isFalse);
    });

    test('first upload preserves local progress', () async {
      final cloud = InMemoryCloudProgressRepository();
      final result = await SyncService(cloud).synchronize(
        userId: 'user-a',
        local: const AgainProgress(
          totalXp: 40,
          completedChapterIds: {'first-encounter'},
        ),
        localUpdatedAt: DateTime.utc(2026, 1, 1),
      );
      expect(result.isSuccess, isTrue);
      expect(cloud.documents['user-a']!.progress.totalXp, 40);
    });

    test('merge unions idempotent sets without adding XP', () {
      final result = const ProgressMerge().merge(
        local: const AgainProgress(
          totalXp: 40,
          completedChapterIds: {'first-encounter'},
          savedWordIds: {'hello'},
        ),
        localUpdatedAt: DateTime.utc(2026, 1, 2),
        cloud: const AgainProgress(
          totalXp: 30,
          completedChapterIds: {'hava-durumu'},
          savedWordIds: {'cloudy'},
        ),
        cloudUpdatedAt: DateTime.utc(2026, 1, 1),
      );
      expect(result.totalXp, 40);
      expect(result.completedChapterIds, {'first-encounter', 'hava-durumu'});
      expect(result.savedWordIds, {'hello', 'cloudy'});
    });

    test('invalid user ownership never overwrites local data', () async {
      final cloud = InMemoryCloudProgressRepository();
      cloud.documents['user-a'] = CloudProgressDocument(
        schemaVersion: 1,
        userId: 'user-b',
        updatedAt: DateTime.now().toUtc(),
        progress: const AgainProgress(totalXp: 999),
      );
      final result = await SyncService(cloud).synchronize(
        userId: 'user-a',
        local: const AgainProgress(totalXp: 10),
        localUpdatedAt: DateTime.utc(2026, 1, 1),
      );
      expect(result.failure?.kind, SyncFailureKind.invalidCloudData);
      expect(cloud.documents['user-a']!.progress.totalXp, 999);
    });

    test('guest progress is adopted once without loss', () async {
      final cloud = InMemoryCloudProgressRepository();
      final ownership = MemoryDataOwnershipStore(
        const DataOwner.guest('installation-a'),
      );
      final local = MemoryProgressionRepository(
        const AgainProgress(totalXp: 55, savedWordIds: {'hello'}),
      );
      final service = GuestUpgradeService(
        ownership: ownership,
        localProgress: local,
        sync: SyncService(cloud),
      );
      final first = await service.adoptGuestProgress(userId: 'user-a');
      final second = await service.adoptGuestProgress(userId: 'user-a');
      expect(first.isSuccess, isTrue);
      expect(second.progress?.totalXp, 55);
      expect((await ownership.current()).namespace, 'user:user-a');
      expect(cloud.documents['user-a']?.progress.savedWordIds, {'hello'});
    });

    test('storage namespaces isolate guest and authenticated users', () {
      const guest = DataOwner.guest('installation-a');
      const userA = DataOwner.user('a');
      const userB = DataOwner.user('b');
      expect(guest.storageKey('progress'), isNot(userA.storageKey('progress')));
      expect(userA.storageKey('progress'), isNot(userB.storageKey('progress')));
    });
  });
}
