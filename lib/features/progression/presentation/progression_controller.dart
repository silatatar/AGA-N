import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progression_repository.dart';
import '../domain/again_progress.dart';
import '../../sync/application/data_ownership_provider.dart';

final progressionRepositoryProvider = Provider<ProgressionRepository>(
  (ref) => SharedPreferencesProgressionRepository(
    ownership: ref.watch(dataOwnershipStoreProvider),
  ),
);

final progressionProvider =
    AsyncNotifierProvider<ProgressionController, AgainProgress>(
      ProgressionController.new,
    );

class ProgressionController extends AsyncNotifier<AgainProgress> {
  @override
  Future<AgainProgress> build() async {
    try {
      return await ref.read(progressionRepositoryProvider).read();
    } catch (_) {
      return const AgainProgress();
    }
  }

  Future<AgainProgress> record(LearningEvent event) async {
    final current =
        state.value ?? await ref.read(progressionRepositoryProvider).read();
    final updated = current.apply(event);
    state = AsyncData(updated);
    await ref.read(progressionRepositoryProvider).save(updated);
    return updated;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(progressionRepositoryProvider).read,
    );
  }
}
