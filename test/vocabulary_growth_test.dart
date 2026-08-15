import 'package:again/features/vocabulary/domain/vocabulary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 14, 10);

  group('Phase 23 vocabulary growth', () {
    test('newly saved word is a real seed', () {
      final entry = vocabularyTemplate('cloudy', now: now);
      expect(entry.growthState, VocabularyGrowthState.seed);
      expect(entry.reviewCount, 0);
      expect(entry.successfulReviewCount, 0);
    });

    test('opening data does not grow a plant', () {
      final entry = vocabularyTemplate('cloudy', now: now);
      expect(
        VocabularyEntry.fromJson(entry.toJson()).growthState,
        VocabularyGrowthState.seed,
      );
    });

    test('first successful review creates a sprout', () {
      final updated = review(vocabularyTemplate('cloudy', now: now), true, now);
      expect(updated.growthState, VocabularyGrowthState.sprout);
      expect(updated.reviewCount, 1);
      expect(updated.successfulReviewCount, 1);
    });

    test('successful review schedules one day', () {
      final updated = review(vocabularyTemplate('cloudy', now: now), true, now);
      expect(updated.nextReviewAt, now.add(const Duration(days: 1)));
    });

    test('difficult review schedules earlier without success', () {
      final updated = review(
        vocabularyTemplate('cloudy', now: now),
        false,
        now,
      );
      expect(updated.nextReviewAt, now.add(const Duration(hours: 6)));
      expect(updated.successfulReviewCount, 0);
      expect(updated.isDifficult, isTrue);
    });

    test('intervals increase deterministically', () {
      var entry = vocabularyTemplate('cloudy', now: now);
      final intervals = <int>[];
      for (var i = 0; i < 4; i++) {
        entry = review(entry, true, now.add(Duration(days: i)));
        intervals.add(entry.intervalDays);
      }
      expect(intervals, [1, 3, 7, 14]);
    });

    test('mastery requires four consecutive successful reviews', () {
      var entry = vocabularyTemplate('cloudy', now: now);
      for (var i = 0; i < 3; i++) {
        entry = review(entry, true, now.add(Duration(days: i)));
      }
      expect(entry.mastery, isNot(WordMastery.mastered));
      entry = review(entry, true, now.add(const Duration(days: 4)));
      expect(entry.mastery, WordMastery.mastered);
      expect(entry.growthState, VocabularyGrowthState.mastered);
    });

    test('difficulty resets streak and never fabricates mastery', () {
      var entry = vocabularyTemplate('cloudy', now: now);
      entry = review(entry, true, now);
      entry = review(entry, true, now.add(const Duration(days: 1)));
      entry = review(entry, false, now.add(const Duration(days: 2)));
      expect(entry.correctStreak, 0);
      expect(entry.mastery, WordMastery.learning);
    });

    test('due calculation follows next review date', () {
      final due = vocabularyTemplate(
        'cloudy',
        now: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final future = due.copyWith(
        nextReviewAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(due.isDue, isTrue);
      expect(future.isDue, isFalse);
    });

    test('plant variant is deterministic and bounded', () {
      final first = vocabularyTemplate('cloudy', now: now);
      final restart = VocabularyEntry.fromJson(first.toJson());
      expect(first.plantVariant, restart.plantVariant);
      expect(first.plantVariant, inInclusiveRange(0, 3));
    });

    test('story and world origin survive persistence', () {
      final entry = vocabularyTemplate(
        'cloudy',
        now: now,
        storyId: 'weather-story',
        storyTitle: 'Hava Durumu',
        worldId: 'deniz-kralligi',
        worldTitle: 'Deniz Krallığı',
      );
      final restored = VocabularyEntry.fromJson(entry.toJson());
      expect(restored.storyId, 'weather-story');
      expect(restored.worldId, 'deniz-kralligi');
      expect(restored.worldTitle, 'Deniz Krallığı');
    });

    test('old unversioned entry migrates with safe defaults', () {
      final json = vocabularyTemplate('cloudy', now: now).toJson()
        ..remove('discoveredAt')
        ..remove('lastReviewedAt')
        ..remove('successfulReviewCount')
        ..remove('worldId')
        ..remove('storyId')
        ..remove('worldTitle');
      final migrated = VocabularyEntry.fromJson(json);
      expect(migrated.successfulReviewCount, migrated.correctStreak);
      expect(migrated.discoveredAt, migrated.nextReviewAt);
      expect(migrated.worldId, isNull);
    });

    test('review count cannot increase without review function', () {
      final entry = vocabularyTemplate('cloudy', now: now);
      final favorite = entry.copyWith(isFavorite: true);
      expect(favorite.reviewCount, 0);
      expect(favorite.growthState, VocabularyGrowthState.seed);
    });
  });
}

VocabularyEntry review(VocabularyEntry entry, bool correct, DateTime date) =>
    applyVocabularyReview(
      entry: entry,
      mode: ReviewMode.meaningRecall,
      correct: correct,
      reviewedAt: date,
    );
