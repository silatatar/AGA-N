import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/again_tokens.dart';

class OpeningAtmosphere extends StatelessWidget {
  const OpeningAtmosphere({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AgainColors.night950,
          AgainColors.night900,
          AgainColors.night700,
        ],
        stops: [0, .52, 1],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: CustomPaint(painter: _NightPainter())),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(.55, -.18),
              radius: .72,
              colors: [
                AgainColors.turquoise400.withValues(alpha: .16),
                Colors.transparent,
              ],
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class AgainEmblem extends StatelessWidget {
  const AgainEmblem({super.key, this.size = 112});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'AGAIN amblemi',
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _EmblemPainter()),
    ),
  );
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 160;
    canvas.scale(scale);
    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AgainColors.gold400;
    final gem = Paint()..color = AgainColors.turquoise400;

    final outline = Path()
      ..moveTo(80, 18)
      ..lineTo(99, 48)
      ..lineTo(80, 73)
      ..lineTo(61, 48)
      ..close()
      ..moveTo(80, 73)
      ..lineTo(80, 118)
      ..moveTo(80, 91)
      ..cubicTo(59, 77, 38, 73, 22, 76)
      ..cubicTo(39, 94, 57, 104, 80, 107)
      ..moveTo(80, 91)
      ..cubicTo(101, 77, 122, 73, 138, 76)
      ..cubicTo(121, 94, 103, 104, 80, 107)
      ..moveTo(67, 122)
      ..lineTo(80, 142)
      ..lineTo(93, 122);
    canvas.drawPath(outline, gold);

    final gemPath = Path()
      ..moveTo(80, 29)
      ..lineTo(90, 48)
      ..lineTo(80, 62)
      ..lineTo(70, 48)
      ..close();
    canvas.drawPath(gemPath, gem);
  }

  @override
  bool shouldRepaint(_EmblemPainter oldDelegate) => false;
}

class _NightPainter extends CustomPainter {
  const _NightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = AgainColors.gold200.withValues(alpha: .45);
    for (var i = 0; i < 28; i++) {
      final x = ((i * 83) % 997) / 997 * size.width;
      final y = ((i * 47) % 431) / 431 * size.height * .7;
      final radius = i % 5 == 0 ? 1.4 : .7;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    final silhouette = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .84)
      ..quadraticBezierTo(
        size.width * .12,
        size.height * .73,
        size.width * .24,
        size.height * .83,
      )
      ..quadraticBezierTo(
        size.width * .39,
        size.height * .67,
        size.width * .53,
        size.height * .82,
      )
      ..quadraticBezierTo(
        size.width * .7,
        size.height * .7,
        size.width * .84,
        size.height * .84,
      )
      ..quadraticBezierTo(
        size.width * .92,
        size.height * .76,
        size.width,
        size.height * .81,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      silhouette,
      Paint()..color = AgainColors.night950.withValues(alpha: .78),
    );

    final moonPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AgainColors.turquoise100.withValues(alpha: .28),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .76, size.height * .2),
              radius: math.min(size.width, size.height) * .2,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .2),
      math.min(size.width, size.height) * .2,
      moonPaint,
    );
  }

  @override
  bool shouldRepaint(_NightPainter oldDelegate) => false;
}
