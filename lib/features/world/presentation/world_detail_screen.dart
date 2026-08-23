import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_cinematic.dart';
import '../../../core/widgets/again_components.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../story/data/story_repository.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../huma/presentation/huma_components.dart';
import '../domain/world_chapter.dart';
import '../domain/world_region.dart';
import '../domain/world_visual_profile.dart';

class WorldDetailScreen extends ConsumerStatefulWidget {
  const WorldDetailScreen({super.key, required this.region});
  final WorldRegion region;

  @override
  ConsumerState<WorldDetailScreen> createState() => _WorldDetailScreenState();
}

class _WorldDetailScreenState extends ConsumerState<WorldDetailScreen> {
  String _selectedId = 'hava-durumu';

  @override
  Widget build(BuildContext context) {
    final progressValue = ref.watch(progressionProvider).value;
    final progress = progressValue ?? const AgainProgress();
    final playableChapters = catalogChaptersForWorld(
      localStoryCatalog,
      widget.region.slug,
      progress,
    );
    if (widget.region.slug != 'deniz-kralligi') {
      return _SimpleWorldDetail(
        region: widget.region,
        chapters: playableChapters,
        onPlay: _play,
      );
    }
    final chapters = [
      ...playableChapters,
      ...denizChaptersFrom(
        progress,
      ).where((chapter) => !chapter.hasPlayableContent),
    ];
    final selected = chapters.firstWhere(
      (chapter) => chapter.id == _selectedId,
      orElse: () => chapters.first,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: LayoutBuilder(
        builder: (context, bounds) {
          final wide = bounds.maxWidth >= 900;
          return CustomScrollView(
            key: const Key('world-detail-scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: _SeaHero(
                  region: widget.region,
                  height: _heroHeight(bounds),
                  reduceMotion: reduceMotion,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 32 : 16,
                        18,
                        wide ? 32 : 16,
                        72,
                      ),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 350,
                                  child: Column(
                                    children: [
                                      _GuideMoment(),
                                      const SizedBox(height: 16),
                                      _WorldProgressPanel(
                                        progress: progress,
                                        chapters: chapters,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  child: _ChapterJourney(
                                    chapters: chapters,
                                    selected: selected,
                                    onSelected: _select,
                                    onPlay: _play,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _GuideMoment(),
                                const SizedBox(height: 16),
                                _WorldProgressPanel(
                                  progress: progress,
                                  chapters: chapters,
                                ),
                                const SizedBox(height: 26),
                                _ChapterJourney(
                                  chapters: chapters,
                                  selected: selected,
                                  onSelected: _select,
                                  onPlay: _play,
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
    );
  }

  double _heroHeight(BoxConstraints bounds) {
    if (bounds.maxWidth >= 900) return math.min(500, bounds.maxHeight * .62);
    return (bounds.maxHeight * .42).clamp(238, 390);
  }

  void _select(WorldChapter chapter) {
    if (chapter.isSelectable) setState(() => _selectedId = chapter.id);
  }

  void _play(WorldChapter chapter) {
    if (!chapter.isSelectable) return;
    context.push('/world/${widget.region.slug}/chapter/${chapter.id}');
  }
}

class _SeaHero extends StatelessWidget {
  const _SeaHero({
    required this.region,
    required this.height,
    required this.reduceMotion,
  });
  final WorldRegion region;
  final double height;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'world-art-deniz-kralligi',
          transitionOnUserGestures: true,
          child: RepaintBoundary(
            child: Image.asset(
              WorldVisualProfiles.seaKingdom.detailHeroAsset!,
              fit: BoxFit.cover,
              alignment: const Alignment(.22, .25),
              cacheWidth: 1440,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(painter: _BubblePainter(reduceMotion ? .35 : .55)),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22020B1A), Color(0x08020B1A), Color(0xE6081022)],
              stops: [0, .48, 1],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _RoundGlassButton(
                tooltip: 'Haritaya dön',
                icon: Icons.arrow_back_rounded,
                onPressed: context.pop,
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '3. DÜNYA • A1',
                  style: TextStyle(
                    color: AgainColors.turquoise100,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  region.title,
                  key: const Key('world-detail-title'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    shadows: AgainShadows.darkCard,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Yolculuk ve günlük yaşam',
                  style: TextStyle(
                    color: AgainColors.gold200,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dalgaların altında yeni kelimeler, yönler ve yolculuklar seni bekliyor.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AgainColors.mist, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuideMoment extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => HumaGuideCard(
    message: ref.watch(humaMessageProvider(HumaScreen.worldDetail)),
    compact: true,
  );
}

class _WorldProgressPanel extends StatelessWidget {
  const _WorldProgressPanel({required this.progress, required this.chapters});
  final AgainProgress progress;
  final List<WorldChapter> chapters;

  @override
  Widget build(BuildContext context) {
    final completed = chapters
        .where((chapter) => chapter.state == ChapterState.completed)
        .length;
    final playable = chapters.where((chapter) => chapter.hasPlayableContent);
    final percent = playable.isEmpty ? 0.0 : completed / playable.length;
    final current = chapters.firstWhere(
      (chapter) => chapter.state == ChapterState.current,
      orElse: () => chapters.firstWhere(
        (chapter) => chapter.id == 'hava-durumu',
        orElse: () => chapters.first,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(AgainColors.gold400.withValues(alpha: .38)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dünya ilerlemesi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '%${(percent * 100).round()}',
                style: const TextStyle(
                  color: AgainColors.turquoise100,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: percent,
              color: AgainColors.turquoise300,
              backgroundColor: AgainColors.night950,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _ProgressFact('$completed/${playable.length}', 'Bölüm'),
              _ProgressFact('${progress.totalXp}', 'Toplam XP'),
              _ProgressFact(current.title, 'Sıradaki durak'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressFact extends StatelessWidget {
  const _ProgressFact(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 82),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(
          label,
          style: const TextStyle(color: AgainColors.mist, fontSize: 12),
        ),
      ],
    ),
  );
}

class _ChapterJourney extends StatelessWidget {
  const _ChapterJourney({
    required this.chapters,
    required this.selected,
    required this.onSelected,
    required this.onPlay,
  });
  final List<WorldChapter> chapters;
  final WorldChapter selected;
  final ValueChanged<WorldChapter> onSelected;
  final ValueChanged<WorldChapter> onPlay;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Bölüm Yolculuğu',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 5),
      const Text(
        'Işıklı inci yolunu takip ederek krallığın hikâyesini keşfet.',
        style: TextStyle(color: AgainColors.mist),
      ),
      const SizedBox(height: 18),
      for (var i = 0; i < chapters.length; i++)
        _JourneyStop(
          chapter: chapters[i],
          selected: chapters[i].id == selected.id,
          isLast: i == chapters.length - 1,
          onSelected: () => onSelected(chapters[i]),
          onPlay: () => onPlay(chapters[i]),
        ),
    ],
  );
}

class _JourneyStop extends StatelessWidget {
  const _JourneyStop({
    required this.chapter,
    required this.selected,
    required this.isLast,
    required this.onSelected,
    required this.onPlay,
  });
  final WorldChapter chapter;
  final bool selected;
  final bool isLast;
  final VoidCallback onSelected;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final current = chapter.state == ChapterState.current;
    final completed = chapter.state == ChapterState.completed;
    final locked = chapter.state == ChapterState.locked;
    final soon = chapter.state == ChapterState.comingSoon;
    final status = _stateLabel(chapter.state);
    final semantics = soon
        ? '${chapter.title}. Bölüm ${chapter.number}. Yakında.'
        : locked
        ? '${chapter.title}. Bölüm ${chapter.number}. Kilitli.'
        : '${chapter.title}. Bölüm ${chapter.number}. $status. ${chapter.durationMinutes} dakika. Başlamak için dokunun.';
    return Semantics(
      button: chapter.isSelectable,
      enabled: chapter.isSelectable,
      selected: selected,
      label: semantics,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  _PearlNode(chapter: chapter),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: completed
                              ? AgainColors.emerald200
                              : AgainColors.turquoise300.withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: completed
                              ? AgainShadows.magicalGlow
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: Key('chapter-${chapter.id}'),
                    onTap: chapter.isSelectable ? onSelected : null,
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : AgainDurations.micro,
                      padding: EdgeInsets.all(current ? 18 : 15),
                      decoration: _glassDecoration(
                        current
                            ? AgainColors.turquoise300
                            : completed
                            ? AgainColors.emerald200.withValues(alpha: .65)
                            : AgainColors.gold400.withValues(alpha: .22),
                        emphasized: current,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              if (chapter.coverAsset != null) ...[
                                Container(
                                  width: 44,
                                  height: 44,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AgainColors.gold400.withValues(
                                        alpha: .72,
                                      ),
                                    ),
                                  ),
                                  child: Image.asset(
                                    chapter.coverAsset!,
                                    key: Key('chapter-cover-${chapter.id}'),
                                    excludeFromSemantics: true,
                                    fit: BoxFit.cover,
                                    alignment: Alignment(
                                      chapter.coverAlignmentX,
                                      chapter.coverAlignmentY,
                                    ),
                                    cacheWidth: 160,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text('${chapter.number}'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Text(
                                  '${chapter.number}. ${chapter.title}',
                                  style: TextStyle(
                                    fontSize: current ? 20 : 17,
                                    fontWeight: FontWeight.w900,
                                    color: soon || locked
                                        ? AgainColors.mist
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              _StatusPill(state: chapter.state),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (current)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Hava durumunu dinle, temel ifadeleri öğren ve hikâyenin yönünü seç.',
                                style: TextStyle(
                                  color: AgainColors.mist,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 11,
                            runSpacing: 7,
                            children: [
                              _Meta(
                                Icons.signal_cellular_alt_rounded,
                                chapter.level,
                              ),
                              _Meta(
                                Icons.schedule_rounded,
                                '${chapter.durationMinutes} dk',
                              ),
                              if (chapter.vocabularyCount > 0)
                                _Meta(
                                  Icons.translate_rounded,
                                  '${chapter.vocabularyCount} kelime',
                                ),
                              if (chapter.hasListening)
                                const _Meta(Icons.hearing_rounded, 'Dinleme'),
                              if (chapter.hasSpeaking)
                                const _Meta(Icons.mic_none_rounded, 'Konuşma'),
                              if (current)
                                const _Meta(
                                  Icons.alt_route_rounded,
                                  'Hikâye seçimi',
                                ),
                            ],
                          ),
                          if (chapter.isSelectable) ...[
                            const SizedBox(height: 16),
                            AgainPrimaryButton(
                              key: const Key('chapter-continue'),
                              label: completed ? 'Tekrar Oyna' : 'Devam Et',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: onPlay,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PearlNode extends StatelessWidget {
  const _PearlNode({required this.chapter});
  final WorldChapter chapter;
  @override
  Widget build(BuildContext context) {
    final completed = chapter.state == ChapterState.completed;
    final current = chapter.state == ChapterState.current;
    final locked = chapter.state == ChapterState.locked;
    final soon = chapter.state == ChapterState.comingSoon;
    return Container(
      width: current ? 50 : 42,
      height: current ? 50 : 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? AgainColors.emerald600
            : current
            ? AgainColors.ocean500
            : AgainColors.night800,
        border: Border.all(
          width: current ? 3 : 2,
          color: current
              ? AgainColors.turquoise100
              : completed
              ? AgainColors.gold200
              : AgainColors.gold400.withValues(alpha: .35),
        ),
        boxShadow: current ? AgainShadows.magicalGlow : null,
      ),
      child: completed
          ? const Icon(Icons.check_rounded, size: 22)
          : locked
          ? const Icon(Icons.lock_outline_rounded, size: 18)
          : soon
          ? const Icon(
              Icons.hourglass_top_rounded,
              size: 18,
              color: AgainColors.mist,
            )
          : Text(
              '${chapter.number}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.state});
  final ChapterState state;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: _stateColor(state).withValues(alpha: .16),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _stateColor(state).withValues(alpha: .62)),
    ),
    child: Text(
      _stateLabel(state),
      style: TextStyle(
        color: _stateColor(state),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AgainColors.turquoise100),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: AgainColors.mist)),
    ],
  );
}

class _RoundGlassButton extends StatelessWidget {
  const _RoundGlassButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgainColors.night950.withValues(alpha: .72),
      shape: BoxShape.circle,
      border: Border.all(color: AgainColors.gold400.withValues(alpha: .55)),
    ),
    child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon)),
  );
}

class _SimpleWorldDetail extends StatelessWidget {
  const _SimpleWorldDetail({
    required this.region,
    required this.chapters,
    required this.onPlay,
  });
  final WorldRegion region;
  final List<WorldChapter> chapters;
  final ValueChanged<WorldChapter> onPlay;
  @override
  Widget build(BuildContext context) {
    final visual = WorldVisualProfiles.forWorld(region.slug);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: AgainCinematicBackground(
        primary: visual.primary,
        secondary: visual.secondary,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _RoundGlassButton(
                        tooltip: 'Haritaya dön',
                        icon: Icons.arrow_back_rounded,
                        onPressed: context.pop,
                      ),
                    ),
                    const SizedBox(height: AgainSpacing.lg),
                    _WorldIdentityHero(region: region, visual: visual),
                    const SizedBox(height: AgainSpacing.lg),
                    Text(
                      'Bölüm yolculuğu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AgainColors.gold200,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    for (final chapter in chapters) ...[
                      _CompactWorldChapter(
                        chapter: chapter,
                        accent: visual.primary,
                        onPlay: onPlay,
                      ),
                      const SizedBox(height: AgainSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldIdentityHero extends StatelessWidget {
  const _WorldIdentityHero({required this.region, required this.visual});
  final WorldRegion region;
  final WorldVisualProfile visual;

  @override
  Widget build(BuildContext context) => AgainGlassPanel(
    accent: visual.primary,
    emphasized: true,
    padding: EdgeInsets.zero,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AgainRadii.card - 1),
      child: SizedBox(
        height: 292,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    visual.surfaceTint,
                    visual.primary.withValues(alpha: .42),
                    AgainColors.night950,
                  ],
                ),
              ),
            ),
            if (visual.detailHeroAsset != null)
              RepaintBoundary(
                child: Image.asset(
                  visual.detailHeroAsset!,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, .34),
                  cacheWidth: 1280,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    visual.surfaceTint.withValues(alpha: .2),
                    AgainColors.night950.withValues(alpha: .9),
                  ],
                  stops: const [.2, .56, 1],
                ),
              ),
            ),
            CustomPaint(painter: _WorldSilhouettePainter(visual.atmosphere)),
            Padding(
              padding: const EdgeInsets.all(AgainSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    visual.eyebrow,
                    style: TextStyle(
                      color: visual.secondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    region.title,
                    key: const Key('world-detail-title'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    visual.learningTheme,
                    style: TextStyle(
                      color: visual.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visual.description,
                    style: const TextStyle(color: AgainColors.mist),
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

class _CompactWorldChapter extends StatelessWidget {
  const _CompactWorldChapter({
    required this.chapter,
    required this.accent,
    required this.onPlay,
  });
  final WorldChapter chapter;
  final Color accent;
  final ValueChanged<WorldChapter> onPlay;

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(chapter.state);
    final icon = switch (chapter.state) {
      ChapterState.completed => Icons.check_rounded,
      ChapterState.locked => Icons.lock_outline_rounded,
      ChapterState.comingSoon => Icons.hourglass_empty_rounded,
      _ => Icons.play_arrow_rounded,
    };
    return Semantics(
      button: chapter.isSelectable,
      label: '${chapter.title}, ${_stateLabel(chapter.state)}',
      child: InkWell(
        key: Key('chapter-${chapter.id}'),
        borderRadius: BorderRadius.circular(AgainRadii.card),
        onTap: chapter.isSelectable ? () => onPlay(chapter) : null,
        child: AgainGlassPanel(
          accent: chapter.state == ChapterState.current ? accent : color,
          emphasized: chapter.state == ChapterState.current,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: .14),
                  border: Border.all(color: color.withValues(alpha: .65)),
                ),
                child: chapter.coverAsset != null
                    ? Image.asset(
                        chapter.coverAsset!,
                        key: Key('chapter-cover-${chapter.id}'),
                        excludeFromSemantics: true,
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          chapter.coverAlignmentX,
                          chapter.coverAlignmentY,
                        ),
                        cacheWidth: 160,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            '${chapter.number}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child:
                            chapter.state == ChapterState.current ||
                                chapter.state == ChapterState.available
                            ? Text(
                                '${chapter.number}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : Icon(icon, color: color, size: 20),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${chapter.level} • ${chapter.durationMinutes} dk • ${chapter.vocabularyCount} kelime',
                      style: const TextStyle(
                        color: AgainColors.slate,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AgainStatusBadge(
                label: _stateLabel(chapter.state),
                icon: icon,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldSilhouettePainter extends CustomPainter {
  const _WorldSilhouettePainter(this.atmosphere);
  final WorldAtmosphere atmosphere;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()..style = PaintingStyle.fill;
    switch (atmosphere) {
      case WorldAtmosphere.sunlitValley:
        glow.color = AgainColors.gold400.withValues(alpha: .18);
        canvas.drawCircle(
          Offset(size.width * .76, size.height * .22),
          70,
          glow,
        );
        glow.color = AgainColors.emerald600.withValues(alpha: .48);
        canvas.drawOval(
          Rect.fromLTWH(-30, size.height * .45, size.width * .75, size.height),
          glow,
        );
      case WorldAtmosphere.moonlitForest:
        glow.color = AgainColors.turquoise300.withValues(alpha: .12);
        canvas.drawCircle(Offset(size.width * .72, size.height * .2), 54, glow);
        glow.color = const Color(0xCC061B20);
        for (var i = 0; i < 7; i++) {
          final x = size.width * (i / 6);
          canvas.drawRect(
            Rect.fromLTWH(x, size.height * .18, 18 + i % 3 * 8, size.height),
            glow,
          );
        }
      case WorldAtmosphere.underwater:
        glow.color = AgainColors.turquoise300.withValues(alpha: .12);
        for (var i = 0; i < 5; i++) {
          final path = Path()
            ..moveTo(size.width * (.12 + i * .18), 0)
            ..lineTo(size.width * (.24 + i * .18), size.height)
            ..lineTo(size.width * (.34 + i * .18), size.height)
            ..lineTo(size.width * (.2 + i * .18), 0)
            ..close();
          canvas.drawPath(path, glow);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldSilhouettePainter oldDelegate) =>
      oldDelegate.atmosphere != atmosphere;
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.phase);
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AgainColors.turquoise100.withValues(alpha: .28);
    for (var i = 0; i < 14; i++) {
      final x = size.width * ((i * .173 + .07) % 1);
      final y = size.height * ((i * .113 + phase * .08) % 1);
      canvas.drawCircle(Offset(x, size.height - y), 1.8 + i % 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

BoxDecoration _glassDecoration(Color border, {bool emphasized = false}) =>
    BoxDecoration(
      color: AgainColors.night800.withValues(alpha: emphasized ? .9 : .76),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: border, width: emphasized ? 1.8 : 1),
      boxShadow: emphasized ? AgainShadows.magicalGlow : AgainShadows.darkCard,
    );

String _stateLabel(ChapterState state) => switch (state) {
  ChapterState.completed => 'Tamamlandı',
  ChapterState.current => 'Mevcut bölüm',
  ChapterState.available => 'Açık',
  ChapterState.locked => 'Kilitli',
  ChapterState.comingSoon => 'Yakında',
};

Color _stateColor(ChapterState state) => switch (state) {
  ChapterState.completed => AgainColors.emerald200,
  ChapterState.current => AgainColors.turquoise100,
  ChapterState.available => AgainColors.gold200,
  ChapterState.locked => AgainColors.purple200,
  ChapterState.comingSoon => AgainColors.mist,
};
