import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vocabulary_repository.dart';
import '../domain/vocabulary_entry.dart';
import '../../story/data/story_services.dart';
import '../../story/domain/story_definition.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>(
  (ref) => SharedPreferencesVocabularyRepository(),
);

class VocabularyController extends AsyncNotifier<List<VocabularyEntry>> {
  @override
  Future<List<VocabularyEntry>> build() =>
      ref.read(vocabularyRepositoryProvider).readAll();

  Future<void> saveStoryWord(String word) async {
    await ref.read(vocabularyRepositoryProvider).save(vocabularyTemplate(word));
    ref.invalidateSelf();
  }

  Future<void> saveStoryVocabularyItem({
    required StoryVocabularyItem item,
    required String storyId,
    required String storyTitle,
    required String worldId,
    required String worldTitle,
  }) async {
    final entry = vocabularyTemplate(
      item.word,
      id: item.id,
      turkishMeaning: item.turkishMeaning,
      englishDefinition: item.englishDefinition,
      pronunciation: item.pronunciation,
      exampleSentence: item.example,
      storyContext: item.storyContext,
      storyTitle: storyTitle,
      storyId: storyId,
      worldId: worldId,
      worldTitle: worldTitle,
    );
    await ref.read(vocabularyRepositoryProvider).save(entry);
    ref.invalidateSelf();
  }

  Future<void> removeWord(String id) async {
    await ref.read(vocabularyRepositoryProvider).remove(id);
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(VocabularyEntry entry) =>
      _update(entry.copyWith(isFavorite: !entry.isFavorite));

  Future<void> toggleDifficult(VocabularyEntry entry) =>
      _update(entry.copyWith(isDifficult: !entry.isDifficult));

  Future<void> saveUserExample(VocabularyEntry entry, String example) =>
      _update(entry.copyWith(userExample: example.trim()));

  Future<VocabularyEntry> recordReview({
    required VocabularyEntry entry,
    required ReviewMode mode,
    required bool correct,
  }) async {
    final reviewedAt = DateTime.now();
    final updated = applyVocabularyReview(
      entry: entry,
      mode: mode,
      correct: correct,
      reviewedAt: reviewedAt,
    );
    await _update(updated);
    await ref.read(storyProgressRepositoryProvider).completeVocabularyReview();
    return updated;
  }

  Future<void> _update(VocabularyEntry entry) async {
    await ref.read(vocabularyRepositoryProvider).update(entry);
    ref.invalidateSelf();
  }
}

final vocabularyProvider =
    AsyncNotifierProvider<VocabularyController, List<VocabularyEntry>>(
      VocabularyController.new,
    );
