import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/again_navigation.dart';
import '../../../core/widgets/state_views.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_personalization_provider.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../story/data/story_repository.dart';
import '../../vocabulary/domain/vocabulary_entry.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../../world/domain/world_visual_profile.dart';
import '../domain/home_learning_priority.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalization = ref.watch(learnerPersonalizationProvider);
    final progress = ref.watch(progressionProvider);
    final vocabulary = ref.watch(vocabularyProvider);
    final humaMessage = ref.watch(humaMessageProvider(HumaScreen.home));
    if (personalization.isLoading ||
        progress.isLoading ||
        vocabulary.isLoading) {
      return const Scaffold(
        backgroundColor: AgainColors.night950,
        body: LoadingView(message: 'Dünyan hazırlanıyor…'),
      );
    }
    if (personalization.hasError || progress.hasError || vocabulary.hasError) {
      return Scaffold(
        backgroundColor: AgainColors.night950,
        body: ErrorView(
          title: 'Yolculuk kısa bir mola verdi',
          message: 'Dünyana bağlanırken küçük bir sorun oluştu.',
          onRetry: () {
            ref.invalidate(learnerPersonalizationProvider);
            ref.invalidate(progressionProvider);
            ref.invalidate(vocabularyProvider);
          },
        ),
      );
    }
    return _LivingHome(
      name: personalization.value?.identity?.displayName ?? 'Gezgin',
      learnerType: personalization.value?.learnerType,
      preferences:
          personalization.value?.preferences ?? const OnboardingPreferences(),
      progress: progress.value ?? const AgainProgress(),
      words: vocabulary.value ?? const [],
      humaMessage: humaMessage,
    );
  }
}

class _LivingHome extends StatelessWidget {
  const _LivingHome({
    required this.name,
    required this.learnerType,
    required this.preferences,
    required this.progress,
    required this.words,
    required this.humaMessage,
  });
  final String name;
  final LearnerType? learnerType;
  final OnboardingPreferences preferences;
  final AgainProgress progress;
  final List<VocabularyEntry> words;
  final HumaMessage humaMessage;

  @override
  Widget build(BuildContext context) {
    final due = words.where((word) => word.isDue).length;
    final priority = resolveHomeLearningPriority(
      progress: progress,
      catalog: localStoryCatalog,
      dueWords: due,
      learnerType: learnerType,
      goals: preferences.goals,
      interests: preferences.interests,
    );
    final child = learnerType == LearnerType.child;
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          final content = _HomeContent(
            name: name,
            learnerType: learnerType,
            preferences: preferences,
            progress: progress,
            words: words,
            priority: priority,
            humaMessage: humaMessage,
            child: child,
            wide: wide,
          );
          if (!wide) {
            return Stack(
              children: [
                content,
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _HomeNavigation(),
                ),
              ],
            );
          }
          return Row(
            children: [
              const SafeArea(child: _HomeRail()),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.name,
    required this.learnerType,
    required this.preferences,
    required this.progress,
    required this.words,
    required this.priority,
    required this.humaMessage,
    required this.child,
    required this.wide,
  });
  final String name;
  final LearnerType? learnerType;
  final OnboardingPreferences preferences;
  final AgainProgress progress;
  final List<VocabularyEntry> words;
  final HomeLearningPriority priority;
  final HumaMessage humaMessage;
  final bool child, wide;

