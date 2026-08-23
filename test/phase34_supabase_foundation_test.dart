import 'package:again/core/backend/backend_config.dart';
import 'package:again/features/auth/data/unconfigured_auth_repository.dart';
import 'package:again/features/auth/domain/auth_repository.dart';
import 'package:again/features/learner_profile/domain/learner_personalization.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/sync/data/cloud_progress_repository.dart';
import 'package:again/features/sync/domain/sync_models.dart';
import 'package:again/features/sync/domain/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 34 Supabase foundation', () {
    test('missing public configuration is truthfully unconfigured', () {
      const config = BackendConfig(
        environment: AppEnvironment.production,
        provider: BackendProvider.supabase,
      );
      expect(config.status, BackendStatus.supabaseUnconfigured);
      expect(config.hasProductionBackend, isFalse);
    });

    test('unconfigured auth never fabricates a session', () async {
      const repository = UnconfiguredAuthRepository();
      final result = await repository.login(email: 'a@b.com', password: 'x');
      expect(result.failure, AuthFailure.providerUnavailable);
      expect((await repository.getCurrentSession()).canSync, isFalse);
    });

    test('sync keeps canonical personalization beside progress', () async {
      final cloud = InMemoryCloudProgressRepository();
      final result = await SyncService(cloud).synchronize(
        userId: 'user-1',
        local: const AgainProgress(totalXp: 12),
        localUpdatedAt: DateTime.utc(2026, 8, 21),
        localPersonalization: const LearnerPersonalization(
          onboardingComplete: true,
        ),
      );
      expect(result.isSuccess, isTrue);
      expect(result.personalization?.onboardingComplete, isTrue);
      final stored = await cloud.fetch('user-1');
      expect(stored?.progress.totalXp, 12);
      expect(stored?.personalization?.onboardingComplete, isTrue);
    });

    test('typed cloud permission failure remains typed', () async {
      final result = await SyncService(_DeniedCloud()).synchronize(
        userId: 'wrong-owner',
        local: const AgainProgress(),
        localUpdatedAt: DateTime.utc(2026, 8, 21),
      );
      expect(result.failure?.kind, SyncFailureKind.permission);
    });
  });
}

class _DeniedCloud implements CloudProgressRepository {
  @override
  bool get isConfigured => true;
  @override
  Future<CloudProgressDocument?> fetch(String userId) =>
      throw const CloudRepositoryException(SyncFailureKind.permission);
  @override
  Future<void> push(CloudProgressDocument document) async {}
  @override
  Future<void> deleteForUser(String userId) async {}
}
