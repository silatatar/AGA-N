import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/backend_config.dart';
import '../../../core/backend/supabase_runtime.dart';
import '../data/cloud_progress_repository.dart';
import '../data/supabase_cloud_progress_repository.dart';
import '../domain/sync_service.dart';

final cloudProgressRepositoryProvider = Provider<CloudProgressRepository>(
  (ref) => switch (SupabaseRuntime.config.status) {
    BackendStatus.supabaseConfigured => SupabaseCloudProgressRepository(
      SupabaseRuntime.client!,
    ),
    BackendStatus.developmentLocal || BackendStatus.supabaseUnconfigured =>
      const UnconfiguredCloudProgressRepository(),
  },
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(cloudProgressRepositoryProvider)),
);
