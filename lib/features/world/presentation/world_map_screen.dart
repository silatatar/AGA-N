import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/again_navigation.dart';
import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../../progression/domain/again_progress.dart';
import '../../progression/presentation/progression_controller.dart';
import '../domain/world_region.dart';

/// Phase 19 temporary atlas art. Replace the image layer without changing
/// normalized node coordinates or progression-connected widgets.
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});
  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(learnerProfileProvider).value;
    final level = ref.watch(onboardingProvider).value?.level;
    final progress =
        ref.watch(progressionProvider).value ?? const AgainProgress();
    final regions = worldRegionsFrom(progress);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: _TopHud(
                    name: profile?.displayName ?? 'Gezgin',
                    level: _levelLabel(level),
                    xp: progress.totalXp,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Dünya Haritası',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AgainColors.gold400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: WorldMapViewport(
                  regions: regions,
                  progress: progress,
                  motion: _motion,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 102)),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _MapNavigation(),
          ),
        ],
      ),
    );
  }

  String _levelLabel(EnglishLevel? value) => switch (value) {
    EnglishLevel.beginner => 'A1',
    EnglishLevel.words => 'A1+',
    EnglishLevel.simpleSentences => 'A2',
    EnglishLevel.conversational => 'B1',
    EnglishLevel.placementTest => 'Seviye bekleniyor',
    null => 'Yeni Gezgin',
  };
}

class WorldMapViewport extends StatelessWidget {
  const WorldMapViewport({
    super.key,
    required this.regions,
    required this.progress,
    required this.motion,
  });
  final List<WorldRegion> regions;
  final AgainProgress progress;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = MediaQuery.sizeOf(context);
          final width = constraints.maxWidth;
          final canvasHeight = math.max(viewport.height * 2.05, width * 2.85);
          return WorldMapCanvas(
            width: width,
            height: canvasHeight,
            regions: regions,
            progress: progress,
            motion: motion,
          );
        },
      ),
    ),
  );
}

