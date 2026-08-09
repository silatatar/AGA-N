import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/vocabulary_entry.dart';
import 'vocabulary_controller.dart';

enum _GardenSection { today, newWords, difficult, learned, favorites, stories }

class VocabularyGardenScreen extends ConsumerStatefulWidget {
  const VocabularyGardenScreen({super.key});
  @override
  ConsumerState<VocabularyGardenScreen> createState() =>
      _VocabularyGardenScreenState();
}

class _VocabularyGardenScreenState
    extends ConsumerState<VocabularyGardenScreen> {
  _GardenSection _section = _GardenSection.today;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vocabularyProvider);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  tooltip: 'Geri',
                  onPressed: context.pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: const Text('Kelime Bahçesi'),
              ),
              Expanded(
                child: state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: AgainSecondaryButton(
                      label: 'Tekrar dene',
                      onPressed: () => ref.invalidate(vocabularyProvider),
                    ),
                  ),
                  data: (entries) {
                    final visible = _filter(entries);
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 920),
                              child: Padding(
                                padding: const EdgeInsets.all(AgainSpacing.lg),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _GardenHero(),
                                    const SizedBox(height: AgainSpacing.lg),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _GardenSection.values
                                            .map(
                                              (section) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: AgainSpacing.xs,
                                                ),
                                                child: ChoiceChip(
                                                  key: Key(
                                                    'garden-${section.name}',
                                                  ),
                                                  selected: _section == section,
                                                  label: Text(
                                                    _sectionTitle(section),
                                                  ),
                                                  onSelected: (_) => setState(
                                                    () => _section = section,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(height: AgainSpacing.lg),
                                    Text(
                                      _sectionTitle(_section),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: AgainSpacing.sm),
                                    if (visible.isEmpty)
                                      const AgainCard(
                                        child: Text(
                                          'Bu bölümde henüz kelime yok. Hikâyede bir kelimeye dokunup kaydedebilirsin.',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else if (_section == _GardenSection.stories)
                                      _StoryGroups(entries: visible)
                                    else
                                      ...visible.map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AgainSpacing.sm,
                                          ),
                                          child: _WordCard(entry: entry),
                                        ),
                                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  List<VocabularyEntry> _filter(
    List<VocabularyEntry> entries,
  ) => switch (_section) {
    _GardenSection.today => entries.where((entry) => entry.isDue).toList(),
    _GardenSection.newWords =>
      entries.where((entry) => entry.mastery == WordMastery.newWord).toList(),
    _GardenSection.difficult =>
      entries.where((entry) => entry.isDifficult).toList(),
    _GardenSection.learned =>
      entries.where((entry) => entry.mastery == WordMastery.mastered).toList(),
    _GardenSection.favorites =>
      entries.where((entry) => entry.isFavorite).toList(),
    _GardenSection.stories => entries,
  };

  String _sectionTitle(_GardenSection section) => switch (section) {
    _GardenSection.today => 'Bugün Tekrar Et',
    _GardenSection.newWords => 'Yeni Kelimeler',
    _GardenSection.difficult => 'Zorlandıklarım',
    _GardenSection.learned => 'Öğrendiklerim',
    _GardenSection.favorites => 'Favoriler',
    _GardenSection.stories => 'Hikâyelere Göre',
  };
}

class _GardenHero extends StatelessWidget {
  const _GardenHero();
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Row(
      children: [
        const Icon(
          Icons.local_florist_rounded,
          size: 62,
          color: AgainColors.emerald200,
        ),
        const SizedBox(width: AgainSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelimelerin burada büyür',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AgainSpacing.xs),
              const Text(
                'Tekrar aralıkları yerel bir prototip modelidir; bilimsel olarak en iyi plan olduğu iddia edilmez.',
                style: TextStyle(color: AgainColors.mist),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.entry});
  final VocabularyEntry entry;
  @override
  Widget build(BuildContext context) => AgainCard(
    onTap: () => context.push('/vocabulary/${entry.id}'),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AgainColors.emerald600.withValues(alpha: .24),
            borderRadius: BorderRadius.circular(AgainRadii.control),
          ),
          child: const Icon(Icons.spa_outlined, color: AgainColors.emerald200),
        ),
        const SizedBox(width: AgainSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.word,
                key: Key('garden-word-${entry.id}'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${entry.turkishMeaning} · ${_mastery(entry.mastery)}',
                style: const TextStyle(color: AgainColors.mist),
              ),
              const SizedBox(height: AgainSpacing.xs),
              LinearProgressIndicator(
                value: entry.correctStreak.clamp(0, 4) / 4,
                minHeight: 5,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: AgainColors.night700,
                color: AgainColors.emerald200,
              ),
            ],
          ),
        ),
        if (entry.isFavorite)
          const Icon(Icons.favorite, color: AgainColors.gold400),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );

  String _mastery(WordMastery mastery) => switch (mastery) {
    WordMastery.newWord => 'Yeni',
    WordMastery.learning => 'Öğreniliyor',
    WordMastery.familiar => 'Tanıdık',
    WordMastery.mastered => 'Öğrenildi',
  };
}

class _StoryGroups extends StatelessWidget {
  const _StoryGroups({required this.entries});
  final List<VocabularyEntry> entries;
  @override
  Widget build(BuildContext context) {
    final groups = <String, List<VocabularyEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.storyTitle, () => []).add(entry);
    }
    return Column(
      children: groups.entries
          .map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: AgainSpacing.md),
              child: AgainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      group.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    Wrap(
                      spacing: AgainSpacing.xs,
                      children: group.value
                          .map((entry) => Chip(label: Text(entry.word)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
