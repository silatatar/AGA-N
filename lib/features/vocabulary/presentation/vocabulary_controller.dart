import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vocabulary_repository.dart';
import '../domain/vocabulary_entry.dart';

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
    final streak = correct ? entry.correctStreak + 1 : 0;
    final interval = correct ? const [1, 3, 7, 14][streak.clamp(1, 4) - 1] : 1;
    final mastery = !correct
        ? WordMastery.learning
        : streak >= 4
        ? WordMastery.mastered
        : streak >= 2
        ? WordMastery.familiar
        : WordMastery.learning;
    final updated = entry.copyWith(
      mastery: mastery,
      reviewCount: entry.reviewCount + 1,
      correctStreak: streak,
      intervalDays: interval,
      nextReviewAt: DateTime.now().add(Duration(days: interval)),
      isDifficult: correct ? entry.isDifficult : true,
      lastReviewMode: mode,
    );
    await _update(updated);
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
