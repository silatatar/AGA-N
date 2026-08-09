import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../story/data/story_services.dart';

final homeStoryProgressProvider =
    FutureProvider.autoDispose<StoryProgressSnapshot>(
      (ref) => ref.read(storyProgressRepositoryProvider).readSnapshot(),
    );

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(learnerProfileProvider).value;
    final learnerType = ref.watch(learnerSelectionProvider).value;
    final preferences = ref.watch(onboardingProvider).value;
    final storyState = ref.watch(homeStoryProgressProvider);
    final name = profile?.displayName ?? 'Gezgin';
    final dailyGoal = preferences?.dailyMinutes ?? 15;

    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: Stack(
        children: [
          OpeningAtmosphere(
            child: SafeArea(
              bottom: false,
              child: storyState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: AgainSecondaryButton(
                    label: 'Tekrar dene',
                    onPressed: () => ref.invalidate(homeStoryProgressProvider),
                  ),
                ),
                data: (story) => _DashboardContent(
                  name: name,
                  learnerType: learnerType,
                  dailyGoal: dailyGoal,
                  story: story,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _HomeBottomNav(),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.name,
    required this.learnerType,
    required this.dailyGoal,
    required this.story,
  });
  final String name;
  final LearnerType? learnerType;
  final int dailyGoal;
  final StoryProgressSnapshot story;

  bool get _child => learnerType == LearnerType.child;
  bool get _weatherCompleted => story.completedChapters.contains('hava-durumu');

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 920;
      final cards = <Widget>[
        _HumaGuidanceCard(
          text: _weatherCompleted ? _completedGuidance : _guidance,
          largeAction: _child,
        ),
        _DailyGoalCard(
          minutes: story.minutesToday,
          goal: dailyGoal,
          large: _child,
        ),
        _ContinueStoryCard(completed: _weatherCompleted, large: _child),
        _SeedGrowthCard(growth: story.seedGrowth, xp: story.totalXp),
        _TodayTasksCard(story: story, concise: _child),
        _VocabularyCard(words: story.savedWords, concise: _child),
        const _RecommendedStoryCard(),
        _WeeklyProgressCard(minutesToday: story.minutesToday, goal: dailyGoal),
      ];
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AgainSpacing.lg,
          AgainSpacing.lg,
          AgainSpacing.lg,
          110,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            key: const Key('home-greeting'),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: AgainColors.gold400),
                          ),
                          Text(
                            _subtitle,
                            style: const TextStyle(color: AgainColors.mist),
                          ),
                        ],
                      ),
                    ),
                    const HumaAvatar(size: 62),
                  ],
                ),
                const SizedBox(height: AgainSpacing.xl),
                if (desktop)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AgainSpacing.md,
                          mainAxisSpacing: AgainSpacing.md,
                          mainAxisExtent: 330,
                        ),
                    itemCount: cards.length,
                    itemBuilder: (_, index) => cards[index],
                  )
                else
                  ...cards.expand(
                    (card) => [
                      SizedBox(height: 370, child: card),
                      const SizedBox(height: AgainSpacing.md),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  String get _greeting {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Günaydın'
        : hour < 18
        ? 'Merhaba'
        : 'İyi akşamlar';
    return '$greeting, $name.';
  }

  String get _subtitle => switch (learnerType) {
    LearnerType.child => 'Bugün küçük bir keşfe çıkalım!',
    LearnerType.teen => 'Yeni bir hikâyenin kilidini açmaya hazır mısın?',
    LearnerType.adult => 'Bugünkü öğrenme planın hazır.',
    null => 'Yolculuğuna kaldığın yerden devam et.',
  };

  String get _guidance => switch (learnerType) {
    LearnerType.child => 'Deniz Krallığı’nda havayı keşfedelim.',
    LearnerType.teen =>
      'Deniz Krallığı’nda fırtına yaklaşıyor. Hikâyeye katıl!',
    _ => 'Bugün Deniz Krallığı’nda hava durumunu öğrenebiliriz.',
  };

  String get _completedGuidance => switch (learnerType) {
    LearnerType.child => 'Harika! Tohumuna yeni bir yaprak ekledin.',
    LearnerType.teen => 'Hava Durumu tamam! Sıradaki rota seni bekliyor.',
    _ =>
      'Hava Durumu bölümünü tamamladın. Kelimelerini kısa bir tekrar güçlendirir.',
  };
}

class _HumaGuidanceCard extends StatelessWidget {
  const _HumaGuidanceCard({required this.text, required this.largeAction});
  final String text;
  final bool largeAction;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HumaAvatar(size: largeAction ? 78 : 62),
        const SizedBox(width: AgainSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hüma’dan bir not',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AgainSpacing.xs),
              Text(text),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.minutes,
    required this.goal,
    required this.large,
  });
  final int minutes;
  final int goal;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (minutes / goal).clamp(0.0, 1.0);
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(icon: Icons.today_rounded, title: 'Günlük hedef'),
          const Spacer(),
          Text(
            '$minutes / $goal dakika',
            key: const Key('home-daily-goal'),
            style: TextStyle(
              fontSize: large ? 30 : 25,
              fontWeight: FontWeight.w900,
              color: AgainColors.turquoise100,
            ),
          ),
          const SizedBox(height: AgainSpacing.sm),
          LinearProgressIndicator(
            value: progress,
            minHeight: large ? 12 : 8,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AgainColors.night700,
            color: AgainColors.emerald200,
          ),
          const SizedBox(height: AgainSpacing.xs),
          Text(
            progress >= 1
                ? 'Bugünkü hedef tamamlandı.'
                : 'Her dakika ilerlemene katkı sağlar.',
            style: const TextStyle(color: AgainColors.mist),
          ),
        ],
      ),
    );
  }
}

