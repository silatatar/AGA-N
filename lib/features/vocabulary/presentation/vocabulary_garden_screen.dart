import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/state_views.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../huma/presentation/huma_components.dart';
import '../domain/vocabulary_entry.dart';
import 'vocabulary_controller.dart';

enum GardenMode { garden, collection }

enum VocabularyFilter { all, newWords, due, growing, mastered }

enum VocabularySort { newest, due, mastery, alphabetical }

class VocabularyGardenScreen extends ConsumerStatefulWidget {
  const VocabularyGardenScreen({super.key});

  @override
  ConsumerState<VocabularyGardenScreen> createState() =>
      _VocabularyGardenScreenState();
}

class _VocabularyGardenScreenState
    extends ConsumerState<VocabularyGardenScreen> {
  final _search = TextEditingController();
  GardenMode _mode = GardenMode.garden;
  VocabularyFilter _filter = VocabularyFilter.all;
  VocabularySort _sort = VocabularySort.newest;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vocabularyProvider);
    final learnerType = ref.watch(learnerSelectionProvider).value;
    return Scaffold(
      backgroundColor: AgainColors.night950,
      appBar: AppBar(
        backgroundColor: AgainColors.night950,
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Kelime Bahçesi'),
      ),
      body: state.when(
        loading: () => const LoadingView(message: 'Bahçen uyanıyor…'),
        error: (_, _) => ErrorView(
          title: 'Bahçeye ulaşılamadı',
          message:
              'Kelimelerin silinmedi. Yerel kayıt yeniden okunmayı bekliyor.',
          onRetry: () => ref.invalidate(vocabularyProvider),
        ),
        data: (entries) => _content(context, entries, learnerType),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    List<VocabularyEntry> entries,
    LearnerType? learnerType,
  ) {
    if (entries.isEmpty) return const _EmptyGarden();
    final visible = _visible(entries);
    final due = entries.where((entry) => entry.isDue).length;
    final mastered = entries
        .where((entry) => entry.mastery == WordMastery.mastered)
        .length;
    final child = learnerType == LearnerType.child;
    final guidance = ref.watch(humaMessageProvider(HumaScreen.vocabulary));
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 960;
        final garden = _GardenScene(
          entries: _curated(entries, child ? 7 : 12),
          child: child,
        );
        final learning = _LearningPanel(
          entries: visible,
          due: due,
          mastered: mastered,
          child: child,
          search: _search,
          filter: _filter,
          sort: _sort,
          onSearch: (_) => setState(() {}),
          onFilter: (value) => setState(() => _filter = value),
          onSort: (value) => setState(() => _sort = value),
          embedded: !desktop && _mode == GardenMode.garden,
        );
        return Column(
          children: [
            _ModeSwitch(
              mode: _mode,
              onChanged: (value) => setState(() => _mode = value),
            ),
            Expanded(
              child: desktop
                  ? Row(
                      children: [
                        Expanded(flex: 6, child: garden),
                        Expanded(flex: 5, child: learning),
                      ],
                    )
                  : _mode == GardenMode.garden
                  ? CustomScrollView(
                      key: const Key('garden-scroll'),
                      slivers: [
                        SliverToBoxAdapter(child: garden),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: HumaGuideCard(message: guidance),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _StatusStrip(
                            total: entries.length,
                            due: due,
                            mastered: mastered,
                          ),
                        ),
                        SliverToBoxAdapter(child: learning),
                      ],
                    )
                  : learning,
            ),
          ],
        );
      },
    );
  }

  List<VocabularyEntry> _visible(List<VocabularyEntry> source) {
    final query = _search.text.trim().toLowerCase();
    final filtered = source.where((entry) {
      final matchesQuery =
          query.isEmpty ||
          entry.word.toLowerCase().contains(query) ||
          entry.turkishMeaning.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        VocabularyFilter.all => true,
        VocabularyFilter.newWords =>
          entry.growthState == VocabularyGrowthState.seed,
        VocabularyFilter.due => entry.isDue,
        VocabularyFilter.growing =>
          entry.growthState != VocabularyGrowthState.seed &&
              entry.growthState != VocabularyGrowthState.mastered,
        VocabularyFilter.mastered =>
          entry.growthState == VocabularyGrowthState.mastered,
      };
      return matchesQuery && matchesFilter;
    }).toList();
    filtered.sort(switch (_sort) {
      VocabularySort.newest => (a, b) => b.discoveredAt.compareTo(
        a.discoveredAt,
      ),
      VocabularySort.due => (a, b) => a.nextReviewAt.compareTo(b.nextReviewAt),
      VocabularySort.mastery => (a, b) => b.successfulReviewCount.compareTo(
        a.successfulReviewCount,
      ),
      VocabularySort.alphabetical => (a, b) => a.word.compareTo(b.word),
    });
    return filtered;
  }

  List<VocabularyEntry> _curated(List<VocabularyEntry> entries, int limit) {
    final sorted = [...entries]
      ..sort((a, b) {
        if (a.isDue != b.isDue) return a.isDue ? -1 : 1;
        return b.discoveredAt.compareTo(a.discoveredAt);
      });
    return sorted.take(limit).toList();
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});
  final GardenMode mode;
  final ValueChanged<GardenMode> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    child: SegmentedButton<GardenMode>(
      segments: const [
        ButtonSegment(
          value: GardenMode.garden,
          icon: Icon(Icons.park_outlined),
          label: Text('Bahçem'),
        ),
        ButtonSegment(
          value: GardenMode.collection,
          icon: Icon(Icons.menu_book_outlined),
          label: Text('Kelimeler'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    ),
  );
}

class _GardenScene extends StatelessWidget {
  const _GardenScene({required this.entries, required this.child});
  final List<VocabularyEntry> entries;
  final bool child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      key: const Key('vocabulary-garden-scene'),
      height: child ? 390 : 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .45)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07182E), Color(0xFF0B3440), Color(0xFF102E25)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x3300E5D5), blurRadius: 26)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _GardenPainter()),
            ),
            const Positioned(
              left: 20,
              top: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YAŞAYAN KELİME BAHÇEN',
                    style: TextStyle(
                      color: AgainColors.gold400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'Her gerçek tekrar, bir kökü güçlendirir.',
                    style: TextStyle(color: AgainColors.mist),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < entries.length; i++)
              _PlantPosition(
                entry: entries[i],
                index: i,
                total: entries.length,
                large: child,
              ),
          ],
        ),
      ),
    ),
  );
}

