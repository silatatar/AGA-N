import 'package:flutter_test/flutter_test.dart';

import 'package:again/features/learner_profile/data/learner_personalization_store.dart';
import 'package:again/features/learner_profile/domain/learner_personalization.dart';
import 'package:again/features/learner_profile/domain/learner_profile.dart';
import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/onboarding/domain/onboarding_preferences.dart';

void main() {
  group('Phase 33 canonical learner personalization', () {
    test('defaults preserve genuinely unconfigured optional values', () {
      const value = LearnerPersonalization();
      expect(value.preferences.level, isNull);
      expect(value.preferences.dailyMinutes, isNull);
      expect(value.preferences.interests, isEmpty);
      expect(value.onboardingComplete, isFalse);
    });

    test('versioned serialization round trip preserves bounded profile', () {
      const value = LearnerPersonalization(
        identity: LearnerProfile(
          displayName: 'Aslı',
          avatar: LearnerAvatar.huma,
        ),
        learnerType: LearnerType.adult,
        preferences: OnboardingPreferences(
          goals: {'Seyahat etmek'},
          level: EnglishLevel.simpleSentences,
          interests: {'Kültür'},
          dailyMinutes: 10,
        ),
        onboardingComplete: true,
      );

      final decoded = LearnerPersonalization.tryFromJson(value.toJson());
      expect(decoded, isNotNull);
      expect(
        decoded!.schemaVersion,
        LearnerPersonalization.currentSchemaVersion,
      );
      expect(decoded.identity?.displayName, 'Aslı');
      expect(decoded.learnerType, LearnerType.adult);
      expect(decoded.preferences.level, EnglishLevel.simpleSentences);
      expect(decoded.preferences.goals, {'Seyahat etmek'});
      expect(decoded.preferences.interests, {'Kültür'});
      expect(decoded.preferences.dailyMinutes, 10);
      expect(decoded.onboardingComplete, isTrue);
    });

    test('corrupt or future records fail safely', () {
      expect(LearnerPersonalization.tryFromJson('broken'), isNull);
      expect(
        LearnerPersonalization.tryFromJson({'schemaVersion': 999}),
        isNull,
      );
    });

    test('unknown values remain unresolved instead of fabricated', () {
      final decoded = LearnerPersonalization.tryFromJson({
        'schemaVersion': 1,
        'learnerType': 'unknown',
        'level': 'certified-c2',
        'dailyMinutes': -5,
        'interests': const [],
      });
      expect(decoded, isNotNull);
      expect(decoded!.learnerType, isNull);
      expect(decoded.preferences.level, isNull);
      expect(decoded.preferences.dailyMinutes, isNull);
      expect(decoded.preferences.interests, isEmpty);
    });

    test('legacy migration preserves values and is idempotent', () async {
      final first = LearnerPersonalizationStore.migrateLegacy(
        learnerType: 'adult',
        displayName: 'Aslı',
        avatar: 'huma',
        onboarding: {
          'goals': ['Seyahat etmek'],
          'level': 'words',
          'interests': ['Tarih'],
          'dailyMinutes': 15,
        },
      );
      final second = LearnerPersonalization.tryFromJson(first.toJson())!;

      expect(first.toJson(), second.toJson());
      expect(first.identity?.displayName, 'Aslı');
      expect(first.learnerType, LearnerType.adult);
      expect(first.preferences.dailyMinutes, 15);
      expect(first.preferences.interests, {'Tarih'});
    });

    test('partial legacy data recovers without fabricated preferences', () {
      final recovered = LearnerPersonalizationStore.migrateLegacy(
        learnerType: 'child',
        displayName: 'Ece',
      );

      expect(recovered.identity?.displayName, 'Ece');
      expect(recovered.learnerType, LearnerType.child);
      expect(recovered.preferences.dailyMinutes, isNull);
    });
  });
}
