import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_views.dart';
import '../../features/design_system/presentation/design_system_preview_screen.dart';
import '../../features/atlas/presentation/atlas_screen.dart';
import '../../features/conversation/presentation/huma_conversation_screen.dart';
import '../../features/auth/presentation/account_decision_screen.dart';
import '../../features/auth/presentation/auth_form_screen.dart';
import '../../features/auth/presentation/password_reset_screen.dart';
import '../../features/foundation/presentation/not_found_screen.dart';
import '../../features/home/presentation/home_dashboard_screen.dart';
import '../../features/learner_profile/presentation/learner_profile_selection_screen.dart';
import '../../features/learner_profile/presentation/profile_name_setup_screen.dart';
import '../../features/onboarding/presentation/personalised_onboarding_screen.dart';
import '../../features/story/data/story_repository.dart';
import '../../features/story/domain/story_definition.dart';
import '../../features/story/presentation/data_driven_story_player_screen.dart';
import '../../features/story/presentation/story_entry_gate.dart';
import '../../features/story_square/presentation/story_square_screen.dart';
import '../../features/tasks/presentation/daily_tasks_screen.dart';
import '../../features/world/domain/world_region.dart';
import '../../features/world/presentation/world_detail_screen.dart';
import '../../features/world/presentation/world_map_screen.dart';
import '../../features/vocabulary/domain/vocabulary_entry.dart';
import '../../features/vocabulary/presentation/vocabulary_garden_screen.dart';
import '../../features/vocabulary/presentation/vocabulary_review_screen.dart';
import '../../features/vocabulary/presentation/word_detail_screen.dart';
import '../../features/opening/presentation/flutter_splash_screen.dart';
import '../../features/opening/presentation/huma_arrival_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/startup/startup_decision.dart';
import '../../features/sync/application/data_ownership_provider.dart';
import 'route_access_policy.dart';

abstract final class AppRoutes {
  static const designSystem = 'designSystem';
  static const designSystemPath = '/design-system';
  static const home = 'home';
  static const homePath = '/home';
  static const humaConversation = 'humaConversation';
  static const humaConversationPath = '/huma';
  static const humaChat = 'humaChat';
  static const humaChatPath = '/huma/chat';
  static const humaSummary = 'humaSummary';
  static const humaSummaryPath = '/huma/summary';
  static const storySquare = 'storySquare';
  static const storySquarePath = '/square';
  static const profile = 'profile';
  static const profilePath = '/profile';
  static const atlas = 'atlas';
  static const atlasPath = '/atlas';
  static const atlasWorld = 'atlasWorld';
  static const atlasWorldPath = '/atlas/world/:slug';
  static const dailyTasks = 'dailyTasks';
  static const dailyTasksPath = '/daily-tasks';
  static const vocabularyGarden = 'vocabularyGarden';
  static const vocabularyGardenPath = '/vocabulary';
  static const wordDetail = 'wordDetail';
  static const wordDetailPath = '/vocabulary/:wordId';
  static const vocabularyReview = 'vocabularyReview';
  static const vocabularyReviewPath = '/vocabulary/:wordId/review/:mode';
  static const splash = 'splash';
  static const splashPath = '/splash';
  static const humaArrival = 'humaArrival';
  static const humaArrivalPath = '/huma-arrival';
  static const learnerProfiles = 'learnerProfiles';
  static const learnerProfilesPath = '/learner-profiles';
  static const profileName = 'profileName';
  static const profileNamePath = '/profile-name';
  static const learningGoal = 'learningGoal';
  static const learningGoalPath = '/learning-goal';
  static const accountDecision = 'accountDecision';
  static const accountDecisionPath = '/account-decision';
  static const login = 'login';
  static const loginPath = '/login';
  static const register = 'register';
  static const registerPath = '/register';
  static const passwordReset = 'passwordReset';
  static const passwordResetPath = '/password-reset';
  static const emailVerification = 'emailVerification';
  static const emailVerificationPath = '/email-verification';
  static const storyIntro = 'storyIntro';
  static const storyIntroPath = '/story-intro';
  static const story = 'story';
  static const storyPath = '/story/:storyId';
  static const worldMap = 'worldMap';
  static const worldMapPath = '/world-map';
  static const worldDetail = 'worldDetail';
  static const worldDetailPath = '/world/:slug';
  static const chapterIntro = 'chapterIntro';
  static const chapterIntroPath = '/world/:slug/chapter/:chapterId';
}

