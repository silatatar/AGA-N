import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../startup/startup_decision.dart';
import 'opening_atmosphere.dart';

class FlutterSplashScreen extends ConsumerStatefulWidget {
  const FlutterSplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
  });
  final Duration duration;

  @override
  ConsumerState<FlutterSplashScreen> createState() =>
      _FlutterSplashScreenState();
}

class _FlutterSplashScreenState extends ConsumerState<FlutterSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AgainDurations.hero,
    )..forward();
    _timer = Timer(widget.duration, _continue);
  }

  Future<void> _continue() async {
    final destination = await ref
        .read(startupControllerProvider.notifier)
        .decide();
    if (!mounted) return;
    context.go(switch (destination) {
      StartupDestination.humaArrival => AppRoutes.humaArrivalPath,
      StartupDestination.learnerProfiles => AppRoutes.learnerProfilesPath,
      StartupDestination.profileName => AppRoutes.profileNamePath,
      StartupDestination.onboarding => AppRoutes.learningGoalPath,
      StartupDestination.accountDecision => AppRoutes.accountDecisionPath,
      StartupDestination.emailVerification => AppRoutes.emailVerificationPath,
      StartupDestination.home => AppRoutes.homePath,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: reduceMotion
                  ? const AlwaysStoppedAnimation(1)
                  : animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AgainEmblem(size: 128),
                  const SizedBox(height: AgainSpacing.lg),
                  Text(
                    'AGAIN',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AgainColors.gold400,
                      letterSpacing: 9,
                    ),
                  ),
                  const SizedBox(height: AgainSpacing.sm),
                  Text(
                    'Her hikâye bir kelimeyle başlar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AgainColors.turquoise100.withValues(alpha: .82),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