class _PlantPosition extends StatelessWidget {
  const _PlantPosition({
    required this.entry,
    required this.index,
    required this.total,
    required this.large,
  });
  final VocabularyEntry entry;
  final int index, total;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final columns = total <= 7 ? 4 : 6;
    final row = index ~/ columns;
    final column = index % columns;
    return Positioned(
      left: 12 + column * (large ? 74 : 62),
      bottom: 18 + row * 100 + (column.isOdd ? 13 : 0),
      child: Semantics(
        button: true,
        label:
            '${entry.word}. ${entry.turkishMeaning}. ${growthLabel(entry.growthState)}. ${entry.isDue ? 'Tekrarı bugün.' : 'Tekrarı planlandı.'}',
        child: InkWell(
          key: Key('garden-plant-${entry.id}'),
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/vocabulary/${entry.id}'),
          child: SizedBox(
            width: large ? 70 : 58,
            height: 86,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomPaint(
                  size: Size(large ? 58 : 48, large ? 58 : 48),
                  painter: VocabularyPlantPainter(
                    entry.growthState,
                    entry.plantVariant,
                  ),
                ),
                Text(
                  entry.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.total,
    required this.due,
    required this.mastered,
  });
  final int total, due, mastered;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(child: _Metric('$total', 'Kayıtlı')),
        Expanded(child: _Metric('$due', 'İlgi bekliyor')),
        Expanded(child: _Metric('$mastered', 'Çiçek açtı')),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: AgainColors.turquoise100,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AgainColors.mist, fontSize: 12),
        ),
      ],
    ),
  );
}