  @override
  Widget build(BuildContext context) {
    final today = progress.activityFor(DateTime.now());
    final due = words.where((word) => word.isDue).length;
    return SingleChildScrollView(
      key: const Key('home-scroll'),
      padding: EdgeInsets.fromLTRB(
        wide ? 30 : 16,
        20,
        wide ? 30 : 16,
        wide ? 34 : 108,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Greeting(
                name: name,
                level: _level(preferences.level),
                xp: progress.totalXp,
              ),
              const SizedBox(height: 18),
              _HumaGuide(message: humaMessage, child: child),
              const SizedBox(height: 18),
              _JourneyHero(
                progress: progress,
                priority: priority,
                child: child,
              ),
              const SizedBox(height: 18),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _DailyGoal(
                            minutes: today.learningMinutes,
                            goal: preferences.dailyMinutes,
                          ),
                          const SizedBox(height: 16),
                          _SeedGrowth(growth: progress.seedGrowth),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _TasksPreview(progress: progress),
                          const SizedBox(height: 16),
                          _VocabularyReview(due: due),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _DailyGoal(
                  minutes: today.learningMinutes,
                  goal: preferences.dailyMinutes,
                ),
                const SizedBox(height: 14),
                _SeedGrowth(growth: progress.seedGrowth),
                const SizedBox(height: 14),
                _TasksPreview(progress: progress),
                const SizedBox(height: 14),
                _VocabularyReview(due: due),
              ],
              const SizedBox(height: 16),
              _Discovery(
                interests: preferences.interests,
                learnerType: learnerType,
                progress: progress,
              ),
              const SizedBox(height: 16),
              _Weekly(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.level, required this.xp});
  final String name, level;
  final int xp;
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Günaydın'
        : hour < 18
        ? 'İyi günler'
        : 'İyi akşamlar';
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name.',
            key: const Key('home-greeting'),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AgainColors.gold400,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$level • $xp XP',
            key: const Key('home-level-xp'),
            style: const TextStyle(
              color: AgainColors.turquoise100,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyHero extends StatelessWidget {
  const _JourneyHero({
    required this.progress,
    required this.priority,
    required this.child,
  });
  final AgainProgress progress;
  final HomeLearningPriority priority;
  final bool child;
  @override
  Widget build(BuildContext context) {
    final story = priority.story;
    final worldId =
        priority.worldId ?? progress.currentWorldId ?? 'yasam-vadisi';
    final visual = WorldVisualProfiles.forWorld(worldId);
    final worldStories = localStoryCatalog.byWorld(worldId);
    final value =
        progress.worldProgress(worldStories.map((item) => item.chapter.id)) /
        100;
    final title = story?.title ?? _worldName(worldId);
    final subtitle = story?.description ?? visual.description;
    final label = switch (priority.kind) {
      HomeLearningPriorityKind.activeStory => 'Devam Et',
      HomeLearningPriorityKind.nextStory => 'Hikâyeye Başla',
      HomeLearningPriorityKind.vocabulary => 'Kelimeleri Tekrar Et',
      HomeLearningPriorityKind.world => 'Dünyayı Aç',
      HomeLearningPriorityKind.complete => 'Haritayı Aç',
    };
    final cover = story?.coverVisual;
    return Semantics(
      container: true,
      label: '$title. Yüzde ${(value * 100).round()} tamamlandı.',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: child ? 310 : 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                cover?.assetPath ?? visual.detailHeroAsset!,
                fit: BoxFit.cover,
                alignment: cover == null
                    ? Alignment.center
                    : Alignment(cover.alignmentX, cover.alignmentY),
                cacheWidth: 960,
                excludeFromSemantics: true,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xF0041020)],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story == null
                          ? visual.eyebrow
                          : _worldName(worldId).toUpperCase(),
                      style: const TextStyle(
                        color: AgainColors.gold400,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: child ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AgainColors.mist),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      color: AgainColors.turquoise300,
                      backgroundColor: AgainColors.night700,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 210,
                      child: AgainPrimaryButton(
                        key: const Key('home-continue-story'),
                        label: label,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(priority.route),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HumaGuide extends StatelessWidget {
  const _HumaGuide({required this.message, required this.child});
  final HumaMessage message;
  final bool child;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Row(
      children: [
        HumaAvatar(size: child ? 78 : 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hüma',
                style: TextStyle(
                  color: AgainColors.gold400,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message.text,
                style: TextStyle(fontSize: child ? 17 : 15, height: 1.4),
              ),
              if (message.action case final action?) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => context.push(action.route),
                  child: Text(action.label),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal({required this.minutes, required this.goal});
  final int minutes;
  final int? goal;
  @override
  Widget build(BuildContext context) {
    final configuredGoal = goal;
    final value = configuredGoal == null || configuredGoal <= 0
        ? 0.0
        : (minutes / configuredGoal).clamp(0.0, 1.0);
    return Semantics(
      label: configuredGoal == null
          ? 'Bugün $minutes dakika öğrenildi. Günlük hedef ayarlanmadı.'
          : 'Bugünkü hedef. $minutes dakika tamamlandı, hedef $configuredGoal dakika.',
      child: AgainCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Title(Icons.route_rounded, 'Bugünkü Yolculuk'),
            const SizedBox(height: 16),
            Text(
              configuredGoal == null
                  ? '$minutes dakika • Hedef ayarlanmadı'
                  : '$minutes / $configuredGoal dakika',
              key: const Key('home-daily-goal'),
              style: const TextStyle(
                fontSize: 25,
                color: AgainColors.turquoise100,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: value,
              minHeight: 9,
              borderRadius: BorderRadius.circular(99),
              color: value >= 1
                  ? AgainColors.emerald200
                  : AgainColors.turquoise300,
              backgroundColor: AgainColors.night700,
            ),
            const SizedBox(height: 8),
            Text(
              configuredGoal == null
                  ? 'Günlük hedefini profilinden belirleyebilirsin.'
                  : value >= 1
                  ? 'Bugünkü hedefini tamamladın.'
                  : 'Her dakika dünyanda bir iz bırakır.',
              style: const TextStyle(color: AgainColors.mist),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeedGrowth extends StatelessWidget {
  const _SeedGrowth({required this.growth});

  final int growth;

  @override
  Widget build(BuildContext context) {
    final stage = _growth(growth);
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title(Icons.auto_awesome_rounded, 'Tohum Vadisi'),
          const SizedBox(height: 14),
          Row(
            children: [
              CustomPaint(
                size: const Size(82, 90),
                painter: _PlantPainter(stage.index),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.label,
                      key: const Key('home-seed-growth'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AgainColors.emerald200,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stage.next,
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
}

class _TasksPreview extends StatelessWidget {
  const _TasksPreview({required this.progress});
  final AgainProgress progress;
  @override
  Widget build(BuildContext context) {
    final today = progress.activityFor(DateTime.now());
    final tasks = [
      ('Hikâye bölümü tamamla', today.storyCount, 1),
      ('Kelime tekrarı yap', today.vocabularyReviews, 1),
      ('Konuşma pratiği', today.speakingMinutes, 2),
    ];
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title(Icons.task_alt_rounded, 'Bugünün Görevleri'),
          const SizedBox(height: 10),
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Icon(
                    task.$2 >= task.$3
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: task.$2 >= task.$3
                        ? AgainColors.emerald200
                        : AgainColors.slate,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task.$1)),
                  Text('${task.$2.clamp(0, task.$3)}/${task.$3}'),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('open-daily-tasks'),
              onPressed: () => context.push(AppRoutes.dailyTasksPath),
              child: const Text('Tüm Görevleri Gör'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyReview extends StatelessWidget {
  const _VocabularyReview({required this.due});
  final int due;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Title(Icons.local_florist_outlined, 'Kelime Bahçesi'),
        const SizedBox(height: 12),
        Text(
          due > 0
              ? 'Bugün $due kelime tekrar edilmeyi bekliyor.'
              : 'Bugünlük tüm kelimelerin taze.',
          style: const TextStyle(height: 1.4),
        ),
        const SizedBox(height: 12),
        AgainSecondaryButton(
          key: const Key('open-vocabulary-garden'),
          label: due > 0 ? 'Tekrar Et' : 'Bahçeyi Aç',
          onPressed: () => context.push(AppRoutes.vocabularyGardenPath),
        ),
      ],
    ),
  );
}

class _Discovery extends StatelessWidget {
  const _Discovery({
    required this.interests,
    required this.learnerType,
    required this.progress,
  });
  final Set<String> interests;
  final LearnerType? learnerType;
  final AgainProgress progress;
  @override
  Widget build(BuildContext context) {
    final text = interests.isNotEmpty
        ? '${interests.first} ilgine uygun yeni dünyalar Atlas’ta seni bekliyor.'
        : learnerType == LearnerType.adult
        ? 'Seyahat İngilizcesi için Deniz Krallığı rotasını güçlendir.'
        : 'Haritada yeni bir keşif rotası seç.';
    return AgainCard(
      child: Row(
        children: [
          const Icon(
            Icons.explore_rounded,
            color: AgainColors.gold400,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Senin için',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(text, style: const TextStyle(color: AgainColors.mist)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Haritayı aç',
            onPressed: () => context.push(AppRoutes.worldMapPath),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _Weekly extends StatelessWidget {
  const _Weekly({required this.progress});
  final AgainProgress progress;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i)),
    );
    final minutes = [
      for (final day in days) progress.activityFor(day).learningMinutes,
    ];
    final maxValue = minutes.fold<int>(1, (a, b) => b > a ? b : a);
    final total = minutes.fold<int>(0, (a, b) => a + b);
    return AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: _Title(Icons.insights_rounded, 'Bu Haftanın İzleri'),
              ),
              if (progress.currentStreak > 0)
                Text(
                  '${progress.currentStreak} günlük seri',
                  style: const TextStyle(color: AgainColors.gold400),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 8 + 60 * minutes[i] / maxValue,
                          decoration: BoxDecoration(
                            color: minutes[i] > 0
                                ? AgainColors.turquoise300
                                : AgainColors.night700,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${days[i].day}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'Bu hafta $total dakika öğrendin.',
            key: const Key('home-weekly-minutes'),
            style: const TextStyle(color: AgainColors.mist),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AgainColors.gold400),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _HomeNavigation extends StatelessWidget {
  const _HomeNavigation();
  @override
  Widget build(BuildContext context) =>
      const AgainPrimaryNavigation(selectedIndex: 0);
}

class _HomeRail extends StatelessWidget {
  const _HomeRail();
  @override
  Widget build(BuildContext context) => NavigationRail(
    selectedIndex: 0,
    labelType: NavigationRailLabelType.all,
    onDestinationSelected: (i) => _go(context, i),
    destinations: const [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        label: Text('Ana Sayfa'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.map_outlined),
        label: Text('Harita'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.forum_outlined),
        label: Text('Meydan'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        label: Text('Hüma'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        label: Text('Profil'),
      ),
    ],
  );
}

void _go(BuildContext context, int i) {
  final routes = [
    AppRoutes.homePath,
    AppRoutes.worldMapPath,
    AppRoutes.storySquarePath,
    AppRoutes.humaConversationPath,
    AppRoutes.profilePath,
  ];
  context.go(routes[i]);
}

({int index, String label, String next}) _growth(int value) {
  if (value <= 0) {
    return (
      index: 0,
      label: 'Tohumun dinleniyor.',
      next: 'İlk hikâyen onu filizlendirecek.',
    );
  }
  if (value == 1) {
    return (
      index: 1,
      label: 'İlk filizin göründü.',
      next: 'Bir sonraki öğrenme etkinliği filizi güçlendirir.',
    );
  }
  if (value < 4) {
    return (
      index: 2,
      label: 'Filizin güçleniyor.',
      next: '${4 - value} öğrenme etkinliği sonra genç bitki.',
    );
  }
  if (value < 7) {
    return (
      index: 3,
      label: 'Genç bitkin büyüyor.',
      next: '${7 - value} öğrenme etkinliği sonra küçük ağaç.',
    );
  }
  if (value < 11) {
    return (
      index: 4,
      label: 'Küçük ağacın kök saldı.',
      next: '${11 - value} öğrenme etkinliği sonra olgun ağaç.',
    );
  }
  return (
    index: 5,
    label: 'Ağacın ışıkla büyüyor.',
    next: 'Yeni etkinlikler dallarına iz bırakır.',
  );
}

String _level(EnglishLevel? level) => switch (level) {
  EnglishLevel.beginner => 'A1',
  EnglishLevel.words => 'A1',
  EnglishLevel.simpleSentences => 'A2',
  EnglishLevel.conversational => 'B1',
  EnglishLevel.placementTest || null => 'Seviye bekleniyor',
};

String _worldName(String id) => switch (id) {
  'yasam-vadisi' => 'Yaşam Vadisi',
  'sessiz-orman' => 'Sessiz Orman',
  'deniz-kralligi' => 'Deniz Krallığı',
  _ => 'Öğrenme Dünyası',
};

class _PlantPainter extends CustomPainter {
  const _PlantPainter(this.stage);
  final int stage;
  @override
  void paint(Canvas canvas, Size size) {
    final soil = Paint()..color = const Color(0xFF725536);
    canvas.drawOval(
      Rect.fromLTWH(8, size.height - 18, size.width - 16, 12),
      soil,
    );
    final stem = Paint()
      ..color = AgainColors.emerald500
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    if (stage == 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - 25),
          width: 18,
          height: 13,
        ),
        Paint()..color = AgainColors.gold400,
      );
      return;
    }
    final height = 25.0 + stage * 9;
    canvas.drawLine(
      Offset(size.width / 2, size.height - 20),
      Offset(size.width / 2, size.height - 20 - height),
      stem,
    );
    for (var i = 0; i < stage + 1; i++) {
      final y = size.height - 34 - i * 10;
      final side = i.isEven ? -1.0 : 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2 + side * 12, y),
          width: 25,
          height: 13,
        ),
        Paint()
          ..color = i < 2 ? AgainColors.emerald200 : AgainColors.emerald500,
      );
    }
    if (stage >= 4) {
      canvas.drawCircle(
        Offset(size.width / 2, 24),
        24 + stage * 2,
        Paint()..color = AgainColors.emerald600.withValues(alpha: .8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) =>
      oldDelegate.stage != stage;
}
