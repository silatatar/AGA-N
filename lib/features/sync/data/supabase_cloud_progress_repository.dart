import 'package:supabase_flutter/supabase_flutter.dart';

import '../../learner_profile/domain/learner_personalization.dart';
import '../../progression/domain/again_progress.dart';
import '../domain/sync_models.dart';
import 'cloud_progress_repository.dart';

class SupabaseCloudProgressRepository implements CloudProgressRepository {
  SupabaseCloudProgressRepository(this._client);
  final SupabaseClient _client;
  static const table = 'learner_cloud_state';

  @override
  bool get isConfigured => true;

  String _trustedUserId(String requested) {
    final trusted = _client.auth.currentUser?.id;
    if (trusted == null || trusted != requested) {
      throw const CloudRepositoryException(SyncFailureKind.permission);
    }
    return trusted;
  }

  @override
  Future<CloudProgressDocument?> fetch(String userId) async {
    final owner = _trustedUserId(userId);
    final row = await _client
        .from(table)
        .select()
        .eq('user_id', owner)
        .maybeSingle();
    if (row == null) return null;
    try {
      return CloudProgressDocument(
        schemaVersion: row['schema_version'] as int,
        userId: row['user_id'] as String,
        updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
        progress: AgainProgress.fromJson(
          Map<String, Object?>.from(row['progress_data'] as Map),
        ),
        personalization: LearnerPersonalization.tryFromJson(
          row['personalization_data'],
        ),
      );
    } catch (_) {
      throw const CloudRepositoryException(SyncFailureKind.invalidCloudData);
    }
  }

  @override
  Future<void> push(CloudProgressDocument document) async {
    final owner = _trustedUserId(document.userId);
    await _client.from(table).upsert({
      'user_id': owner,
      'schema_version': document.schemaVersion,
      'updated_at': document.updatedAt.toUtc().toIso8601String(),
      'progress_data': document.progress.toJson(),
      'personalization_data': document.personalization?.toJson(),
    }, onConflict: 'user_id');
  }

  @override
  Future<void> deleteForUser(String userId) async {
    final owner = _trustedUserId(userId);
    await _client.from(table).delete().eq('user_id', owner);
  }
}
