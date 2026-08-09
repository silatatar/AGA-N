import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/state_views.dart';
import '../../learner_profile/domain/learner_profile.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../domain/profile_progress.dart';
import 'profile_progress_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(profileProgressProvider);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AgainColors.welcomeGradient),
        child: SafeArea(
          bottom: false,
          child: progress.when(
            loading: () => const LoadingView(message: 'Profil hazırlanıyor…'),
            error: (_, _) => ErrorView(
              title: 'Profil açılamadı',
              message: 'İlerleme bilgileri okunamadı.',
              onRetry: () => ref.invalidate(profileProgressProvider),
            ),
            data: (data) => _ProfileContent(data: data),
          ),
        ),
      ),
      bottomNavigationBar: const _ProfileBottomNav(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.data});
  final ProfileProgress data;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: const Key('open-atlas'),
                      onPressed: () => context.push(AppRoutes.atlasPath),
                      icon: const Icon(Icons.travel_explore_outlined),
                      label: const Text('Atlası Aç'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ProfileHeader(data: data),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'İstatistikler',
                    icon: Icons.insights_outlined,
                  ),
                  const SizedBox(height: 10),
                  _StatisticsGrid(items: data.statistics),
                  const SizedBox(height: 24),
                  _GrowthCard(growth: data.growth),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Koleksiyon',
                    icon: Icons.auto_awesome_mosaic_outlined,
                  ),
                  const SizedBox(height: 10),
                  _CollectionStrip(items: data.collections),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Rozetler',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 10),
                  _BadgeStrip(items: data.badges),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});
  final ProfileProgress data;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final avatar = _ProfileAvatar(
          profile: data.profile,
          size: compact ? 82 : 104,
        );
        final details = Column(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              data.profile?.displayName ?? 'AGAIN Gezgini',
              key: const Key('profile-display-name'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: compact ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 4),
            Text('${data.learnerType?.title ?? 'Gezgin'} • ${data.levelName}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Seviye ${data.numericLevel}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${data.totalXp} XP'),
              ],
            ),
            const SizedBox(height: 7),
            Semantics(
              label: 'Sonraki seviyeye XP ilerlemesi',
              value: '${data.xpInLevel} / ${data.xpForNextLevel}',
              child: LinearProgressIndicator(
                value: data.xpInLevel / data.xpForNextLevel,
                minHeight: 9,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            const SizedBox(height: 5),
            Text('${data.xpInLevel} / ${data.xpForNextLevel} sonraki seviyeye'),
          ],
        );
        if (compact) {
          return Column(
            children: [avatar, const SizedBox(height: 14), details],
          );
        }
        return Row(
          children: [
            avatar,
            const SizedBox(width: 24),
            Expanded(child: details),
          ],
        );
      },
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.size});
  final LearnerProfile? profile;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (profile?.avatar == LearnerAvatar.huma || profile == null) {
      return HumaAvatar(size: size);
    }
    final icon = switch (profile!.avatar) {
      LearnerAvatar.moon => Icons.nightlight_round,
      LearnerAvatar.compass => Icons.explore_outlined,
      LearnerAvatar.forest => Icons.forest_outlined,
      LearnerAvatar.huma => Icons.auto_awesome,
    };
    return Semantics(
      image: true,
      label: profile!.avatar.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AgainColors.night700,
          border: Border.all(color: AgainColors.gold400, width: 2),
          boxShadow: AgainShadows.magicalGlow,
        ),
        child: Icon(icon, size: size * .46, color: AgainColors.gold200),
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.items});
  final List<ProfileStatistic> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760
          ? 5
          : constraints.maxWidth >= 480
          ? 3
          : 2;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map(
              (item) => SizedBox(
                width: width,
                child: AgainCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.growth});
  final ProfileGrowth growth;
  @override
  Widget build(BuildContext context) => AgainCard(
    key: const Key('seed-growth-card'),
    child: Row(
      children: [
        _PlantVisual(growth: growth.points),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tohum Vadisi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                growth.stateName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AgainColors.emerald200,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: growth.progress,
                minHeight: 9,
                color: AgainColors.emerald500,
                borderRadius: BorderRadius.circular(9),
              ),
              const SizedBox(height: 7),
              Text(
                '${growth.points} / ${growth.nextMilestone} • sonraki büyüme eşiği',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlantVisual extends StatelessWidget {
  const _PlantVisual({required this.growth});
  final int growth;
  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 112,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AgainColors.night700, AgainColors.emerald600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(AgainRadii.card),
      border: Border.all(color: AgainColors.gold400.withValues(alpha: .45)),
    ),
    child: Icon(
      growth == 0
          ? Icons.grain
          : growth < 3
          ? Icons.eco_outlined
          : growth < 10
          ? Icons.park_outlined
          : Icons.park,
      size: 54,
      color: growth == 0 ? AgainColors.gold200 : AgainColors.emerald200,
    ),
  );
}

class _CollectionStrip extends StatelessWidget {
  const _CollectionStrip({required this.items});
  final List<ProfileCollectionItem> items;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 140,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return SizedBox(
          width: 142,
          child: AgainCard(
            padding: const EdgeInsets.all(12),
            child: Opacity(
              opacity: item.isUnlocked ? 1 : .48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _collectionIcon(index),
                    color: item.isUnlocked
                        ? AgainColors.gold400
                        : AgainColors.slate,
                    size: 30,
                  ),
                  const SizedBox(height: 7),
                  Text(item.title, textAlign: TextAlign.center, maxLines: 2),
                  Text(
                    '${item.count}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.items});
  final List<ProfileBadge> items;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: items
        .map(
          (badge) => Semantics(
            label: '${badge.title} rozeti',
            value: badge.isUnlocked ? 'Kazanıldı' : 'Kilitli',
            child: Chip(
              avatar: Icon(
                badge.isUnlocked ? Icons.workspace_premium : Icons.lock_outline,
                color: badge.isUnlocked
                    ? AgainColors.gold400
                    : AgainColors.slate,
              ),
              label: Text(badge.title),
            ),
          ),
        )
        .toList(),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AgainColors.gold400),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav();
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: 4,
    onDestinationSelected: (index) {
      if (index == 0) context.go(AppRoutes.homePath);
      if (index == 1) context.go(AppRoutes.worldMapPath);
      if (index == 2) context.go(AppRoutes.storySquarePath);
      if (index == 3) context.go(AppRoutes.humaConversationPath);
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Ana Sayfa',
      ),
      NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Harita'),
      NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Meydan'),
      NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        label: 'Hüma',
      ),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
    ],
  );
}

IconData _collectionIcon(int index) => const [
  Icons.auto_awesome,
  Icons.menu_book_outlined,
  Icons.gesture,
  Icons.diamond_outlined,
  Icons.account_balance_outlined,
][index];