class _LearningPanel extends StatelessWidget {
  const _LearningPanel({
    required this.entries,
    required this.due,
    required this.mastered,
    required this.child,
    required this.search,
    required this.filter,
    required this.sort,
    required this.onSearch,
    required this.onFilter,
    required this.onSort,
    required this.embedded,
  });
  final List<VocabularyEntry> entries;
  final int due, mastered;
  final bool child;
  final TextEditingController search;
  final VocabularyFilter filter;
  final VocabularySort sort;
  final ValueChanged<String> onSearch;
  final ValueChanged<VocabularyFilter> onFilter;
  final ValueChanged<VocabularySort> onSort;
  final bool embedded;

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('vocabulary-collection-list'),
    shrinkWrap: embedded,
    physics: embedded ? const NeverScrollableScrollPhysics() : null,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Kelimelerin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (due > 0)
            AgainPrimaryButton(
              label: 'Tekrar Et ($due)',
              onPressed: () => context.push(
                '/vocabulary/${entries.firstWhere((e) => e.isDue, orElse: () => entries.first).id}/review/${ReviewMode.meaningRecall.name}',
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      AgainTextField(
        key: const Key('vocabulary-search'),
        label: 'Kelime ara',
        hint: 'İngilizce veya Türkçe',
        controller: search,
        onChanged: onSearch,
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final value in VocabularyFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  key: Key('vocabulary-filter-${value.name}'),
                  selected: filter == value,
                  onSelected: (_) => onFilter(value),
                  label: Text(filterLabel(value)),
                ),
              ),
            PopupMenuButton<VocabularySort>(
              tooltip: 'Sırala',
              initialValue: sort,
              onSelected: onSort,
              itemBuilder: (_) => [
                for (final value in VocabularySort.values)
                  PopupMenuItem(value: value, child: Text(sortLabel(value))),
              ],
              icon: const Icon(Icons.sort_rounded),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (entries.isEmpty)
        const EmptyView(
          title: 'Bu filtrede kelime yok',
          message: 'Başka bir filtre veya arama deneyebilirsin.',
          compact: true,
        )
      else
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WordTile(entry: entry, child: child),
          ),
    ],
  );
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.entry, required this.child});
  final VocabularyEntry entry;
  final bool child;

  @override
  Widget build(BuildContext context) => AgainCard(
    onTap: () => context.push('/vocabulary/${entry.id}'),
    child: Row(
      children: [
        CustomPaint(
          size: Size(child ? 58 : 48, child ? 58 : 48),
          painter: VocabularyPlantPainter(
            entry.growthState,
            entry.plantVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.word,
                key: Key('garden-word-${entry.id}'),
                style: TextStyle(
                  fontSize: child ? 21 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                entry.turkishMeaning,
                style: const TextStyle(color: AgainColors.mist),
              ),
              Text(
                '${growthLabel(entry.growthState)} • ${entry.worldTitle ?? entry.storyTitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AgainColors.slate, fontSize: 12),
              ),
            ],
          ),
        ),
        if (entry.isDue)
          const Icon(Icons.schedule_rounded, color: AgainColors.gold400),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}

class _EmptyGarden extends StatelessWidget {
  const _EmptyGarden();
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          children: [
            const SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(painter: _GardenPainter(empty: true)),
            ),
            const HumaAvatar(size: 86),
            const SizedBox(height: 12),
            Text(
              'Bahçen ilk kelimeyi bekliyor',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'İlk kelimeni bir hikâyede keşfettiğinde burada ilk tohumun filizlenecek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AgainColors.mist, height: 1.5),
            ),
            const SizedBox(height: 18),
            AgainPrimaryButton(
              label: 'Hikâye Keşfet',
              icon: Icons.auto_stories_outlined,
              onPressed: () => context.go(AppRoutes.worldMapPath),
            ),
          ],
        ),
      ),
    ),
  );
}

