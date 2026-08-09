import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../story/data/story_services.dart';
import '../domain/daily_task.dart';

final dailyTaskProgressProvider =
    FutureProvider.autoDispose<StoryProgressSnapshot>(
      (ref) => ref.read(storyProgressRepositoryProvider).readSnapshot(),
    );

class DailyTasksScreen extends ConsumerWidget {
  const DailyTasksScreen({super.key});

  IconData _icon(String name) => switch (name) {
    'words' => Icons.translate_rounded,
    'story' => Icons.auto_stories_rounded,
    'speaking' => Icons.mic_none_rounded,
    'review' => Icons.replay_rounded,
    _ => Icons.hearing_rounded,
  };

  Future<void> _claim(
    BuildContext context,
    WidgetRef ref,
    DailyTask task,
  ) async {
    await ref
        .read(storyProgressRepositoryProvider)
        .claimDailyReward(
          taskId: task.id,
          xp: task.reward.xp,
          seedGrowth: task.reward.seedGrowth,
        );
    ref.invalidate(dailyTaskProgressProvider);
    if (!context.mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ödül penceresini kapat',
      barrierColor: Colors.black54,
      transitionDuration: AgainDurations.page,
      pageBuilder: (context, _, _) => _RewardMoment(task: task),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
    );
  }