final routerAccessSnapshotProvider = FutureProvider<RouterAccessSnapshot>((
  ref,
) async {
  final startup = await ref.watch(startupControllerProvider.future);
  final owner = await ref.read(dataOwnershipStoreProvider).current();
  return RouterAccessSnapshot.ready(
    session: startup.auth,
    onboardingComplete: startup.onboardingComplete,
    ownerNamespace: owner.namespace,
  );
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = RouterAccessRefreshBridge();
  ref
    ..listen(
      routerAccessSnapshotProvider,
      (_, next) => refresh.update(next),
      fireImmediately: true,
    )
    ..onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      return refresh.redirect(state.uri.path);
    },
    routes: [
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        name: AppRoutes.humaConversation,
        path: AppRoutes.humaConversationPath,
        builder: (context, state) => const HumaConversationEntryScreen(),
      ),
      GoRoute(
        name: AppRoutes.humaChat,
        path: AppRoutes.humaChatPath,
        builder: (context, state) => const HumaConversationChatScreen(),
      ),
      GoRoute(
        name: AppRoutes.humaSummary,
        path: AppRoutes.humaSummaryPath,
        builder: (context, state) => const HumaConversationSummaryScreen(),
      ),
      GoRoute(
        name: AppRoutes.storySquare,
        path: AppRoutes.storySquarePath,
        builder: (context, state) => const StorySquareScreen(),
      ),
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.atlasWorld,
        path: AppRoutes.atlasWorldPath,
        builder: (context, state) =>
            AtlasWorldDetailScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        name: AppRoutes.atlas,
        path: AppRoutes.atlasPath,
        builder: (context, state) => const AtlasScreen(),
      ),
      GoRoute(
        name: AppRoutes.dailyTasks,
        path: AppRoutes.dailyTasksPath,
        builder: (context, state) => const DailyTasksScreen(),
      ),
      GoRoute(
        name: AppRoutes.vocabularyGarden,
        path: AppRoutes.vocabularyGardenPath,
        builder: (context, state) => const VocabularyGardenScreen(),
      ),
      GoRoute(
        name: AppRoutes.vocabularyReview,
        path: AppRoutes.vocabularyReviewPath,
        builder: (context, state) {
          final modeName = state.pathParameters['mode'] ?? '';
          final mode = ReviewMode.values
              .where((item) => item.name == modeName)
              .firstOrNull;
          return mode == null
              ? const NotFoundScreen()
              : VocabularyReviewScreen(
                  wordId: state.pathParameters['wordId'] ?? '',
                  mode: mode,
                );
        },
      ),
      GoRoute(
        name: AppRoutes.wordDetail,
        path: AppRoutes.wordDetailPath,
        builder: (context, state) =>
            WordDetailScreen(wordId: state.pathParameters['wordId'] ?? ''),
      ),
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splashPath,
        builder: (context, state) => const FlutterSplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.humaArrival,
        path: AppRoutes.humaArrivalPath,
        builder: (context, state) => const HumaArrivalScreen(),
      ),
      GoRoute(
        name: AppRoutes.learnerProfiles,
        path: AppRoutes.learnerProfilesPath,
        builder: (context, state) => const LearnerProfileSelectionScreen(),
      ),
      GoRoute(
        name: AppRoutes.profileName,
        path: AppRoutes.profileNamePath,
        builder: (context, state) => const ProfileNameSetupScreen(),
      ),
      GoRoute(
        name: AppRoutes.learningGoal,
        path: AppRoutes.learningGoalPath,
        builder: (context, state) => const PersonalisedOnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.accountDecision,
        path: AppRoutes.accountDecisionPath,
        builder: (context, state) => const AccountDecisionScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        builder: (context, state) =>
            const AuthFormScreen(mode: AuthFormMode.login),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: AppRoutes.registerPath,
        builder: (context, state) =>
            const AuthFormScreen(mode: AuthFormMode.register),
      ),
      GoRoute(
        name: AppRoutes.passwordReset,
        path: AppRoutes.passwordResetPath,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        name: AppRoutes.emailVerification,
        path: AppRoutes.emailVerificationPath,
        builder: (context, state) => EmailVerificationScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        name: AppRoutes.storyIntro,
        path: AppRoutes.storyIntroPath,
        builder: (context, state) =>
            const DataDrivenStoryPlayerScreen(storyId: 'first-encounter'),
      ),
      GoRoute(
        name: AppRoutes.story,
        path: AppRoutes.storyPath,
        builder: (context, state) =>
            _StoryRouteScreen(storyId: state.pathParameters['storyId'] ?? ''),
      ),
      GoRoute(
        name: AppRoutes.worldMap,
        path: AppRoutes.worldMapPath,
        builder: (context, state) => const WorldMapScreen(),
      ),
      GoRoute(
        name: AppRoutes.chapterIntro,
        path: AppRoutes.chapterIntroPath,
        builder: (context, state) {
          final region = regionBySlug(state.pathParameters['slug'] ?? '');
          final chapterId = state.pathParameters['chapterId'] ?? '';
          return region == null
              ? const NotFoundScreen()
              : StoryEntryGate(region: region, chapterId: chapterId);
        },
      ),
      GoRoute(
        name: AppRoutes.worldDetail,
        path: AppRoutes.worldDetailPath,
        builder: (context, state) {
          final region = regionBySlug(state.pathParameters['slug'] ?? '');
          return region == null
              ? const NotFoundScreen()
              : WorldDetailScreen(region: region);
        },
      ),
      GoRoute(
        name: AppRoutes.designSystem,
        path: AppRoutes.designSystemPath,
        builder: (context, state) => const DesignSystemPreviewScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

class _StoryRouteScreen extends ConsumerStatefulWidget {
  const _StoryRouteScreen({required this.storyId});

  final String storyId;

  @override
  ConsumerState<_StoryRouteScreen> createState() => _StoryRouteScreenState();
}

class _StoryRouteScreenState extends ConsumerState<_StoryRouteScreen> {
  late final Future<StoryDefinition?> _story;

  @override
  void initState() {
    super.initState();
    _story = ref.read(storyRepositoryProvider).getStory(widget.storyId);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<StoryDefinition?>(
    future: _story,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: LoadingView());
      }
      if (snapshot.hasError || snapshot.data == null) {
        return const NotFoundScreen();
      }
      return DataDrivenStoryPlayerScreen(storyId: widget.storyId);
    },
  );
}

/// Exactly one controlled reactive bridge refreshes GoRouter. Equal snapshots
/// do not churn the router or create redirect loops.
class RouterAccessRefreshBridge extends ChangeNotifier {
  RouterAccessSnapshot _snapshot = const RouterAccessSnapshot.loading();
  String? _pendingLocation;

  RouterAccessSnapshot get snapshot => _snapshot;
  String? get pendingLocation => _pendingLocation;

  String? redirect(String path) {
    final decision = RouteAccessPolicy.decide(
      path: path,
      snapshot: _snapshot,
      pendingLocation: _pendingLocation,
    );
    _pendingLocation = decision.pendingLocation;
    return decision.redirect;
  }

  void update(AsyncValue<RouterAccessSnapshot> value) {
    final next = value.value ?? const RouterAccessSnapshot.loading();
    if (next == _snapshot) return;
    _snapshot = next;
    notifyListeners();
  }
}
