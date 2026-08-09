import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import 'opening_atmosphere.dart';

class FlutterSplashScreen extends StatefulWidget {
  const FlutterSplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
  });
  final Duration duration;

  @override
  State<FlutterSplashScreen> createState() => _FlutterSplashScreenState();
}

class _FlutterSplashScreenState extends State<FlutterSplashScreen>
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

  void _continue() {
    if (mounted) context.goNamed(AppRoutes.humaArrival);
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
