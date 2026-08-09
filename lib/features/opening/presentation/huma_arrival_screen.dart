import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import 'opening_atmosphere.dart';

class HumaArrivalScreen extends StatefulWidget {
  const HumaArrivalScreen({super.key});

  @override
  State<HumaArrivalScreen> createState() => _HumaArrivalScreenState();
}

class _HumaArrivalScreenState extends State<HumaArrivalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AgainDurations.hero,
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _floatController.stop();
    } else if (!_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    final wide = MediaQuery.sizeOf(context).width >= AgainBreakpoints.expanded;
    final art = _HumaEntranceArt(
      entrance: entrance,
      float: _floatController,
      reduceMotion: reduceMotion,
    );
    final copy = _ArrivalCopy(entrance: entrance, reduceMotion: reduceMotion);

    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AgainBreakpoints.maxContentWidth,
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      AgainSpacing.xxxl,
                ),
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: art),
                          const SizedBox(width: AgainSpacing.xxxl),
                          Expanded(child: copy),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          art,
                          const SizedBox(height: AgainSpacing.md),
                          copy,
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

class _HumaEntranceArt extends StatelessWidget {
  const _HumaEntranceArt({
    required this.entrance,
    required this.float,
    required this.reduceMotion,
  });

  final Animation<double> entrance;
  final Animation<double> float;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < AgainBreakpoints.compact;
    final height = compact ? 300.0 : 470.0;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([entrance, float]),
        builder: (context, child) {
          final entranceValue = reduceMotion ? 1.0 : entrance.value;
          final floatOffset = reduceMotion ? 0.0 : (float.value - .5) * 12;
          return Opacity(
            opacity: entranceValue,
            child: Transform.translate(
              offset: Offset(0, (1 - entranceValue) * 28 + floatOffset),
              child: child,
            ),
          );
        },
        child: Container(
          height: height,
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AgainColors.turquoise300.withValues(alpha: .24),
                AgainColors.gold400.withValues(alpha: .08),
                Colors.transparent,
              ],
            ),
          ),
          child: Semantics(
            image: true,
            label: 'Hüma, AGAIN öğrenme rehberi',
            child: Image.asset(
              'assets/images/huma.png',
              fit: BoxFit.contain,
              semanticLabel: 'Hüma, AGAIN öğrenme rehberi',
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrivalCopy extends StatelessWidget {
  const _ArrivalCopy({required this.entrance, required this.reduceMotion});
  final Animation<double> entrance;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: reduceMotion ? const AlwaysStoppedAnimation(1) : entrance,
    child: AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Merhaba, ben Hüma.',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AgainColors.gold400),
          ),
          const SizedBox(height: AgainSpacing.md),
          Text(
            'Birlikte kelimelerin ardındaki dünyaları keşfedeceğiz.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AgainSpacing.xs),
          Text(
            'Önce seni biraz tanıyalım.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AgainSpacing.lg),
          AgainPrimaryButton(
            key: const Key('huma-arrival-continue'),
            label: 'Devam Et',
            onPressed: () => context.goNamed(AppRoutes.learnerProfiles),
          ),
        ],
      ),
    ),
  );
}