class WorldMapCanvas extends StatelessWidget {
  const WorldMapCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.regions,
    required this.progress,
    required this.motion,
  });
  final double width, height;
  final List<WorldRegion> regions;
  final AgainProgress progress;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    final current = regions.firstWhere(
      (region) => region.state == WorldRegionState.current,
      orElse: () => regions.firstWhere(
        (region) => region.state == WorldRegionState.available,
        orElse: () => regions.first,
      ),
    );
    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/worlds/shared/world_map_atlas_placeholder.webp',
                fit: BoxFit.cover,
                cacheWidth: 1024,
                filterQuality: FilterQuality.medium,
              ),
            ),
            const Positioned.fill(child: CustomPaint(painter: _DepthPainter())),
            Positioned.fill(
              child: CustomPaint(
                painter: _JourneyPainter(
                  completedSegments: progress.completedChapterIds.length,
                ),
              ),
            ),
            _WorldNode(region: regions[0], x: .12, y: .15, number: 1),
            _WorldNode(region: regions[1], x: .48, y: .43, number: 2),
            _WorldNode(region: regions[2], x: .11, y: .71, number: 3),
            const _FutureWorldNode(title: 'Ateş Dağları', x: .54, y: .89),
            _HumaGuide(region: current, motion: motion),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: motion,
                  builder: (_, _) =>
                      CustomPaint(painter: _AtmospherePainter(motion.value)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
const phase19ResponsiveSizes = <Size>[
  Size(320, 568),
  Size(360, 800),
  Size(390, 844),
  Size(412, 915),
  Size(600, 960),
  Size(1024, 768),
  Size(1366, 768),
];

class _TopHud extends StatelessWidget {
  const _TopHud({required this.name, required this.level, required this.xp});
  final String name, level;
  final int xp;
  @override
  Widget build(BuildContext context) {
    final inLevel = xp % 200;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AgainColors.night900.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .48)),
        boxShadow: AgainShadows.darkCard,
      ),
      child: Row(
        children: [
          const _LearnerAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '$level • $xp XP',
                  style: const TextStyle(
                    color: AgainColors.turquoise100,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: inLevel / 200,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(99),
                  color: AgainColors.gold400,
                  backgroundColor: AgainColors.night700,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Henüz yeni bir bildirimin yok.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnerAvatar extends StatelessWidget {
  const _LearnerAvatar();
  @override
  Widget build(BuildContext context) => Container(
    width: 43,
    height: 43,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [AgainColors.turquoise300, AgainColors.gold400],
      ),
      border: Border.all(color: AgainColors.gold200),
    ),
    child: const Icon(Icons.person_rounded, color: AgainColors.night950),
  );
}

class _WorldNode extends StatefulWidget {
  const _WorldNode({
    required this.region,
    required this.x,
    required this.y,
    required this.number,
  });
  final WorldRegion region;
  final double x, y;
  final int number;
  @override
  State<_WorldNode> createState() => _WorldNodeState();
}

class _WorldNodeState extends State<_WorldNode> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final locked = widget.region.state == WorldRegionState.locked;
    return Align(
      alignment: Alignment(widget.x * 2 - 1, widget.y * 2 - 1),
      child: Semantics(
        button: !locked,
        label:
            '${widget.region.title}, ${_label(widget.region.state)}, '
            'yüzde ${(widget.region.progress * 100).round()}',
        child: GestureDetector(
          onTap: locked
              ? () => _lockedMessage(context)
              : () => context.push('/world/${widget.region.slug}'),
          onTapDown: locked ? null : (_) => setState(() => pressed = true),
          onTapCancel: locked ? null : () => setState(() => pressed = false),
          onTapUp: locked
              ? null
              : (_) {
                  setState(() => pressed = false);
                },
          child: AnimatedScale(
            scale: pressed ? .96 : 1,
            duration: AgainDurations.micro,
            child: Container(
              key: Key('world-${widget.region.slug}'),
              width: math.min(MediaQuery.sizeOf(context).width * .58, 232),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgainColors.night900.withValues(
                  alpha: locked ? .78 : .9,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _accent(widget.region), width: 1.5),
                boxShadow: widget.region.state == WorldRegionState.current
                    ? AgainShadows.magicalGlow
                    : AgainShadows.darkCard,
              ),
              child: Row(
                children: [
                  _WorldSigil(region: widget.region, number: widget.number),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.region.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: widget.region.progress,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(99),
                                color: _accent(widget.region),
                                backgroundColor: AgainColors.night700,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '%${(widget.region.progress * 100).round()}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    locked
                        ? Icons.lock_rounded
                        : widget.region.state == WorldRegionState.completed
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: _accent(widget.region),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _lockedMessage(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bu bölgeyi açmak için önce mevcut yolculuğunu tamamlamalısın.',
          ),
        ),
      );
  static String _label(WorldRegionState state) => switch (state) {
    WorldRegionState.completed => 'tamamlandı',
    WorldRegionState.current => 'şu anki dünya',
    WorldRegionState.available => 'erişilebilir',
    WorldRegionState.locked => 'kilitli',
  };
  static Color _accent(WorldRegion region) => switch (region.state) {
    WorldRegionState.completed => AgainColors.emerald200,
    WorldRegionState.current => AgainColors.turquoise300,
    WorldRegionState.available => AgainColors.gold400,
    WorldRegionState.locked => AgainColors.purple200,
  };
}

class _WorldSigil extends StatelessWidget {
  const _WorldSigil({required this.region, required this.number});
  final WorldRegion region;
  final int number;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SigilPainter(region.slug, _WorldNodeState._accent(region)),
    child: SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    ),
  );
}

class _FutureWorldNode extends StatelessWidget {
  const _FutureWorldNode({
    required this.title,
    required this.x,
    required this.y,
  });
  final String title;
  final double x, y;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment(x * 2 - 1, y * 2 - 1),
    child: Container(
      width: 154,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AgainColors.night950.withValues(alpha: .84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AgainColors.purple200.withValues(alpha: .6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AgainColors.purple200),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AgainColors.mist,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HumaGuide extends ConsumerWidget {
  const _HumaGuide({required this.region, required this.motion});
  final WorldRegion region;
  final Animation<double> motion;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidance = ref.watch(humaMessageProvider(HumaScreen.map));
    final position = switch (region.slug) {
      'yasam-vadisi' => const Alignment(.68, -.6),
      'sessiz-orman' => const Alignment(-.66, -.05),
      _ => const Alignment(.66, .48),
    };
    return Align(
      alignment: position,
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -4 + motion.value * 8),
          child: child,
        ),
        child: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width * .48, 190),
          child: Column(
            children: [
              const HumaAvatar(size: 76),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AgainColors.night900.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AgainColors.gold400.withValues(alpha: .55),
                  ),
                ),
                child: Text(
                  guidance.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, height: 1.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapNavigation extends StatelessWidget {
  const _MapNavigation();
  @override
  Widget build(BuildContext context) =>
      const AgainPrimaryNavigation(selectedIndex: 1);
}

class _SigilPainter extends CustomPainter {
  const _SigilPainter(this.slug, this.color);
  final String slug;
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color.withValues(alpha: .18);
    c.drawCircle(s.center(Offset.zero), s.shortestSide / 2, p);
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (slug == 'yasam-vadisi') {
      path.moveTo(s.width * .5, s.height * .78);
      path.quadraticBezierTo(
        s.width * .18,
        s.height * .38,
        s.width * .5,
        s.height * .2,
      );
      path.quadraticBezierTo(
        s.width * .82,
        s.height * .38,
        s.width * .5,
        s.height * .78,
      );
    } else if (slug == 'sessiz-orman') {
      path.moveTo(s.width * .2, s.height * .7);
      path.quadraticBezierTo(
        s.width * .5,
        s.height * .12,
        s.width * .8,
        s.height * .7,
      );
      path.moveTo(s.width * .32, s.height * .55);
      path.lineTo(s.width * .68, s.height * .55);
    } else {
      path.moveTo(s.width * .12, s.height * .56);
      path.quadraticBezierTo(
        s.width * .3,
        s.height * .3,
        s.width * .5,
        s.height * .56,
      );
      path.quadraticBezierTo(
        s.width * .7,
        s.height * .82,
        s.width * .88,
        s.height * .56,
      );
    }
    c.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SigilPainter old) =>
      old.slug != slug || old.color != color;
}

class _JourneyPainter extends CustomPainter {
  const _JourneyPainter({required this.completedSegments});
  final int completedSegments;
  @override
  void paint(Canvas c, Size s) {
    final path = Path()
      ..moveTo(s.width * .35, s.height * .2)
      ..cubicTo(
        s.width * .76,
        s.height * .29,
        s.width * .28,
        s.height * .39,
        s.width * .62,
        s.height * .48,
      )
      ..cubicTo(
        s.width * .78,
        s.height * .59,
        s.width * .22,
        s.height * .65,
        s.width * .38,
        s.height * .76,
      )
      ..cubicTo(
        s.width * .55,
        s.height * .83,
        s.width * .7,
        s.height * .84,
        s.width * .7,
        s.height * .92,
      );
    c.drawPath(
      path,
      Paint()
        ..color = AgainColors.night950.withValues(alpha: .5)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke,
    );
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            completedSegments > 0 ? AgainColors.gold400 : AgainColors.slate,
            completedSegments > 1
                ? AgainColors.turquoise300
                : AgainColors.purple700,
          ],
        ).createShader(Offset.zero & s)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter old) =>
      old.completedSegments != completedSegments;
}

class _DepthPainter extends CustomPainter {
  const _DepthPainter();
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AgainColors.night950.withValues(alpha: .05),
            Colors.transparent,
            AgainColors.night950.withValues(alpha: .35),
          ],
        ).createShader(Offset.zero & s),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter(this.progress);
  final double progress;
  @override
  void paint(Canvas c, Size s) {
    final sparkle = Paint()
      ..color = AgainColors.turquoise100.withValues(alpha: .42);
    for (var i = 0; i < 14; i++) {
      final x = (i * 73.0 + progress * 28) % s.width;
      final y = (i * 149.0 - progress * 38) % s.height;
      c.drawCircle(Offset(x, y), i.isEven ? 1.2 : .7, sparkle);
    }
    final mist = Paint()..color = Colors.white.withValues(alpha: .045);
    for (final y in [.34, .64, .84]) {
      c.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * (.45 + progress * .06), s.height * y),
          width: s.width * .92,
          height: 70,
        ),
        mist,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.progress != progress;
}
