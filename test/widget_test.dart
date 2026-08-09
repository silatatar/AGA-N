import 'package:again/app/again_app.dart';
import 'package:again/app/router/app_router.dart';
import 'package:again/features/atlas/presentation/atlas_controller.dart';
import 'package:again/features/learner_profile/data/learner_preference_repository.dart';
import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/learner_profile/domain/learner_profile.dart';
import 'package:again/features/learner_profile/presentation/learner_selection_controller.dart';
import 'package:again/features/learner_profile/presentation/learner_profile_controller.dart';
import 'package:again/features/home/presentation/home_dashboard_screen.dart';
import 'package:again/features/onboarding/data/onboarding_preferences_repository.dart';
import 'package:again/features/onboarding/domain/onboarding_preferences.dart';
import 'package:again/features/onboarding/presentation/onboarding_controller.dart';
import 'package:again/features/profile/presentation/profile_progress_controller.dart';
import 'package:again/features/auth/domain/auth_repository.dart';
import 'package:again/features/auth/presentation/auth_controller.dart';
import 'package:again/features/story/data/story_services.dart';
import 'package:again/features/tasks/presentation/daily_tasks_screen.dart';
import 'package:again/features/vocabulary/data/vocabulary_repository.dart';
import 'package:again/features/vocabulary/domain/vocabulary_entry.dart';
import 'package:again/features/vocabulary/presentation/vocabulary_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLearnerPreferenceRepository implements LearnerPreferenceRepository {
  LearnerType? stored;
  LearnerProfile? profile;

  @override
  Future<LearnerProfile?> readProfile() async => profile;

  @override
  Future<LearnerType?> readLearnerType() async => stored;

  @override
  Future<void> saveLearnerType(LearnerType type) async {
    stored = type;
  }

  @override
  Future<void> saveProfile(LearnerProfile value) async {
    profile = value;
  }
}

class FakeOnboardingRepository implements OnboardingPreferencesRepository {
  OnboardingPreferences stored = const OnboardingPreferences();

  @override
  Future<OnboardingPreferences> read() async => stored;

  @override
  Future<void> save(OnboardingPreferences preferences) async {
    stored = preferences;
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async => const AuthResult.failure(AuthFailure.incorrectCredentials);
  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async => const AuthResult.success();
  @override
  Future<AuthResult> requestPasswordReset(String email) async =>
      const AuthResult.success();
  @override
  Future<AuthResult> resendVerification(String email) async =>
      const AuthResult.success();
}

class FakeStoryAudioService implements StoryAudioService {
  int plays = 0;
  @override
  Future<void> playPhrase(String phrase) async {
    plays++;
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> replayPhrase(String phrase) => playPhrase(phrase);
}

class FakeStoryProgressRepository implements StoryProgressRepository {
  bool awarded = false;
  final Set<String> words = {};
  final Set<String> chapters = {};
  int minutes = 0;
  int xp = 0;
  int listening = 0;
  int speaking = 0;
  int reviews = 0;
  int rewardGrowth = 0;
  final Set<String> claimedRewards = {};
  @override
  Future<void> awardFirstSeed() async {
    awarded = true;
  }

  @override
  Future<bool> hasFirstSeed() async => awarded;

  @override
  Future<void> saveWord(String word) async => words.add(word);

  @override
  Future<void> removeWord(String word) async => words.remove(word);

  @override
  Future<void> completeChapter({
    required String chapterId,
    required int minutes,
    required int xp,
  }) async {
    chapters.add(chapterId);
    this.minutes += minutes;
    this.xp += xp;
    listening++;
  }

  @override
  Future<void> completeVocabularyReview() async => reviews++;

  @override
  Future<void> claimDailyReward({
    required String taskId,
    required int xp,
    required int seedGrowth,
  }) async {
    if (!claimedRewards.add(taskId)) return;
    this.xp += xp;
    rewardGrowth += seedGrowth;
  }

  @override
  Future<StoryProgressSnapshot> readSnapshot() async => StoryProgressSnapshot(
    hasFirstSeed: awarded,
    savedWords: {...words},
    completedChapters: {...chapters},
    minutesToday: minutes,
    totalXp: xp,
    listeningActivities: listening,
    speakingMinutes: speaking,
    vocabularyReviews: reviews,
    claimedTaskRewards: {...claimedRewards},
    rewardSeedGrowth: rewardGrowth,
  );
}

class FakeVocabularyRepository implements VocabularyRepository {
  final List<VocabularyEntry> entries = [];