  Future<void> _reviewWords(
    BuildContext context,
    WidgetRef ref,
    StoryProgressSnapshot snapshot,
  ) async {
    if (snapshot.savedWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce bir hikâyeden kelime kaydetmelisin.'),
        ),
      );
      return;
    }
    final word = snapshot.savedWords.first;
    final completed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AgainSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kısa kelime tekrarı',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AgainSpacing.lg),
              Text(
                word,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: AgainColors.gold400),
              ),
              const SizedBox(height: AgainSpacing.xs),
              const Text(
                'Bu kelimeyi hikâyedeki bağlamıyla hatırlıyor musun?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AgainSpacing.lg),
              AgainPrimaryButton(
                key: const Key('complete-vocabulary-review'),
                label: 'Hatırladım',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (completed != true) return;
    await ref.read(storyProgressRepositoryProvider).completeVocabularyReview();
    ref.invalidate(dailyTaskProgressProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyTaskProgressProvider);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: AgainSecondaryButton(
                label: 'Tekrar dene',
                onPressed: () => ref.invalidate(dailyTaskProgressProvider),
              ),
            ),
            data: (snapshot) {
              final tasks = dailyTasksFrom(snapshot);
              final completed = tasks.where((task) => task.isCompleted).length;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AgainColors.night900,
                    leading: IconButton(
                      tooltip: 'Ana sayfaya dön',
                      onPressed: context.pop,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    title: const Text('Günlük Görevler'),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: const EdgeInsets.all(AgainSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _DailySummary(
                                completed: completed,
                                total: tasks.length,
                                claimed: snapshot.claimedTaskRewards.length,
                              ),
                              const SizedBox(height: AgainSpacing.lg),
                              for (final task in tasks) ...[
                                _DailyTaskCard(
                                  task: task,
                                  icon: _icon(task.iconName),
                                  claimed: snapshot.claimedTaskRewards.contains(
                                    task.id,
                                  ),
                                  onClaim: () => _claim(context, ref, task),
                                  onAction: task.id == 'vocabulary-review'
                                      ? () =>
                                            _reviewWords(context, ref, snapshot)
                                      : null,
                                ),
                                const SizedBox(height: AgainSpacing.md),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({
    required this.completed,
    required this.total,
    required this.claimed,
  });
  final int completed;
  final int total;
  final int claimed;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$completed / $total görev tamamlandı',
          key: const Key('daily-task-summary'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AgainSpacing.sm),
        LinearProgressIndicator(
          value: completed / total,
          minHeight: 9,
          borderRadius: BorderRadius.circular(99),
          color: AgainColors.emerald200,
          backgroundColor: AgainColors.night700,
        ),
        const SizedBox(height: AgainSpacing.xs),
        Text(
          '$claimed ödül toplandı. Her ödül yalnızca bir kez alınabilir.',
          style: const TextStyle(color: AgainColors.mist),
        ),
      ],
    ),
  );
}

class _DailyTaskCard extends StatelessWidget {
  const _DailyTaskCard({
    required this.task,
    required this.icon,
    required this.claimed,
    required this.onClaim,
    required this.onAction,
  });
  final DailyTask task;
  final IconData icon;
  final bool claimed;
  final VoidCallback onClaim;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AgainColors.emerald600.withValues(alpha: .32)
                    : AgainColors.ocean700.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(AgainRadii.control),
              ),
              child: Icon(
                task.isCompleted ? Icons.check_rounded : icon,
                color: task.isCompleted
                    ? AgainColors.emerald200
                    : AgainColors.turquoise100,
              ),
            ),
            const SizedBox(width: AgainSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AgainSpacing.xxs),
                  Text(
                    task.description,
                    style: const TextStyle(color: AgainColors.mist),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AgainSpacing.md),
        LinearProgressIndicator(
          value: task.progress,
          minHeight: 7,
          borderRadius: BorderRadius.circular(99),
          backgroundColor: AgainColors.night700,
          color: task.isCompleted
              ? AgainColors.emerald200
              : AgainColors.turquoise300,
        ),
        const SizedBox(height: AgainSpacing.sm),
        Text(
          'Neden: ${task.educationalPurpose}',
          style: const TextStyle(fontSize: 13, color: AgainColors.slate),
        ),
        const SizedBox(height: AgainSpacing.md),
        _RewardPreview(reward: task.reward),
        if (task.isCompleted) ...[
          const SizedBox(height: AgainSpacing.md),
          AgainPrimaryButton(
            key: Key('claim-${task.id}'),
            label: claimed ? 'Ödül Alındı' : 'Ödülü Al',
            icon: claimed ? Icons.check_rounded : Icons.redeem_outlined,
            onPressed: claimed ? null : onClaim,
          ),
        ] else if (onAction != null) ...[
          const SizedBox(height: AgainSpacing.md),
          AgainSecondaryButton(label: 'Tekrarı Başlat', onPressed: onAction),
        ],
      ],
    ),
  );
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({required this.reward});
  final DailyReward reward;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AgainSpacing.sm,
    runSpacing: AgainSpacing.xs,
    children: [
      _RewardChip(icon: Icons.auto_awesome, text: '+${reward.xp} XP'),
      if (reward.seedGrowth > 0)
        _RewardChip(
          icon: Icons.eco_outlined,
          text: '+${reward.seedGrowth} tohum gelişimi',
        ),
      if (reward.storyUnlockProgress > 0)
        _RewardChip(
          icon: Icons.lock_open_rounded,
          text: '+${reward.storyUnlockProgress} hikâye kilidi ilerlemesi',
        ),
      if (reward.badgeProgress > 0)
        _RewardChip(
          icon: Icons.military_tech_outlined,
          text: '+${reward.badgeProgress}% rozet ilerlemesi',
        ),
    ],
  );
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 17, color: AgainColors.gold400),
    label: Text(text),
  );
}

class _RewardMoment extends StatelessWidget {
  const _RewardMoment({required this.task});
  final DailyTask task;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AgainSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            padding: const EdgeInsets.all(AgainSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AgainColors.night800, AgainColors.night900],
              ),
              borderRadius: BorderRadius.circular(AgainRadii.hero),
              border: Border.all(color: AgainColors.gold400),
              boxShadow: AgainShadows.magicalGlow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: AgainColors.emerald200,
                ),
                const SizedBox(height: AgainSpacing.md),
                Text(
                  'Görev ödülü alındı',
                  key: const Key('reward-moment-title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AgainColors.gold400,
                  ),
                ),
                const SizedBox(height: AgainSpacing.xs),
                Text(task.title, textAlign: TextAlign.center),
                const SizedBox(height: AgainSpacing.md),
                _RewardPreview(reward: task.reward),
                const SizedBox(height: AgainSpacing.lg),
                AgainPrimaryButton(
                  label: 'Tamam',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
