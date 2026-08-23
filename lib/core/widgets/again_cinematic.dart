import 'package:flutter/material.dart';

import '../../app/theme/again_tokens.dart';

class AgainCinematicBackground extends StatelessWidget {
  const AgainCinematicBackground({
    super.key,
    required this.child,
    this.primary = AgainColors.turquoise400,
    this.secondary = AgainColors.gold400,
  });

  final Widget child;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AgainColors.night950,
          Color.lerp(AgainColors.night900, primary, .12)!,
          AgainColors.night950,
        ],
        stops: const [0, .48, 1],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -110,
          right: -80,
          child: AgainAmbientGlow(color: primary, size: 300),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: AgainAmbientGlow(color: secondary, size: 260, opacity: .11),
        ),
        child,
      ],
    ),
  );
}

class AgainAmbientGlow extends StatelessWidget {
  const AgainAmbientGlow({
    super.key,
    required this.color,
    required this.size,
    this.opacity = .18,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}

class AgainGlassPanel extends StatelessWidget {
  const AgainGlassPanel({
    super.key,
    required this.child,
    this.accent = AgainColors.turquoise400,
    this.padding = const EdgeInsets.all(AgainSpacing.md),
    this.emphasized = false,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AgainColors.night800.withValues(alpha: emphasized ? .9 : .76),
      borderRadius: BorderRadius.circular(AgainRadii.card),
      border: Border.all(
        color: accent.withValues(alpha: emphasized ? .72 : .34),
        width: emphasized ? 1.4 : 1,
      ),
      boxShadow: emphasized ? AgainShadows.magicalGlow : AgainShadows.darkCard,
    ),
    child: child,
  );
}

class AgainStatusBadge extends StatelessWidget {
  const AgainStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(AgainRadii.control),
      border: Border.all(color: color.withValues(alpha: .45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
