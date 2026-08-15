import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/atlas_models.dart';
import 'atlas_controller.dart';

class AtlasScreen extends ConsumerWidget {
  const AtlasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atlas = ref.watch(atlasProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atlas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dünyalar'),
              Tab(text: 'Karakterler'),
              Tab(text: 'Eşyalar'),
            ],
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AgainColors.welcomeGradient,
          ),
          child: atlas.when(
            loading: () => const LoadingView(message: 'Atlas açılıyor…'),
            error: (_, _) => ErrorView(
              title: 'Atlas açılamadı',
              message: 'Keşif geçmişi okunamadı.',
              onRetry: () => ref.invalidate(atlasProvider),
            ),
            data: (data) => TabBarView(
              children: [
                _WorldsTab(data: data),
                _CharactersTab(characters: data.characters),
                _ItemsTab(items: data.items),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldsTab extends StatelessWidget {
  const _WorldsTab({required this.data});
  final AtlasState data;
  @override
  Widget build(BuildContext context) {
    final entries = <AtlasWorld?>[
      ...data.worlds,
      ...List<AtlasWorld?>.filled(
        data.totalWorldCount - data.worlds.length,
        null,
      ),
    ];
    return CustomScrollView(
      key: const PageStorageKey('atlas-worlds'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: AgainCard(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final info = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keşif Arşivi',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text(
                            'Hikâyelerde karşılaştığın dünyaların izlerini burada biriktirirsin.',
                          ),
                        ],
                      );
                      final progress = Text(
                        'Keşfedilen: ${data.discoveredCount} / ${data.totalWorldCount}',
                        key: const Key('atlas-progress'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AgainColors.turquoise300),
                      );
                      if (constraints.maxWidth < 520) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.explore_outlined,
                              color: AgainColors.gold400,
                            ),
                            const SizedBox(height: 8),
                            info,
                            const SizedBox(height: 12),
                            progress,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          const Icon(
                            Icons.explore_outlined,
                            color: AgainColors.gold400,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: info),
                          const SizedBox(width: 16),
                          progress,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final columns = width >= 900
                  ? 4
                  : width >= 600
                  ? 3
                  : 2;
              return SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: width < 450 ? .78 : .9,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final world = entries[index];
                  return world == null
                      ? _LockedWorldCard(number: index + 1)
                      : _WorldCard(world: world);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({required this.world});
  final AtlasWorld world;
  @override
  Widget build(BuildContext context) => AgainCard(
    key: ValueKey('atlas-world-${world.slug}'),
    onTap: world.state == AtlasDiscoveryState.locked
        ? null
        : () => context.push('/atlas/world/${world.slug}'),
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _WorldArtwork(
            slug: world.slug,
            locked: world.state == AtlasDiscoveryState.locked,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(world.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    world.state == AtlasDiscoveryState.discovered
                        ? Icons.check_circle_outline
                        : world.state == AtlasDiscoveryState.locked
                        ? Icons.lock_outline
                        : Icons.timelapse,
                    color: world.state == AtlasDiscoveryState.discovered
                        ? AgainColors.emerald200
                        : AgainColors.gold400,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      world.state == AtlasDiscoveryState.discovered
                          ? 'Keşfedildi'
                          : world.state == AtlasDiscoveryState.locked
                          ? 'Henüz keşfedilmedi'
                          : 'Kısmen keşfedildi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              LinearProgressIndicator(
                value: world.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LockedWorldCard extends StatelessWidget {
  const _LockedWorldCard({required this.number});
  final int number;
  @override
  Widget build(BuildContext context) => AgainCard(
    key: ValueKey('atlas-world-locked-$number'),
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: _WorldArtwork(slug: 'locked', locked: true)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Icon(Icons.lock_outline, color: AgainColors.slate),
              const SizedBox(height: 4),
              Text('Bilinmeyen Dünya $number', textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CharactersTab extends StatelessWidget {
  const _CharactersTab({required this.characters});
  final List<AtlasCharacter> characters;
  @override
  Widget build(BuildContext context) => _AtlasGrid(
    children: characters
        .map(
          (character) => AgainCard(
            key: ValueKey('atlas-character-${character.name}'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                character.name == 'Hüma' && character.isMet
                    ? const HumaAvatar(size: 78)
                    : CircleAvatar(
                        radius: 39,
                        backgroundColor: character.isMet
                            ? AgainColors.ocean700
                            : AgainColors.night950,
                        child: Icon(
                          character.isMet
                              ? Icons.person_outline
                              : Icons.question_mark,
                          size: 38,
                          color: character.isMet
                              ? AgainColors.turquoise100
                              : AgainColors.slate,
                        ),
                      ),
                const SizedBox(height: 12),
                Text(
                  character.isMet ? character.name : 'Bilinmeyen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(character.relationship, textAlign: TextAlign.center),
                if (character.isMet &&
                    character.storyInformation.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    character.storyInformation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        )
        .toList(),
  );
}

class _ItemsTab extends StatelessWidget {
  const _ItemsTab({required this.items});
  final List<AtlasItem> items;
  @override
  Widget build(BuildContext context) => _AtlasGrid(
    children: items
        .map(
          (item) => AgainCard(
            key: ValueKey('atlas-item-${item.name}'),
            child: Opacity(
              opacity: item.isFound ? 1 : .45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.isFound ? Icons.diamond_outlined : Icons.lock_outline,
                    size: 52,
                    color: item.isFound
                        ? AgainColors.gold400
                        : AgainColors.slate,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.isFound ? item.name : 'Bilinmeyen Eşya',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.isFound
                        ? item.lore
                        : 'Hikâyelerde keşfedilmeyi bekliyor.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _AtlasGrid extends StatelessWidget {
  const _AtlasGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 800
          ? 3
          : constraints.maxWidth >= 520
          ? 2
          : 1;
      return GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 1.2 : 1,
        children: children,
      );
    },
  );
}

class _WorldArtwork extends StatelessWidget {
  const _WorldArtwork({required this.slug, required this.locked});
  final String slug;
  final bool locked;
  @override
  Widget build(BuildContext context) {
    final colors = switch (slug) {
      'yasam-vadisi' => const [AgainColors.emerald600, AgainColors.ocean700],
      'sessiz-orman' => const [Color(0xFF173D35), AgainColors.night900],
      'deniz-kralligi' => const [AgainColors.ocean600, AgainColors.night700],
      _ => const [AgainColors.purple700, AgainColors.night950],
    };
    final icon = switch (slug) {
      'yasam-vadisi' => Icons.landscape_outlined,
      'sessiz-orman' => Icons.forest_outlined,
      'deniz-kralligi' => Icons.castle_outlined,
      _ => Icons.question_mark,
    };
    return Semantics(
      image: true,
      label: locked ? 'Keşfedilmemiş dünya silueti' : 'Dünya illüstrasyonu',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 66,
            color: locked ? AgainColors.slate : AgainColors.gold200,
          ),
        ),
      ),
    );
  }
}

class AtlasWorldDetailScreen extends ConsumerWidget {
  const AtlasWorldDetailScreen({super.key, required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atlas = ref.watch(atlasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dünya Kaydı')),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AgainColors.welcomeGradient),
        child: atlas.when(
          loading: () => const LoadingView(),
          error: (_, _) => ErrorView(
            title: 'Kayıt açılamadı',
            message: 'Dünya bilgisi okunamadı.',
            onRetry: () => ref.invalidate(atlasProvider),
          ),
          data: (data) {
            final matches = data.worlds.where((world) => world.slug == slug);
            if (matches.isEmpty) {
              return const EmptyView(
                title: 'Dünya bulunamadı',
                message: 'Bu Atlas kaydı henüz mevcut değil.',
              );
            }
            final world = matches.first;
            if (world.state == AtlasDiscoveryState.locked) {
              return const EmptyView(
                title: 'Bu kayıt henüz kilitli',
                message:
                    'Bu dünyayı yolculuğunda keşfettiğinde Atlas kaydı açılacak.',
              );
            }
            return _WorldDetail(world: world);
          },
        ),
      ),
    );
  }
}

class _WorldDetail extends StatelessWidget {
  const _WorldDetail({required this.world});
  final AtlasWorld world;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AgainRadii.hero),
                child: _WorldArtwork(slug: world.slug, locked: false),
              ),
            ),
            const SizedBox(height: 18),
            Text(world.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(world.description),
            const SizedBox(height: 18),
            _LoreSection(
              title: 'Keşfedilen Hikâyeler',
              items: world.discoveredStories,
              emptyText: 'Henüz tamamlanan hikâye yok.',
            ),
            _LoreSection(
              title: 'Kelime Temaları',
              items: world.vocabularyThemes,
            ),
            _LoreSection(title: 'Kültürel Notlar', items: world.culturalNotes),
          ],
        ),
      ),
    ),
  );
}

class _LoreSection extends StatelessWidget {
  const _LoreSection({
    required this.title,
    required this.items,
    this.emptyText,
  });
  final String title;
  final List<String> items;
  final String? emptyText;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(emptyText ?? 'Henüz keşfedilmedi.')
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('• $item'),
              ),
            ),
        ],
      ),
    ),
  );
}
