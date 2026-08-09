import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../learner_profile/presentation/learner_profile_controller.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../domain/world_region.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _atmosphere;

  @override
  void initState() {
    super.initState();
    _atmosphere = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _atmosphere.stop();
    } else if (!_atmosphere.isAnimating) {
      _atmosphere.repeat();
    }
  }

  @override
  void dispose() {
    _atmosphere.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(learnerProfileProvider).value;
    final level = ref.watch(onboardingProvider).value?.level;
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AgainColors.night950)),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: _TopHud(
                    name: profile?.displayName ?? 'Gezgin',
                    level: _levelLabel(level),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AgainSpacing.sm,
                  ),
                  child: Text(
                    'Dünya Haritası',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AgainColors.gold400,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: SizedBox(
                      height: 1460,
                      child: RepaintBoundary(
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: CustomPaint(
                                painter: _WorldBackgroundPainter(),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _atmosphere,
                                  builder: (_, _) => CustomPaint(
                                    painter: _AtmospherePainter(
                                      progress: _atmosphere.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _MapNode(
                              region: worldRegions[0],
                              top: 108,
                              leftFactor: .18,
                            ),
                            _MapNode(
                              region: worldRegions[1],
                              top: 465,
                              leftFactor: .57,
                            ),
                            _MapNode(
                              region: worldRegions[2],
                              top: 820,
                              leftFactor: .24,
                            ),
                            const _LockedNode(
                              title: 'Ateş Dağları',
                              top: 1125,
                              leftFactor: .60,
                            ),
                            const _LockedNode(
                              title: 'Yıldız Gözlemevi',
                              top: 1320,
                              leftFactor: .25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: _BottomNav()),
        ],
      ),
    );
  }

  String _levelLabel(EnglishLevel? level) => switch (level) {
    EnglishLevel.beginner => 'Başlangıç',
    EnglishLevel.words => 'Temel',
    EnglishLevel.simpleSentences => 'Gelişen',
    EnglishLevel.conversational => 'Konuşan',
    EnglishLevel.placementTest => 'Belirlenecek',
    null => 'Yeni Gezgin',
  };
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.name, required this.level});
  final String name;
  final String level;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AgainSpacing.md),
    padding: const EdgeInsets.symmetric(
      horizontal: AgainSpacing.md,
      vertical: AgainSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AgainColors.night900.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(AgainRadii.card),
      border: Border.all(color: AgainColors.gold400.withValues(alpha: .55)),
      boxShadow: AgainShadows.darkCard,
    ),
    child: Row(
      children: [
        const HumaAvatar(size: 48),
        const SizedBox(width: AgainSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                level,
                style: const TextStyle(color: AgainColors.mist, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Bildirimler',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Henüz yeni bir bildirimin yok.')),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    ),
  );
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.region,
    required this.top,
    required this.leftFactor,
  });
  final WorldRegion region;
  final double top;
  final double leftFactor;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: math.max(
      12,
      (MediaQuery.sizeOf(context).width.clamp(0, 760) - 210) * leftFactor,
    ),
    child: Semantics(
      button: true,
      label:
          '${region.title}, ${_stateLabel(region.state)}, '
          'ilerleme yüzde ${(region.progress * 100).round()}',
      child: InkWell(
        key: Key('world-${region.slug}'),
        onTap: () => context.push('/world/${region.slug}'),
        borderRadius: BorderRadius.circular(AgainRadii.hero),
        child: Container(
          width: 210,
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(AgainSpacing.md),
          decoration: BoxDecoration(
            gradient: _gradient(region.slug),
            borderRadius: BorderRadius.circular(AgainRadii.hero),
            border: Border.all(
              color: region.state == WorldRegionState.current
                  ? AgainColors.turquoise300
                  : AgainColors.gold400,
              width: 2,
            ),
            boxShadow: region.state == WorldRegionState.current
                ? AgainShadows.magicalGlow
                : AgainShadows.darkCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_icon(region.slug), color: Colors.white),
                  const Spacer(),
                  Icon(
                    region.state == WorldRegionState.completed
                        ? Icons.check_circle
                        : Icons.arrow_forward_rounded,
                    color: AgainColors.gold200,
                  ),
                ],
              ),
              const SizedBox(height: AgainSpacing.sm),
              Text(
                region.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AgainSpacing.xs),
              LinearProgressIndicator(
                value: region.progress,
                minHeight: 5,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: Colors.black26,
                color: region.state == WorldRegionState.completed
                    ? AgainColors.emerald200
                    : AgainColors.turquoise300,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static String _stateLabel(WorldRegionState state) => switch (state) {
    WorldRegionState.completed => 'tamamlandı',
    WorldRegionState.current => 'şu anki dünya',
    WorldRegionState.available => 'erişilebilir',
    WorldRegionState.locked => 'kilitli',
  };
  static IconData _icon(String slug) => switch (slug) {
    'yasam-vadisi' => Icons.park_rounded,
    'sessiz-orman' => Icons.forest_rounded,
    _ => Icons.water_rounded,
  };
  static LinearGradient _gradient(String slug) => switch (slug) {
    'yasam-vadisi' => const LinearGradient(
      colors: [Color(0xFF176B4B), Color(0xFF0B403D)],
    ),
    'sessiz-orman' => const LinearGradient(
      colors: [Color(0xFF164E45), Color(0xFF092B3B)],
    ),
    _ => const LinearGradient(colors: [Color(0xFF126E96), Color(0xFF15375F)]),
  };
}

class _LockedNode extends StatelessWidget {
  const _LockedNode({
    required this.title,
    required this.top,
    required this.leftFactor,
  });
  final String title;
  final double top;
  final double leftFactor;
  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: math.max(
      18,
      (MediaQuery.sizeOf(context).width.clamp(0, 760) - 170) * leftFactor,
    ),
    child: Semantics(
      label: '$title, kilitli',
      child: Container(
        width: 170,
        height: 92,
        decoration: BoxDecoration(
          color: AgainColors.purple700.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(AgainRadii.card),
          border: Border.all(
            color: AgainColors.purple200.withValues(alpha: .45),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AgainColors.purple200,
            ),
            const SizedBox(height: AgainSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AgainColors.mist),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.all(AgainSpacing.sm),
      decoration: BoxDecoration(
        color: AgainColors.night900.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(AgainRadii.card),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .5)),
      ),
      child: NavigationBar(
        height: 72,
        backgroundColor: Colors.transparent,
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go(AppRoutes.homePath);
          } else if (index == 2) {
            context.go(AppRoutes.storySquarePath);
          } else if (index == 3) {
            context.go(AppRoutes.humaConversationPath);
          } else if (index == 4) {
            context.go(AppRoutes.profilePath);
          } else if (index != 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${const ['Ana Sayfa', 'Harita', 'Meydan', 'Hüma', 'Profil'][index]} yakında açılacak.',
                ),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Meydan',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Hüma',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    ),
  );
}

class _WorldBackgroundPainter extends CustomPainter {
  const _WorldBackgroundPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final ocean = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF06152E), Color(0xFF063E55), Color(0xFF041020)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, ocean);
    final route = Paint()
      ..color = AgainColors.gold400.withValues(alpha: .28)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * .38, 220)
      ..cubicTo(
        size.width * .8,
        330,
        size.width * .25,
        590,
        size.width * .43,
        720,
      )
      ..cubicTo(
        size.width * .65,
        900,
        size.width * .2,
        1060,
        size.width * .68,
        1240,
      );
    canvas.drawPath(path, route);
    final cloud = Paint()..color = Colors.white.withValues(alpha: .06);
    for (final y in [290.0, 690.0, 1030.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .5, y),
          width: size.width * .8,
          height: 86,
        ),
        cloud,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AgainColors.turquoise100.withValues(alpha: .35);
    for (var i = 0; i < 18; i++) {
      final x = (i * 83.0 + progress * 34) % size.width;
      final y = (i * 127.0 - progress * 80) % size.height;
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.4 : .8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
