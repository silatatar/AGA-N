import 'package:again/app/again_app.dart';
import 'package:again/app/router/app_router.dart';
import 'package:again/app/router/route_access_policy.dart';
import 'package:again/features/atlas/presentation/atlas_controller.dart';
import 'package:again/features/learner_profile/data/learner_preference_repository.dart';
import 'package:again/features/learner_profile/domain/learner_type.dart';
import 'package:again/features/learner_profile/domain/learner_profile.dart';
import 'package:again/features/learner_profile/presentation/learner_selection_controller.dart';
import 'package:again/features/learner_profile/presentation/learner_profile_controller.dart';
import 'package:again/features/onboarding/data/onboarding_preferences_repository.dart';
import 'package:again/features/onboarding/domain/onboarding_preferences.dart';
import 'package:again/features/onboarding/presentation/onboarding_controller.dart';
import 'package:again/features/profile/presentation/profile_progress_controller.dart';
import 'package:again/features/progression/presentation/progression_controller.dart';
import 'package:again/features/progression/data/progression_repository.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/auth/domain/auth_repository.dart';
import 'package:again/features/auth/domain/auth_session.dart';
import 'package:again/features/auth/presentation/auth_controller.dart';
import 'package:again/features/startup/startup_decision.dart';
import 'package:again/features/sync/application/data_ownership_provider.dart';
import 'package:again/features/sync/domain/data_ownership.dart';
import 'package:again/features/story/data/story_services.dart';
import 'package:again/features/story/data/story_repository.dart';
import 'package:again/features/story/domain/story_definition.dart';
import 'package:again/features/tasks/presentation/daily_tasks_screen.dart';
import 'package:again/features/world/presentation/world_map_screen.dart';
import 'package:again/features/world/domain/world_visual_profile.dart';
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
  Future<AuthSession> getCurrentSession() async =>
      const AuthSession(status: AuthStatus.unauthenticated);

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
  }) async => AuthResult.success(
    session: AuthSession(
      status: AuthStatus.emailVerificationRequired,
      user: AuthUser(
        id: 'widget-user',
        email: email,
        displayName: name,
        emailVerified: false,
        createdAt: DateTime.utc(2026),
      ),
    ),
  );
  @override
  Future<AuthResult> requestPasswordReset(String email) async =>
      const AuthResult.success();
  @override
  Future<AuthResult> resendVerification(String email) async =>
      const AuthResult.success();

  @override
  Future<void> signOut() async {}
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
    String? storyId,
    String? worldId,
    String? nextChapterId,
    int seedGrowth = 1,
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

class FakeProgressionRepository implements ProgressionRepository {
  AgainProgress progress = const AgainProgress();

  @override
  Future<AgainProgress> read() async => progress;

