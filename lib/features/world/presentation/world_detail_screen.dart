import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/world_chapter.dart';
import '../domain/world_region.dart';

class WorldDetailScreen extends StatefulWidget {
  const WorldDetailScreen({super.key, required this.region});
  final WorldRegion region;

  @override
  State<WorldDetailScreen> createState() => _WorldDetailScreenState();
}

class _WorldDetailScreenState extends State<WorldDetailScreen> {
  WorldChapter _selected = denizKralligiChapters.firstWhere(
    (chapter) => chapter.state == ChapterState.current,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.region.slug != 'deniz-kralligi') {
      return _SimpleWorldDetail(region: widget.region);
    }
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 390,
            pinned: true,
            backgroundColor: AgainColors.night900,
            leading: IconButton(
              tooltip: 'Haritaya dön',
              onPressed: context.pop,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CustomPaint(painter: _SeaKingdomPainter()),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AgainColors.night950.withValues(alpha: .18),
                            AgainColors.night950,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AgainSpacing.lg,
                      right: AgainSpacing.lg,
                      bottom: AgainSpacing.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '3. DÜNYA',
                            style: TextStyle(
                              color: AgainColors.turquoise100,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                            ),
                          ),
                          Text(
                            widget.region.title,
                            key: const Key('world-detail-title'),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  shadows: AgainShadows.darkCard,
                                ),
                          ),
                          const SizedBox(height: AgainSpacing.xs),
                          const Text(
                            'Dalgaların arasında kelimeleri keşfet; duygularını anlatmayı ve yolculuklarını planlamayı öğren.',
                            maxLines: 3,
                            style: TextStyle(color: AgainColors.mist),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AgainSpacing.lg,
                    AgainSpacing.lg,
                    AgainSpacing.lg,
                    AgainSpacing.hero,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WorldSummary(region: widget.region),
                      const SizedBox(height: AgainSpacing.xl),
                      Text(
                        'Bölümler',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AgainSpacing.xs),
                      const Text(
                        'Öğrenme yolunu görmek için bir bölüm seç.',
                        style: TextStyle(color: AgainColors.mist),
                      ),
                      const SizedBox(height: AgainSpacing.md),
                      for (final chapter in denizKralligiChapters) ...[
                        ChapterSelectionCard(
                          chapter: chapter,
                          selected: chapter.id == _selected.id,
                          onSelected: chapter.isSelectable
                              ? () => setState(() => _selected = chapter)
                              : null,
                        ),
                        const SizedBox(height: AgainSpacing.sm),
                      ],
                      const SizedBox(height: AgainSpacing.md),
                      AgainPrimaryButton(
                        key: const Key('chapter-continue'),
                        label: 'Devam Et',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(
                          '/world/${widget.region.slug}/chapter/${_selected.id}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldSummary extends StatelessWidget {
  const _WorldSummary({required this.region});
  final WorldRegion region;

  @override
  Widget build(BuildContext context) => AgainCard(
    padding: const EdgeInsets.all(AgainSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryValue(
                icon: Icons.trending_up_rounded,
                label: 'Tamamlanma',
                value: '%${(region.progress * 100).round()}',
              ),
            ),
            const Expanded(
              child: _SummaryValue(
                icon: Icons.schedule_rounded,
                label: 'Tahmini süre',
                value: '1 sa 35 dk',
              ),
            ),
          ],
        ),
        const SizedBox(height: AgainSpacing.md),
        const Text('Beceriler', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: AgainSpacing.sm),
        const Wrap(
          spacing: AgainSpacing.xs,
          runSpacing: AgainSpacing.xs,
          children: [
            Chip(
              avatar: Icon(Icons.hearing_rounded, size: 18),
              label: Text('Dinleme'),
            ),
            Chip(
              avatar: Icon(Icons.mic_none_rounded, size: 18),
              label: Text('Konuşma'),
            ),
            Chip(
              avatar: Icon(Icons.menu_book_rounded, size: 18),
              label: Text('Kelime'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AgainColors.turquoise300),
      const SizedBox(width: AgainSpacing.xs),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AgainColors.mist)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ],
  );
}

class ChapterSelectionCard extends StatelessWidget {
  const ChapterSelectionCard({
    super.key,
    required this.chapter,
    required this.selected,
    required this.onSelected,
  });
  final WorldChapter chapter;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final locked = chapter.state == ChapterState.locked;
    return Semantics(
      button: !locked,
      selected: selected,
      enabled: !locked,
      label:
          '${chapter.number}. bölüm, ${chapter.title}, ${_stateLabel(chapter.state)}, ${chapter.level}, ${chapter.durationMinutes} dakika, ${chapter.vocabularyCount} kelime',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('chapter-${chapter.id}'),
          onTap: onSelected,
          borderRadius: BorderRadius.circular(AgainRadii.card),
          child: AnimatedContainer(
            duration: AgainDurations.micro,
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.all(AgainSpacing.md),
            decoration: BoxDecoration(
              color: locked
                  ? AgainColors.night900.withValues(alpha: .45)
                  : selected
                  ? AgainColors.ocean700.withValues(alpha: .42)
                  : AgainColors.night800.withValues(alpha: .82),
              borderRadius: BorderRadius.circular(AgainRadii.card),
              border: Border.all(
                color: selected
                    ? AgainColors.turquoise300
                    : locked
                    ? AgainColors.purple500.withValues(alpha: .55)
                    : AgainColors.gold400.withValues(alpha: .35),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected ? AgainShadows.magicalGlow : null,
            ),
            child: Row(
              children: [
                _ChapterNumber(chapter: chapter),
                const SizedBox(width: AgainSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (chapter.isDownloaded)
                            const Tooltip(
                              message: 'Cihaza indirildi',
                              child: Icon(
                                Icons.download_done_rounded,
                                size: 20,
                                color: AgainColors.emerald200,
                              ),
                            ),
                          if (chapter.isPremium)
                            const Padding(
                              padding: EdgeInsets.only(left: AgainSpacing.xs),
                              child: Icon(
                                Icons.workspace_premium_outlined,
                                size: 20,
                                color: AgainColors.gold400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AgainSpacing.xs),
                      Wrap(
                        spacing: AgainSpacing.sm,
                        runSpacing: AgainSpacing.xs,
                        children: [
                          _Meta(
                            icon: Icons.signal_cellular_alt,
                            text: chapter.level,
                          ),
                          _Meta(
                            icon: Icons.schedule_rounded,
                            text: '${chapter.durationMinutes} dk',
                          ),
                          _Meta(
                            icon: Icons.translate_rounded,
                            text: '${chapter.vocabularyCount} kelime',
                          ),
                          if (chapter.hasListening)
                            const _Meta(
                              icon: Icons.hearing_rounded,
                              text: 'Dinleme',
                            ),
                          if (chapter.hasSpeaking)
                            const _Meta(
                              icon: Icons.mic_none_rounded,
                              text: 'Konuşma',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _stateLabel(ChapterState state) => switch (state) {
    ChapterState.completed => 'tamamlandı',
    ChapterState.current => 'şu anki bölüm',
    ChapterState.available => 'erişilebilir',
    ChapterState.locked => 'kilitli',
  };
}

class _ChapterNumber extends StatelessWidget {
  const _ChapterNumber({required this.chapter});
  final WorldChapter chapter;
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: chapter.state == ChapterState.completed
          ? AgainColors.emerald600
          : chapter.state == ChapterState.locked
          ? AgainColors.purple700
          : AgainColors.ocean700,
      border: Border.all(color: AgainColors.gold400),
    ),
    child: chapter.state == ChapterState.completed
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 21)
        : chapter.state == ChapterState.locked
        ? const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 21)
        : Text(
            '${chapter.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AgainColors.turquoise100),
      const SizedBox(width: AgainSpacing.xxs),
      Text(text, style: const TextStyle(fontSize: 12, color: AgainColors.mist)),
    ],
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
                    const Text(
                      'Bu dünyanın bölümleri sonraki içerik fazında açılacak.',
                      textAlign: TextAlign.center,
                    ),
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

class _SeaKingdomPainter extends CustomPainter {
  const _SeaKingdomPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF07162F), Color(0xFF08758C), Color(0xFF063B59)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final moon = Paint()
      ..color = AgainColors.turquoise100.withValues(alpha: .7);
    canvas.drawCircle(Offset(size.width * .78, 90), 32, moon);

    final palace = Paint()..color = const Color(0xFF123B68);
    final base = Rect.fromLTWH(
      size.width * .24,
      size.height * .34,
      size.width * .52,
      size.height * .34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(18)),
      palace,
    );
    for (final factor in [.3, .5, .7]) {
      final x = size.width * factor;
      final tower = Rect.fromLTWH(
        x - 22,
        size.height * .22,
        44,
        size.height * .32,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(14)),
        palace,
      );
      final roof = Path()
        ..moveTo(x - 30, size.height * .24)
        ..lineTo(x, size.height * .12 - math.sin(factor * 8) * 10)
        ..lineTo(x + 30, size.height * .24)
        ..close();
      canvas.drawPath(
        roof,
        Paint()..color = AgainColors.gold500.withValues(alpha: .85),
      );
    }
    final water = Paint()
      ..color = AgainColors.turquoise300.withValues(alpha: .12)
      ..strokeWidth = 2;
    for (var i = 0; i < 7; i++) {
      final y = size.height * .62 + i * 18;
      canvas.drawArc(
        Rect.fromLTWH(-30 + i * 12, y, size.width * .7, 20),
        0,
        math.pi,
        false,
        water,
      );
      canvas.drawArc(
        Rect.fromLTWH(size.width * .45, y + 8, size.width * .7, 20),
        0,
        math.pi,
        false,
        water,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
