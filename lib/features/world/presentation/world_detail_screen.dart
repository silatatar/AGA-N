import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../huma/presentation/huma_components.dart';
import '../domain/world_chapter.dart';
import '../domain/world_region.dart';

const _seaHero = 'assets/images/worlds/deniz_kralligi/hero_background.webp';

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
    if (widget.region.slug != 'deniz-kralligi') {
      return _SimpleWorldDetail(region: widget.region);
    }
    final progressValue = ref.watch(progressionProvider).value;
    final progress = progressValue ?? const AgainProgress();
    final chapters = progressValue == null
        ? denizKralligiChapters
        : denizChaptersFrom(progressValue);
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
              _seaHero,
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
  const _SimpleWorldDetail({required this.region});
  final WorldRegion region;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: OpeningAtmosphere(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AgainCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Haritaya dön',
                        onPressed: context.pop,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Text(
                      region.title,
                      key: const Key('world-detail-title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    Text(region.subtitle, textAlign: TextAlign.center),
                    const SizedBox(height: AgainSpacing.md),
                    const Text('Bu dünyanın bölüm yolculuğu yakında açılacak.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
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