  @override
  Future<void> save(AgainProgress value) async => progress = value;
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
      FakeProgressionRepository,
    )
  >
  pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    String? route,
    bool audioAvailable = true,
    AgainProgress? initialProgress,
    StoryRepository? storyRepository,
    bool reactiveAccess = false,
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
    final progressionRepository = FakeProgressionRepository();
    final startupRepository = MemoryStartupRepository(
      const StartupState(
        auth: AuthSession(status: AuthStatus.guest),
        onboardingComplete: true,
      ),
    );
    final ownership = MemoryDataOwnershipStore(
      const DataOwner.guest('widget-test'),
    );
    if (initialProgress != null) {
      progressionRepository.progress = initialProgress;
    }
    final container = ProviderContainer(
      overrides: [
        if (!reactiveAccess)
          routerAccessSnapshotProvider.overrideWith(
            (ref) async => const RouterAccessSnapshot.ready(
              session: AuthSession(status: AuthStatus.guest),
              onboardingComplete: true,
              ownerNamespace: 'guest:widget-test',
            ),
          ),
        startupRepositoryProvider.overrideWithValue(startupRepository),
        dataOwnershipStoreProvider.overrideWithValue(ownership),
        learnerPreferenceRepositoryProvider.overrideWithValue(repository),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        storyProgressRepositoryProvider.overrideWithValue(storyProgress),
        storyAudioServiceProvider.overrideWithValue(storyAudio),
        storyAudioAvailabilityProvider.overrideWithValue(audioAvailable),
        vocabularyRepositoryProvider.overrideWithValue(vocabularyRepository),
        progressionRepositoryProvider.overrideWithValue(progressionRepository),
        if (storyRepository != null)
          storyRepositoryProvider.overrideWithValue(storyRepository),
      ],
    );
    addTearDown(container.dispose);
    if (route != null && !reactiveAccess) {
      container.read(appRouterProvider).go(route);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AgainApp()),
    );
    await tester.pump();
    if (route != null && reactiveAccess) {
      await tester.pumpAndSettle();
      container.read(appRouterProvider).go(route);
      await tester.pump();
    }
    return (
      container,
      repository,
      onboardingRepository,
      storyProgress,
      storyAudio,
      vocabularyRepository,
      progressionRepository,
    );
  }

  testWidgets('unavailable Hüma replay is disabled and truthful', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      route: AppRoutes.humaConversationPath,
      audioAvailable: false,
    );
    await tester.tap(find.byKey(const Key('scenario-cafe')));
    await tester.pumpAndSettle();

    final replay = tester.widget<IconButton>(
      find.byKey(const Key('replay-huma-0')),
    );
    expect(replay.onPressed, isNull);
    expect(find.byTooltip('Ses henüz kullanılamıyor'), findsOneWidget);
    expect(result.$5.plays, 0);
  });

  testWidgets('unavailable word pronunciation is disabled and truthful', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      route: '/vocabulary/cloudy',
      audioAvailable: false,
    );
    result.$6.entries.add(vocabularyTemplate('cloudy'));
    result.$1.invalidate(vocabularyProvider);
    await tester.pumpAndSettle();

    final button = tester.widget<IconButton>(
      find.byKey(const Key('word-pronunciation-audio')),
    );
    expect(button.onPressed, isNull);
    expect(find.byTooltip('Ses henüz kullanılamıyor'), findsOneWidget);
    expect(result.$5.plays, 0);
  });

  testWidgets('unavailable vocabulary review audio is disabled', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      route: '/vocabulary/cloudy/review/listeningRecognition',
      audioAvailable: false,
    );
    result.$6.entries.add(vocabularyTemplate('cloudy'));
    result.$1.invalidate(vocabularyProvider);
    await tester.pumpAndSettle();

    final button = tester.widget<IconButton>(
      find.byKey(const Key('review-audio')),
    );
    expect(button.onPressed, isNull);
    expect(find.byTooltip('Ses henüz kullanılamıyor'), findsOneWidget);
    expect(result.$5.plays, 0);
  });

  for (final size in phase19ResponsiveSizes) {
    testWidgets(
      'Phase 19 world map fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpApp(tester, size: size, route: AppRoutes.worldMapPath);
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Dünya Haritası'), findsOneWidget);
        expect(find.byKey(const Key('world-yasam-vadisi')), findsOneWidget);
        expect(find.text('Harita'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Phase 32 locked map node stays inaccessible', (tester) async {
    await pumpApp(
      tester,
      route: AppRoutes.worldMapPath,
      initialProgress: const AgainProgress(),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final lockedForest = find.byKey(const Key('world-sessiz-orman'));
    expect(lockedForest, findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -720),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final lockedTapTarget = find
        .ancestor(of: lockedForest, matching: find.byType(GestureDetector))
        .first;
    tester.widget<GestureDetector>(lockedTapTarget).onTap!();
    await tester.pump();

    expect(find.byKey(const Key('world-sessiz-orman')), findsOneWidget);
    expect(find.byKey(const Key('world-detail-title')), findsNothing);
    expect(find.textContaining('önce mevcut yolculuğunu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phase 32 three world details expose real catalog chapters', (
    tester,
  ) async {
    const progress = AgainProgress(
      unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'},
      unlockedChapterIds: {
        'first-encounter',
        'ben-kimim',
        'gunluk-hayat',
        'sevdigim-seyler',
        'kucuk-bir-gun',
        'ormana-giris',
        'kaybolan-yol',
        'gece-sesleri',
        'duygular',
        'hava-durumu',
        'ulasim-araclari',
        'yolculuk-hazirligi',
      },
    );
    final result = await pumpApp(
      tester,
      route: '/world/yasam-vadisi',
      initialProgress: progress,
    );
    await tester.pumpAndSettle();
    for (final id in const [
      'first-encounter',
      'ben-kimim',
      'gunluk-hayat',
      'sevdigim-seyler',
      'kucuk-bir-gun',
    ]) {
      expect(find.byKey(Key('chapter-$id')), findsOneWidget);
    }
    expect(tester.takeException(), isNull, reason: 'Yaşam Vadisi overflow');

    result.$1.read(appRouterProvider).go('/world/sessiz-orman');
    await tester.pumpAndSettle();
    for (final id in const ['ormana-giris', 'kaybolan-yol', 'gece-sesleri']) {
      expect(find.byKey(Key('chapter-$id')), findsOneWidget);
    }
    expect(tester.takeException(), isNull, reason: 'Sessiz Orman overflow');

    result.$1.read(appRouterProvider).go('/world/deniz-kralligi');
    await tester.pumpAndSettle();
    for (final id in const [
      'duygular',
      'hava-durumu',
      'ulasim-araclari',
      'yolculuk-hazirligi',
      'seyahat-plani',
      'deniz-canlilari',
    ]) {
      expect(find.byKey(Key('chapter-$id')), findsOneWidget);
    }
    for (final id in const [
      'duygular',
      'hava-durumu',
      'ulasim-araclari',
      'yolculuk-hazirligi',
    ]) {
      expect(
        tester.widget<InkWell>(find.byKey(Key('chapter-$id'))).onTap,
        isNotNull,
      );
    }
    expect(
      tester
          .widget<InkWell>(find.byKey(const Key('chapter-seyahat-plani')))
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<InkWell>(find.byKey(const Key('chapter-deniz-canlilari')))
          .onTap,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phase 32 reduced motion keeps world map layout stable', (
    tester,
  ) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await pumpApp(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.worldMapPath,
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('world-yasam-vadisi')), findsOneWidget);
    expect(find.byKey(const Key('world-sessiz-orman')), findsOneWidget);
    expect(find.byKey(const Key('world-deniz-kralligi')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Phase 32 Deniz map environment preserves the existing detail hero', () {
    expect(
      WorldVisualProfiles.seaKingdom.mapEnvironmentAsset,
      'assets/images/worlds/deniz_kralligi/environment_v1.webp',
    );
    expect(
      WorldVisualProfiles.seaKingdom.detailHeroAsset,
      'assets/images/worlds/deniz_kralligi/hero_background.webp',
    );
  });

  testWidgets('Phase 32 available Deniz node opens its real detail', (
    tester,
  ) async {
    await pumpApp(
      tester,
      route: AppRoutes.worldMapPath,
      initialProgress: const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'deniz-kralligi'},
        currentWorldId: 'deniz-kralligi',
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final deniz = find.byKey(const Key('world-deniz-kralligi'));
    expect(deniz, findsOneWidget);
    final tapTarget = find
        .ancestor(of: deniz, matching: find.byType(GestureDetector))
        .first;
    tester.widget<GestureDetector>(tapTarget).onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('world-detail-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in phase19ResponsiveSizes) {
    testWidgets(
      'Phase 23 vocabulary garden fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        final result = await pumpApp(
          tester,
          size: size,
          route: AppRoutes.vocabularyGardenPath,
        );
        result.$6.entries.add(vocabularyTemplate('cloudy'));
        result.$1.invalidate(vocabularyProvider);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('vocabulary-garden-scene')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('garden-plant-cloudy')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in phase19ResponsiveSizes) {
    testWidgets(
      'Phase 22 living home fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpApp(tester, size: size, route: AppRoutes.homePath);
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byKey(const Key('home-greeting')), findsOneWidget);
        expect(find.byKey(const Key('home-scroll')), findsOneWidget);
        expect(find.byKey(const Key('home-continue-story')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in phase19ResponsiveSizes) {
    testWidgets(
      'Phase 20 world detail fits ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpApp(tester, size: size, route: '/world/deniz-kralligi');
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byKey(const Key('world-detail-title')), findsOneWidget);
        expect(find.byKey(const Key('world-detail-scroll')), findsOneWidget);
        expect(find.text('Bölüm Yolculuğu'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
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
      final result = await pumpApp(tester, route: AppRoutes.storySquarePath);
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
      await tester.tap(find.byKey(const Key('complete-guided-practice')));
      await tester.pumpAndSettle();
      expect(result.$7.progress.speakingMinutes, 0);
      expect(find.text('Pratik Tamamlandı'), findsOneWidget);
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
    result.$7.progress = AgainProgress(
      completedChapterIds: const {'first-story', 'hava-durumu'},
      totalXp: 270,
      speakingMinutes: 7,
      firstSeedEarned: true,
      seedGrowth: 5,
      activityHistory: [
        DailyActivity(date: DateTime.now(), learningMinutes: 18),
      ],
    );
    result.$6.entries.add(
      vocabularyTemplate('cloudy').copyWith(mastery: WordMastery.learning),
    );
    result.$1.invalidate(learnerSelectionProvider);
    result.$1.invalidate(learnerProfileProvider);
    result.$1.invalidate(onboardingProvider);
    result.$1.invalidate(vocabularyProvider);
    result.$1.invalidate(progressionProvider);
    result.$1.invalidate(profileProgressProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-display-name')), findsOneWidget);
    expect(find.text('Aslı'), findsOneWidget);
    expect(find.text('Yetişkin • Konuşma'), findsOneWidget);
    expect(find.text('270 XP'), findsOneWidget);
    expect(find.text('7 dk'), findsOneWidget);
    expect(find.text('Haftalık süre'), findsOneWidget);
    expect(find.text('İlk filiz'), findsOneWidget);
    expect(find.text('5 / 6 • sonraki büyüme eşiği'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile preference edit updates the canonical consumer state', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.profilePath);
    result.$2
      ..stored = LearnerType.adult
      ..profile = const LearnerProfile(
        displayName: 'Aslı',
        avatar: LearnerAvatar.huma,
      );
    result.$3.stored = const OnboardingPreferences(
      level: EnglishLevel.words,
      dailyMinutes: 10,
    );
    result.$1
      ..invalidate(learnerSelectionProvider)
      ..invalidate(learnerProfileProvider)
      ..invalidate(onboardingProvider);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Düzenle'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-edit-daily-goal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 dakika').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seyahat etmek'));
    await tester.ensureVisible(find.text('Gizem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gizem'));
    await tester.ensureVisible(
      find.byKey(const Key('save-profile-preferences')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-profile-preferences')));
    await tester.pumpAndSettle();

    expect(result.$3.stored.dailyMinutes, 20);
    expect(result.$3.stored.goals, contains('Seyahat etmek'));
    expect(result.$3.stored.interests, contains('Gizem'));
    expect(find.text('Günlük hedef: 20 dakika'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Atlas archives three current worlds and opens lore detail', (
    tester,
  ) async {
    final result = await pumpApp(tester, route: AppRoutes.atlasPath);
    result.$7.progress = const AgainProgress(
      completedChapterIds: {'first-encounter', 'hava-durumu'},
      unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'},
      firstSeedEarned: true,
    );
    result.$6.entries.add(vocabularyTemplate('cloudy'));
    result.$1.invalidate(vocabularyProvider);
    result.$1.invalidate(progressionProvider);
    result.$1.invalidate(atlasProvider);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('atlas-progress')), findsOneWidget);
    expect(find.text('Keşfedilen: 1 / 11'), findsOneWidget);
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
      result.$7.progress = const AgainProgress(
        completedChapterIds: {'first-encounter'},
        firstSeedEarned: true,
      );
      result.$1.invalidate(progressionProvider);
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

  testWidgets('locked Atlas world cannot be opened by direct route', (
    tester,
  ) async {
    await pumpApp(tester, route: '/atlas/world/sessiz-orman');
    await tester.pumpAndSettle();

    expect(find.text('Bu kayıt henüz kilitli'), findsOneWidget);
    expect(find.text('Dünya Kaydı'), findsOneWidget);
    expect(find.text('Keşfedilen Hikâyeler'), findsNothing);
    expect(tester.takeException(), isNull);
  });

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
    await pumpApp(tester, route: AppRoutes.registerPath, reactiveAccess: true);
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
    expect(result.$5.plays, 0);
    await tester.tap(find.byKey(const Key('story-word-hello')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word-panel-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-phrase-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hello! My name is Ada.'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-complete')));
    await tester.pumpAndSettle();
    expect(result.$4.awarded, isTrue);
    expect(find.text('İlk kelimen filizlendi.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-to-map')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Dünya Haritası'), findsOneWidget);
    expect(find.byKey(const Key('world-yasam-vadisi')), findsOneWidget);
    expect(find.byKey(const Key('world-yasam-vadisi')), findsOneWidget);
  });

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(412, 915),
    Size(600, 960),
    Size(1366, 768),
  ]) {
    testWidgets('first encounter visual pilot is responsive at $size', (
      tester,
    ) async {
      await pumpApp(tester, size: size, route: AppRoutes.storyIntroPath);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('story-scene-valley-arrival')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('story-player-next')));
      await tester.tap(find.byKey(const Key('story-player-next')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('story-scene-valley-meeting')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(412, 915),
    Size(600, 960),
    Size(1366, 768),
  ]) {
    testWidgets('four sea rollout stories render at $size', (tester) async {
      final result = await pumpApp(
        tester,
        size: size,
        route: '/story/duygular',
      );
      await tester.pumpAndSettle();
      for (final entry in const [
        ('duygular', 'sea-gate'),
        ('weather-storm', 'harbour'),
        ('ulasim-araclari', 'sea-station'),
        ('yolculuk-hazirligi', 'travel-room'),
      ]) {
        result.$1.read(appRouterProvider).go('/story/${entry.$1}');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('story-scene-${entry.$2}')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '${entry.$1} at $size');
      }
    });
  }

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(412, 915),
    Size(600, 960),
    Size(1366, 768),
  ]) {
    testWidgets('four valley rollout stories render at $size', (tester) async {
      final result = await pumpApp(
        tester,
        size: size,
        route: '/story/ben-kimim',
      );
      await tester.pumpAndSettle();
      for (final entry in const [
        ('ben-kimim', 'ben-kimim-reflection'),
        ('gunluk-hayat', 'gunluk-hayat-village'),
        ('sevdigim-seyler', 'sevdigim-seyler-garden'),
        ('kucuk-bir-gun', 'kucuk-gun-morning'),
      ]) {
        result.$1.read(appRouterProvider).go('/story/${entry.$1}');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('story-scene-${entry.$2}')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '${entry.$1} at $size');
      }
    });
  }

  testWidgets('visual-less story keeps the branded scene fallback', (
    tester,
  ) async {
    const fixture = StoryDefinition(
      id: 'visual-fallback-fixture',
      worldId: 'test-world',
      chapter: StoryChapter(
        id: 'visual-fallback-fixture',
        number: 1,
        durationMinutes: 1,
        vocabularyCount: 0,
      ),
      title: 'Fallback fixture',
      description: 'Test-only visual fallback fixture.',
      startNodeId: 'start',
      nodes: {
        'start': StoryNode(
          id: 'start',
          scene: StoryScene(id: 'visual-less', artKey: 'visual-less'),
          kind: StoryNodeKind.narration,
          englishText: 'A safe fallback remains visible.',
          nextNodeId: 'complete',
        ),
        'complete': StoryNode(
          id: 'complete',
          scene: StoryScene(id: 'visual-less', artKey: 'visual-less'),
          kind: StoryNodeKind.completion,
          englishText: 'Fallback fixture complete.',
        ),
      },
      reward: StoryReward(xp: 0),
    );
    await pumpApp(
      tester,
      route: '/story/visual-fallback-fixture',
      storyRepository: LocalStoryRepository(
        stories: const {'visual-fallback-fixture': fixture},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('story-scene-fallback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(412, 915),
    Size(600, 960),
    Size(1366, 768),
  ]) {
    testWidgets('three forest rollout stories render at $size', (tester) async {
      final result = await pumpApp(
        tester,
        size: size,
        route: '/story/ormana-giris',
      );
      await tester.pumpAndSettle();
      for (final entry in const [
        ('ormana-giris', 'forest-edge'),
        ('kaybolan-yol', 'forest-trail'),
        ('gece-sesleri', 'forest-night'),
      ]) {
        result.$1.read(appRouterProvider).go('/story/${entry.$1}');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('story-scene-${entry.$2}')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '${entry.$1} at $size');
      }
    });
  }

  testWidgets('all forest chapter cards expose their content covers', (
    tester,
  ) async {
    await pumpApp(
      tester,
      route: '/world/sessiz-orman',
      initialProgress: const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman'},
        unlockedChapterIds: {
          'first-encounter',
          'ormana-giris',
          'kaybolan-yol',
          'gece-sesleri',
        },
      ),
    );
    await tester.pumpAndSettle();
    for (final id in const ['ormana-giris', 'kaybolan-yol', 'gece-sesleri']) {
      final cover = find.byKey(Key('chapter-cover-$id'));
      await tester.ensureVisible(cover);
      await tester.pump();
      expect(cover, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('all valley chapter cards expose their content covers', (
    tester,
  ) async {
    await pumpApp(
      tester,
      route: '/world/yasam-vadisi',
      initialProgress: const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi'},
        unlockedChapterIds: {
          'first-encounter',
          'ben-kimim',
          'gunluk-hayat',
          'sevdigim-seyler',
          'kucuk-bir-gun',
        },
      ),
    );
    await tester.pumpAndSettle();
    for (final id in const [
      'first-encounter',
      'ben-kimim',
      'gunluk-hayat',
      'sevdigim-seyler',
      'kucuk-bir-gun',
    ]) {
      final cover = find.byKey(Key('chapter-cover-$id'));
      await tester.ensureVisible(cover);
      await tester.pump();
      expect(cover, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('all playable sea chapter cards expose their content covers', (
    tester,
  ) async {
    await pumpApp(
      tester,
      route: '/world/deniz-kralligi',
      initialProgress: const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'sessiz-orman', 'deniz-kralligi'},
        unlockedChapterIds: {
          'first-encounter',
          'duygular',
          'hava-durumu',
          'ulasim-araclari',
          'yolculuk-hazirligi',
        },
      ),
    );
    await tester.pumpAndSettle();
    for (final id in const [
      'duygular',
      'hava-durumu',
      'ulasim-araclari',
      'yolculuk-hazirligi',
    ]) {
      final chapter = find.byKey(Key('chapter-$id'));
      expect(chapter, findsOneWidget);
      await tester.ensureVisible(chapter);
      await tester.pump();
      final cover = find.byKey(Key('chapter-cover-$id'));
      expect(cover, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deniz Krallığı chapters are unique and selectable', (
    tester,
  ) async {
    await pumpApp(tester, route: '/world/deniz-kralligi');
    await tester.pumpAndSettle();

    expect(find.text('Deniz Krallığı'), findsOneWidget);
    for (final entry in const [
      ('duygular', 'Duygular'),
      ('hava-durumu', 'Hava Durumu'),
      ('ulasim-araclari', 'Ulaşım Araçları'),
      ('yolculuk-hazirligi', 'Yolculuk Hazırlığı'),
      ('seyahat-plani', 'Seyahat Planı'),
      ('deniz-canlilari', 'Deniz Canlıları'),
    ]) {
      final node = find.byKey(Key('chapter-${entry.$1}'));
      await tester.ensureVisible(node);
      await tester.pump();
      expect(
        find.text(
          '${entry.$1 == 'duygular'
              ? 1
              : entry.$1 == 'hava-durumu'
              ? 2
              : entry.$1 == 'ulasim-araclari'
              ? 3
              : entry.$1 == 'yolculuk-hazirligi'
              ? 4
              : entry.$1 == 'seyahat-plani'
              ? 5
              : 6}. ${entry.$2}',
        ),
        findsOneWidget,
      );
    }
    expect(find.text('15 dk'), findsOneWidget);
    expect(find.text('6 kelime'), findsWidgets);

    expect(find.byKey(const Key('chapter-ulasim-araclari')), findsOneWidget);
    expect(find.byKey(const Key('chapter-hava-durumu')), findsOneWidget);
    expect(find.text('Yakında'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hava Durumu story player completes from beginning to end', (
    tester,
  ) async {
    final result = await pumpApp(
      tester,
      route: '/world/deniz-kralligi/chapter/hava-durumu',
      initialProgress: const AgainProgress(
        unlockedWorldIds: {'yasam-vadisi', 'deniz-kralligi'},
        unlockedChapterIds: {'first-encounter', 'duygular', 'hava-durumu'},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fırtına Öncesi'), findsOneWidget);
    expect(find.text('Ses yakında'), findsOneWidget);
    expect(result.$5.plays, 0);

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
    expect(find.textContaining('doğal'), findsOneWidget);
    await tester.ensureVisible(find.text('Dil ipucu'));
    await tester.tap(find.text('Dil ipucu'));
    await tester.pump();
    expect(find.byKey(const Key('grammar-note')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('story-player-next')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('story-writing')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('story-writing')),
      'It is cloudy today.',
    );
    await tester.ensureVisible(find.byKey(const Key('story-player-next')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('konuşma ilerlemesi kazandırmaz'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('story-player-next')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('story-player-next')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('story-complete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-complete')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-completion-title')), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
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
    await tester.ensureVisible(find.byKey(const Key('garden-word-rain')));
    await tester.pumpAndSettle();
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
      ..invalidate(progressionProvider);
    await tester.pumpAndSettle();

    expect(find.textContaining('Aslı.'), findsOneWidget);
    expect(find.byKey(const Key('home-daily-goal')), findsOneWidget);
    expect(find.byKey(const Key('home-level-xp')), findsOneWidget);
    expect(find.byKey(const Key('home-seed-growth')), findsOneWidget);
    expect(find.byKey(const Key('home-weekly-minutes')), findsOneWidget);
    expect(find.byKey(const Key('home-continue-story')), findsOneWidget);
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
      ..invalidate(onboardingProvider);
    await tester.pumpAndSettle();

    expect(find.textContaining('Ece.'), findsOneWidget);
    expect(find.text('Hüma'), findsWidgets);
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