class _ContinueStoryCard extends StatelessWidget {
  const _ContinueStoryCard({required this.completed, required this.large});
  final bool completed;
  final bool large;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          icon: Icons.auto_stories_rounded,
          title: 'Hikâyeye devam et',
        ),
        const Spacer(),
        Text(
          'Deniz Krallığı — Hava Durumu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AgainSpacing.xs),
        Text(
          completed ? 'Tamamlandı · Tekrar edebilirsin' : 'Fırtına Öncesi',
          style: const TextStyle(color: AgainColors.mist),
        ),
        const SizedBox(height: AgainSpacing.md),
        AgainPrimaryButton(
          key: const Key('home-continue-story'),
          label: completed ? 'Tekrar Et' : 'Devam Et',
          icon: Icons.play_arrow_rounded,
          onPressed: () =>
              context.push('/world/deniz-kralligi/chapter/hava-durumu'),
        ),
      ],
    ),
  );
}

class _SeedGrowthCard extends StatelessWidget {
  const _SeedGrowthCard({required this.growth, required this.xp});
  final int growth;
  final int xp;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(icon: Icons.spa_rounded, title: 'Tohum Vadisi'),
        const Spacer(),
        Row(
          children: [
            const Icon(
              Icons.park_rounded,
              size: 66,
              color: AgainColors.emerald200,
            ),
            const SizedBox(width: AgainSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$growth büyüme izi',
                    key: const Key('home-seed-growth'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '$xp XP ile besleniyor',
                    style: const TextStyle(color: AgainColors.mist),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TodayTasksCard extends StatelessWidget {
  const _TodayTasksCard({required this.story, required this.concise});
  final StoryProgressSnapshot story;
  final bool concise;
  @override
  Widget build(BuildContext context) {
    final tasks = [
      ('Bir cümle dinle', story.minutesToday > 0),
      ('Bir kelime kaydet', story.savedWords.isNotEmpty),
      ('Hava Durumu hikâyesi', story.completedChapters.contains('hava-durumu')),
    ];
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.task_alt_rounded,
            title: 'Bugünün görevleri',
          ),
          const SizedBox(height: AgainSpacing.sm),
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AgainSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    task.$2 ? Icons.check_circle : Icons.circle_outlined,
                    color: task.$2 ? AgainColors.emerald200 : AgainColors.slate,
                  ),
                  const SizedBox(width: AgainSpacing.sm),
                  Expanded(
                    child: Text(
                      concise ? task.$1.split(' ').take(3).join(' ') : task.$1,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('open-daily-tasks'),
              onPressed: () => context.push(AppRoutes.dailyTasksPath),
              child: const Text('Tüm görevleri gör'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  const _VocabularyCard({required this.words, required this.concise});
  final Set<String> words;
  final bool concise;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          icon: Icons.bookmarks_outlined,
          title: 'Kelime tekrarı',
        ),
        const SizedBox(height: AgainSpacing.md),
        if (words.isEmpty)
          const Text(
            'Henüz kelime kaydetmedin. Hikâyede bir kelimeye dokunabilirsin.',
            style: TextStyle(color: AgainColors.mist),
          )
        else ...[
          Wrap(
            spacing: AgainSpacing.xs,
            runSpacing: AgainSpacing.xs,
            children: words
                .take(concise ? 3 : 6)
                .map((word) => Chip(label: Text(word)))
                .toList(),
          ),
          const Spacer(),
          Text('${words.length} kelime tekrar için hazır.'),
        ],
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            key: const Key('open-vocabulary-garden'),
            onPressed: () => context.push(AppRoutes.vocabularyGardenPath),
            child: const Text('Kelime Bahçesi’ni Aç'),
          ),
        ),
      ],
    ),
  );
}

class _RecommendedStoryCard extends StatelessWidget {
  const _RecommendedStoryCard();
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          icon: Icons.explore_outlined,
          title: 'Önerilen hikâye',
        ),
        const Spacer(),
        Text('Ulaşım Araçları', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AgainSpacing.xs),
        const Text(
          'Deniz Krallığı · 14 dakika · 16 kelime',
          style: TextStyle(color: AgainColors.mist),
        ),
        const SizedBox(height: AgainSpacing.md),
        AgainSecondaryButton(
          label: 'Bölümü Gör',
          onPressed: () => context.push('/world/deniz-kralligi'),
        ),
      ],
    ),
  );
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.minutesToday, required this.goal});
  final int minutesToday;
  final int goal;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.bar_chart_rounded,
            title: 'Haftalık ilerleme',
          ),
          const Spacer(),
          SizedBox(
            height: 104,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final minutes = index == today ? minutesToday : 0;
                final height = goal == 0
                    ? 8.0
                    : 8 + 62 * (minutes / goal).clamp(0.0, 1.0);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: AgainDurations.micro,
                        width: 18,
                        height: height,
                        decoration: BoxDecoration(
                          color: index == today
                              ? AgainColors.turquoise300
                              : AgainColors.night700,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: AgainSpacing.xs),
                      Text(
                        const ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'][index],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AgainColors.gold400),
      const SizedBox(width: AgainSpacing.sm),
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    ],
  );
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.all(AgainSpacing.sm),
      decoration: BoxDecoration(
        color: AgainColors.night900.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(AgainRadii.card),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .5)),
      ),
      child: NavigationBar(
        height: 72,
        backgroundColor: Colors.transparent,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.go(AppRoutes.worldMapPath);
          } else if (index == 2) {
            context.go(AppRoutes.storySquarePath);
          } else if (index == 3) {
            context.go(AppRoutes.humaConversationPath);
          } else if (index == 4) {
            context.go(AppRoutes.profilePath);
          } else if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bu alan yakında açılacak.')),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Meydan',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Hüma',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    ),
  );
}