class VocabularyPlantPainter extends CustomPainter {
  const VocabularyPlantPainter(this.stage, this.variant);
  final VocabularyGrowthState stage;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final soil = Paint()..color = const Color(0xFF6B4A32);
    canvas.drawOval(
      Rect.fromLTWH(4, size.height - 10, size.width - 8, 8),
      soil,
    );
    if (stage == VocabularyGrowthState.seed) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center, size.height - 16),
          width: 14,
          height: 10,
        ),
        Paint()..color = AgainColors.gold400,
      );
      return;
    }
    final rank = stage.index;
    final stemTop = size.height - 16 - (15 + rank * 7);
    canvas.drawLine(
      Offset(center, size.height - 9),
      Offset(center, stemTop),
      Paint()
        ..color = AgainColors.emerald500
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < math.min(rank + 1, 3); i++) {
      final side = (i + variant).isEven ? -1.0 : 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center + side * 9, size.height - 19 - i * 8),
          width: 18 + variant.toDouble(),
          height: 9,
        ),
        Paint()..color = AgainColors.emerald200,
      );
    }
    if (rank >= VocabularyGrowthState.blooming.index) {
      final flower = Paint()
        ..color = variant.isEven
            ? AgainColors.turquoise300
            : AgainColors.gold400;
      for (var i = 0; i < 5; i++) {
        final angle = i * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(center + math.cos(angle) * 7, stemTop + math.sin(angle) * 7),
          5,
          flower,
        );
      }
      canvas.drawCircle(
        Offset(center, stemTop),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VocabularyPlantPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.variant != variant;
}

class _GardenPainter extends CustomPainter {
  const _GardenPainter({this.empty = false});
  final bool empty;
  @override
  void paint(Canvas canvas, Size size) {
    final ray = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x5500E5D5), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .7, size.height * .2),
              radius: size.width * .55,
            ),
          );
    canvas.drawRect(Offset.zero & size, ray);
    final hill = Path()
      ..moveTo(0, size.height * .68)
      ..quadraticBezierTo(
        size.width * .45,
        size.height * .48,
        size.width,
        size.height * .7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xCC123D30));
    final stars = Paint()
      ..color = AgainColors.turquoise100.withValues(alpha: .45);
    for (var i = 0; i < (empty ? 8 : 15); i++) {
      canvas.drawCircle(
        Offset((i * 73 % 100) / 100 * size.width, 38 + (i * 41 % 120)),
        i.isEven ? 1.7 : 1.0,
        stars,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) => false;
}

String growthLabel(VocabularyGrowthState state) => switch (state) {
  VocabularyGrowthState.seed => 'Tohum',
  VocabularyGrowthState.sprout => 'Filiz',
  VocabularyGrowthState.young => 'Büyüyen',
  VocabularyGrowthState.blooming => 'Çiçek açan',
  VocabularyGrowthState.mastered => 'Olgunlaşmış',
};

String filterLabel(VocabularyFilter value) => switch (value) {
  VocabularyFilter.all => 'Tümü',
  VocabularyFilter.newWords => 'Yeni',
  VocabularyFilter.due => 'Tekrar Bekleyen',
  VocabularyFilter.growing => 'Büyüyen',
  VocabularyFilter.mastered => 'Öğrenilen',
};

String sortLabel(VocabularySort value) => switch (value) {
  VocabularySort.newest => 'En yeni',
  VocabularySort.due => 'Tekrar zamanı',
  VocabularySort.mastery => 'Öğrenme durumu',
  VocabularySort.alphabetical => 'Alfabetik',
};