  @override
  Future<List<VocabularyEntry>> readAll() async => [...entries];

  @override
  Future<void> save(VocabularyEntry entry) async {
    if (!entries.any((item) => item.id == entry.id)) entries.add(entry);
  }

  @override
  Future<void> remove(String id) async {
    entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<void> update(VocabularyEntry entry) async {
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index >= 0) entries[index] = entry;
  }
}

void main() {
  Future<
    (
      ProviderContainer,
      FakeLearnerPreferenceRepository,
      FakeOnboardingRepository,
      FakeStoryProgressRepository,
      FakeStoryAudioService,
      FakeVocabularyRepository,
    )
  >
  pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    String? route,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeLearnerPreferenceRepository();
    final onboardingRepository = FakeOnboardingRepository();
    final storyProgress = FakeStoryProgressRepository();
    final storyAudio = FakeStoryAudioService();
    final vocabularyRepository = FakeVocabularyRepository();
    final container = ProviderContainer(
      overrides: [
        learnerPreferenceRepositoryProvider.overrideWithValue(repository),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        storyProgressRepositoryProvider.overrideWithValue(storyProgress),
        storyAudioServiceProvider.overrideWithValue(storyAudio),
        vocabularyRepositoryProvider.overrideWithValue(vocabularyRepository),
      ],
    );
    addTearDown(container.dispose);
    if (route != null) container.read(appRouterProvider).go(route);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AgainApp()),
    );
    await tester.pump();
    return (
      container,
      repository,
      onboardingRepository,
      storyProgress,
      storyAudio,
      vocabularyRepository,
    );
  }

  testWidgets('Hüma cafe conversation completes from scenario to summary', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.humaConversationPath);

    expect(find.byKey(const Key('scenario-cafe')), findsOneWidget);
    await tester.tap(find.byKey(const Key('scenario-cafe')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Blue Shell'), findsOneWidget);

    await tester.tap(find.byKey(const Key('translate-huma-0')));
    await tester.pump();
    expect(find.textContaining('Mavi Kabuk'), findsOneWidget);

    await tester.tap(find.text('I’d like a coffee, please.'));
    await tester.pump();
    expect(find.byKey(const Key('typing-indicator')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('What size'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('conversation-input')),
      'i want coffee please',
    );
    await tester.tap(find.byKey(const Key('correct-sentence')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Daha doğal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('replay-huma-0')));
    await tester.pump();
    expect(result.$5.plays, 1);

    await tester.tap(find.byKey(const Key('end-session')));
    await tester.pumpAndSettle();
    expect(find.text('Konuşma tamamlandı'), findsOneWidget);
    expect(find.text('Güçlü ifadeler'), findsOneWidget);
    expect(find.text('Düzeltmeler'), findsOneWidget);
    expect(find.text('Yeni kelimeler'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'story square identifies demo activity and runs guided practice',
    (tester) async {
      await pumpApp(tester, route: AppRoutes.storySquarePath);
      await tester.pumpAndSettle();

      expect(find.text('Hikâye Meydanı'), findsOneWidget);
      expect(find.text('İç demo'), findsOneWidget);
      expect(find.byKey(const Key('fictional-demo-activity')), findsOneWidget);
      expect(find.textContaining('kurgusal demo içeriğidir'), findsOneWidget);

      await tester.tap(find.byKey(const Key('square-microphone')));
      await tester.pumpAndSettle();
      expect(find.text('Hüma ile prova'), findsOneWidget);
      await tester.tap(find.text('The people make it feel like home.'));
      await tester.pump();
      expect(find.byKey(const Key('guided-practice-feedback')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('child story square prevents unrestricted community exposure', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.storySquarePath);
    await result.$1
        .read(learnerSelectionProvider.notifier)
        .select(LearnerType.child);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('child-safe-square')), findsOneWidget);
    expect(find.byKey(const Key('fictional-demo-activity')), findsNothing);
    expect(find.byKey(const Key('square-area-generalChat')), findsNothing);
    expect(
      find.byKey(const Key('square-area-humaGroupPractice')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('square-microphone')));
    await tester.pumpAndSettle();
    expect(find.textContaining('başka kişilerle'), findsNothing);
    expect(find.text('My family makes me happy.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile reflects actual learner and prototype progress state', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.profilePath);
    result.$2
      ..stored = LearnerType.adult
      ..profile = const LearnerProfile(
        displayName: 'Aslı',
        avatar: LearnerAvatar.compass,
      );
    result.$3.stored = const OnboardingPreferences(
      level: EnglishLevel.conversational,
      dailyMinutes: 15,
    );
    result.$4
      ..awarded = true
      ..minutes = 18
      ..xp = 270
      ..speaking = 7
      ..rewardGrowth = 2
      ..chapters.addAll({'first-story', 'hava-durumu'});
    result.$6.entries.add(
      vocabularyTemplate('cloudy').copyWith(mastery: WordMastery.learning),
    );
    result.$1.invalidate(learnerSelectionProvider);
    result.$1.invalidate(learnerProfileProvider);
    result.$1.invalidate(onboardingProvider);
    result.$1.invalidate(vocabularyProvider);
    result.$1.invalidate(profileProgressProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-display-name')), findsOneWidget);
    expect(find.text('Aslı'), findsOneWidget);
    expect(find.text('Yetişkin • Konuşma'), findsOneWidget);
    expect(find.text('270 XP'), findsOneWidget);
    expect(find.text('7 dk'), findsOneWidget);
    expect(find.text('18 dk'), findsOneWidget);
    expect(find.text('İlk filiz'), findsOneWidget);
    expect(find.text('5 / 6 • sonraki büyüme eşiği'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Atlas archives three current worlds and opens lore detail', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.atlasPath);
    result.$4
      ..awarded = true
      ..chapters.add('hava-durumu');
    result.$6.entries.add(vocabularyTemplate('cloudy'));
    result.$1.invalidate(vocabularyProvider);
    result.$1.invalidate(atlasProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('atlas-progress')), findsOneWidget);
    expect(find.text('Keşfedilen: 3 / 11'), findsOneWidget);
    expect(find.byKey(const Key('atlas-world-yasam-vadisi')), findsOneWidget);
    expect(find.byKey(const Key('atlas-world-sessiz-orman')), findsOneWidget);
    expect(find.byKey(const Key('atlas-world-deniz-kralligi')), findsOneWidget);

    final deniz = find.byKey(const Key('atlas-world-deniz-kralligi'));
    await tester.ensureVisible(deniz);
    await tester.tap(deniz);
    await tester.pumpAndSettle();
    expect(find.text('Dünya Kaydı'), findsOneWidget);
    expect(find.text('Deniz Krallığı'), findsOneWidget);
    expect(find.text('Keşfedilen Hikâyeler'), findsOneWidget);
    expect(find.textContaining('Hava Durumu'), findsOneWidget);
    expect(find.text('Kelime Temaları'), findsOneWidget);
    expect(find.text('Kültürel Notlar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Atlas separates character and item collections from map navigation',
    (tester) async {
      final result = await pumpApp(tester, route: AppRoutes.atlasPath);
      result.$4.awarded = true;
      result.$1.invalidate(atlasProvider);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Karakterler'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('atlas-character-Hüma')), findsOneWidget);
      expect(find.byKey(const Key('atlas-character-Mira')), findsOneWidget);
      expect(find.text('Yaşam Vadisi’nde tanıştın'), findsOneWidget);

      await tester.tap(find.text('Eşyalar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('atlas-item-İlk Tohum')), findsOneWidget);
      expect(find.text('İlk Tohum'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('opening flow reaches learner selection and profile name', (
    tester,
  ) async {
    final result = await pumpApp(tester);

    expect(find.text('AGAIN'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump();
    expect(find.text('Merhaba, ben Hüma.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('huma-arrival-continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Kim öğreniyor?'), findsOneWidget);

    await tester.tap(find.text('Yetişkin'));
    await tester.pumpAndSettle();
    expect(result.$2.stored, LearnerType.adult);

    final continueButton = find.byKey(const Key('learner-profile-continue'));
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Sana nasıl seslenelim?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(360, 800), Size(390, 844), Size(412, 915)]) {
    testWidgets(
      'learner selection fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpApp(tester, size: size, route: AppRoutes.learnerProfilesPath);
        await tester.pump();

        expect(find.text('Çocuk'), findsOneWidget);
        expect(find.text('Genç'), findsOneWidget);
        expect(find.text('Yetişkin'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('learner selection presents three cards on desktop', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(1366, 768),
      route: AppRoutes.learnerProfilesPath,
    );
    await tester.pump();

    expect(find.text('Kim öğreniyor?'), findsOneWidget);
    expect(find.text('7–12'), findsOneWidget);
    expect(find.text('13–17'), findsOneWidget);
    expect(find.text('18+'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile setup validates, previews, saves and continues', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.profileNamePath);
    await tester.pumpAndSettle();

    expect(find.text('Sana nasıl seslenelim?'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('display-name-field')), 'Aslı');
    await tester.pump();
    expect(find.text('Tanıştığımıza sevindim, Aslı.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('avatar-forest')));
    await tester.ensureVisible(find.byKey(const Key('profile-name-continue')));
    await tester.tap(find.byKey(const Key('profile-name-continue')));
    await tester.pumpAndSettle();

    expect(result.$2.profile?.displayName, 'Aslı');
    expect(result.$2.profile?.avatar, LearnerAvatar.forest);
    expect(find.text('İngilizce sana hangi kapıları açsın?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile setup explains invalid display names', (tester) async {
    await pumpApp(tester, route: AppRoutes.profileNamePath);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('display-name-field')), 'A1');
    await tester.ensureVisible(find.byKey(const Key('profile-name-continue')));
    await tester.tap(find.byKey(const Key('profile-name-continue')));
    await tester.pump();
    expect(find.textContaining('Yalnızca harf'), findsOneWidget);
    expect(find.text('İngilizce sana hangi kapıları açsın?'), findsNothing);
  });

  testWidgets('child profile does not request a username', (tester) async {
    final result = await pumpApp(tester, route: AppRoutes.profileNamePath);
    await result.$2.saveLearnerType(LearnerType.child);
    result.$1.invalidate(learnerSelectionProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('username-field')), findsNothing);
    expect(find.textContaining('bir yetişkinle'), findsOneWidget);
  });

  testWidgets('profile setup fits compact mobile and desktop', (tester) async {
    await pumpApp(
      tester,
      size: const Size(360, 800),
      route: AppRoutes.profileNamePath,
    );
    await tester.pumpAndSettle();
    expect(find.text('Avatarını seç'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('four onboarding answers persist and reach account decision', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.learningGoalPath);
    await tester.pumpAndSettle();

    expect(find.text('1/4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('goal-Günlük konuşmak')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('onboarding-continue')));
    await tester.tap(find.byKey(const Key('onboarding-continue')));
    await tester.pump();

    expect(find.text('2/4'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('onboarding-back')));
    await tester.tap(find.byKey(const Key('onboarding-back')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilterChip>(find.byKey(const Key('goal-Günlük konuşmak')))
          .selected,
      isTrue,
    );
    await tester.ensureVisible(find.byKey(const Key('onboarding-continue')));
    await tester.tap(find.byKey(const Key('onboarding-continue')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('level-beginner')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('onboarding-continue')));
    await tester.tap(find.byKey(const Key('onboarding-continue')));
    await tester.pump();

    expect(find.text('3/4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('interest-Mitoloji')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('onboarding-continue')));
    await tester.tap(find.byKey(const Key('onboarding-continue')));
    await tester.pump();

    expect(find.text('4/4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('minutes-5')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('onboarding-continue')));
    await tester.tap(find.byKey(const Key('onboarding-continue')));
    await tester.pumpAndSettle();

    expect(result.$3.stored.goals, contains('Günlük konuşmak'));
    expect(result.$3.stored.level, EnglishLevel.beginner);
    expect(result.$3.stored.interests, contains('Mitoloji'));
    expect(result.$3.stored.dailyMinutes, 5);
    expect(find.text('Yolculuğunu kaydet'), findsOneWidget);
  });

  testWidgets('registration reaches email verification', (tester) async {
    await pumpApp(tester, route: AppRoutes.registerPath);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-name')), 'Aslı');
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'asli@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth-password')), 'Again123!');
    await tester.enterText(find.byKey(const Key('auth-confirm')), 'Again123!');
    await tester.tap(find.byKey(const Key('terms-approval')));
    await tester.tap(find.byKey(const Key('privacy-approval')));
    await tester.ensureVisible(find.byKey(const Key('auth-submit')));
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('E-postanı doğrula'), findsOneWidget);
  });

  testWidgets('first story awards seed and reaches world map', (tester) async {
    final result = await pumpApp(tester, route: AppRoutes.storyIntroPath);
    await tester.pumpAndSettle();
    expect(find.text('Burası Yaşam Vadisi.'), findsOneWidget);

    await tester.tap(find.text('Vadiyi keşfet'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-listen')));
    await tester.pumpAndSettle();
    expect(result.$5.plays, 1);
    await tester.tap(find.byKey(const Key('story-word-hello')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hello — Merhaba'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-phrase-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hello, Mira!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İlk tohumunu al'));
    await tester.pumpAndSettle();
    expect(result.$4.awarded, isTrue);
    expect(find.text('İlk kelimen filizlendi.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-to-map')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Dünya Haritası'), findsOneWidget);
    expect(find.byKey(const Key('world-yasam-vadisi')), findsOneWidget);
    await tester.tap(find.byKey(const Key('world-yasam-vadisi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('world-detail-title')), findsOneWidget);
    expect(find.text('Yaşam Vadisi'), findsOneWidget);
  });

  testWidgets('Deniz Krallığı chapters are unique and selectable', (
    tester,
  ) async {
    await pumpApp(tester, route: '/world/deniz-kralligi');
    await tester.pumpAndSettle();

    expect(find.text('Deniz Krallığı'), findsOneWidget);
    for (final title in const [
      'Duygular',
      'Hava Durumu',
      'Ulaşım Araçları',
      'Yolculuk Hazırlığı',
      'Seyahat Planı',
      'Deniz Canlıları',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('15 dk'), findsOneWidget);
    expect(find.text('18 kelime'), findsOneWidget);

    final chapter = find.byKey(const Key('chapter-ulasim-araclari'));
    await tester.ensureVisible(chapter);
    await tester.pumpAndSettle();
    await tester.tap(chapter);
    await tester.pump();
    final continueButton = find.byKey(const Key('chapter-continue'));
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chapter-intro-title')), findsOneWidget);
    expect(find.text('3. Bölüm · Ulaşım Araçları'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hava Durumu story player completes from beginning to end', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      route: '/world/deniz-kralligi/chapter/hava-durumu',
    );
    await tester.pumpAndSettle();

    expect(find.text('Fırtına Öncesi'), findsOneWidget);
    await tester.tap(find.byKey(const Key('audio-play-pause')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('replay-sentence')));
    await tester.pump();
    expect(result.$5.plays, 2);

    await tester.tap(find.byKey(const Key('story-word-rain')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word-panel-title')), findsOneWidget);
    expect(find.text('yağmur'), findsOneWidget);
    await tester.tap(find.byKey(const Key('word-save')));
    await tester.pump();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    final correctChoice = find.text('Take an umbrella.');
    await tester.ensureVisible(correctChoice);
    await tester.pumpAndSettle();
    await tester.tap(correctChoice);
    await tester.pumpAndSettle();
    expect(find.text('İyi düşünce!'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('story-complete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-complete')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-completion-title')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.text('+1 yaprak'), findsOneWidget);
    expect(find.byKey(const Key('completion-continue')), findsOneWidget);
    expect(result.$4.words, contains('rain'));
    expect(result.$6.entries.map((entry) => entry.word), contains('rain'));
    expect(result.$4.chapters, contains('hava-durumu'));
    expect(result.$4.minutes, 15);
    expect(result.$4.xp, 25);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved story word appears in garden and review changes mastery', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.vocabularyGardenPath);
    result.$6.entries.add(vocabularyTemplate('rain'));
    result.$1.invalidate(vocabularyProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('garden-word-rain')), findsOneWidget);
    await tester.tap(find.byKey(const Key('garden-word-rain')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word-detail-title')), findsOneWidget);
    expect(find.text('/reɪn/'), findsOneWidget);

    final meaningMode = find.text('Anlamı Hatırla');
    await tester.ensureVisible(meaningMode);
    await tester.pumpAndSettle();
    await tester.tap(meaningMode);
    await tester.pumpAndSettle();
    await tester.tap(find.text('yağmur'));
    await tester.pumpAndSettle();

    expect(find.text('İyi hatırladın.'), findsOneWidget);
    expect(result.$6.entries.single.reviewCount, 1);
    expect(result.$6.entries.single.correctStreak, 1);
    expect(result.$6.entries.single.mastery, WordMastery.learning);
    expect(find.byKey(const Key('review-finish')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home dashboard reflects persisted learner and story state', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.homePath);
    result.$2.stored = LearnerType.adult;
    result.$2.profile = const LearnerProfile(
      displayName: 'Aslı',
      avatar: LearnerAvatar.huma,
    );
    result.$3.stored = const OnboardingPreferences(dailyMinutes: 15);
    result.$4
      ..awarded = true
      ..words.add('rain')
      ..chapters.add('hava-durumu')
      ..minutes = 15
      ..xp = 25;
    result.$1
      ..invalidate(learnerSelectionProvider)
      ..invalidate(learnerProfileProvider)
      ..invalidate(onboardingProvider)
      ..invalidate(homeStoryProgressProvider);
    await tester.pumpAndSettle();

    expect(find.textContaining('Aslı.'), findsOneWidget);
    expect(find.text('15 / 15 dakika'), findsOneWidget);
    expect(find.text('rain'), findsOneWidget);
    expect(find.text('2 büyüme izi'), findsOneWidget);
    expect(find.text('25 XP ile besleniyor'), findsOneWidget);
    expect(find.text('Tamamlandı · Tekrar edebilirsin'), findsOneWidget);
    expect(find.text('Haftalık ilerleme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('child home dashboard uses concise adaptive copy', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      size: const Size(360, 800),
      route: AppRoutes.homePath,
    );
    result.$2.stored = LearnerType.child;
    result.$2.profile = const LearnerProfile(
      displayName: 'Ece',
      avatar: LearnerAvatar.huma,
    );
    result.$3.stored = const OnboardingPreferences(dailyMinutes: 10);
    result.$1
      ..invalidate(learnerSelectionProvider)
      ..invalidate(learnerProfileProvider)
      ..invalidate(onboardingProvider)
      ..invalidate(homeStoryProgressProvider);
    await tester.pumpAndSettle();

    expect(find.text('Bugün küçük bir keşfe çıkalım!'), findsOneWidget);
    expect(find.text('Deniz Krallığı’nda havayı keşfedelim.'), findsOneWidget);
    expect(find.text('0 / 10 dakika'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('daily tasks use actual progress and rewards claim once', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.dailyTasksPath);
    result.$4
      ..words.add('rain')
      ..chapters.add('hava-durumu')
      ..listening = 1;
    result.$1.invalidate(dailyTaskProgressProvider);
    await tester.pumpAndSettle();

    expect(find.text('2 / 5 görev tamamlandı'), findsOneWidget);
    expect(find.text('1 / 5 kelime kaydedildi'), findsOneWidget);
    expect(find.text('0 / 2 dakika'), findsOneWidget);

    final reviewAction = find.text('Tekrarı Başlat');
    await tester.ensureVisible(reviewAction);
    await tester.pumpAndSettle();
    await tester.tap(reviewAction);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('complete-vocabulary-review')));
    await tester.pumpAndSettle();
    expect(result.$4.reviews, 1);
    expect(find.text('3 / 5 görev tamamlandı'), findsOneWidget);

    final claim = find.byKey(const Key('claim-complete-story'));
    await tester.ensureVisible(claim);
    await tester.pumpAndSettle();
    await tester.tap(claim);
    await tester.pump();
    expect(find.byKey(const Key('reward-moment-title')), findsOneWidget);
    expect(result.$4.xp, 15);
    expect(result.$4.rewardGrowth, 1);
    expect(result.$4.claimedRewards, contains('complete-story'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('design system preview remains available internally', (
    tester,
  ) async {
    await pumpApp(tester, route: AppRoutes.designSystemPath);

    expect(find.text('Tasarım Sistemi Önizlemesi'), findsOneWidget);
  });

  testWidgets('unknown route shows branded error screen', (tester) async {
    await pumpApp(tester, route: '/bilinmeyen-yol');

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Bu yol henüz açılmadı'), findsOneWidget);
  });
}
