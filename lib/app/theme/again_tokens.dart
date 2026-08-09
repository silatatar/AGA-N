import 'package:flutter/material.dart';

abstract final class AgainColors {
  static const night950 = Color(0xFF041020);
  static const night900 = Color(0xFF06152E);
  static const night800 = Color(0xFF09233D);
  static const night700 = Color(0xFF0B4162);

  static const ocean700 = Color(0xFF0C6477);
  static const ocean600 = Color(0xFF078B91);
  static const ocean500 = Color(0xFF16B8C7);

  static const turquoise400 = Color(0xFF45D6DF);
  static const turquoise300 = Color(0xFF70EAF0);
  static const turquoise100 = Color(0xFFBFF7FA);

  static const gold500 = Color(0xFFD8A73F);
  static const gold400 = Color(0xFFE7BF67);
  static const gold200 = Color(0xFFF6E2AB);

  static const emerald600 = Color(0xFF188768);
  static const emerald500 = Color(0xFF25A77B);
  static const emerald200 = Color(0xFFA9E6CF);

  static const purple700 = Color(0xFF49316E);
  static const purple500 = Color(0xFF7050A0);
  static const purple200 = Color(0xFFD5C2EF);

  static const snow = Color(0xFFF7FAFC);
  static const mist = Color(0xFFE7EEF3);
  static const slate = Color(0xFF8193A3);
  static const ink = Color(0xFF132231);

  static const error = Color(0xFFD94C5C);
  static const success = Color(0xFF2BAE75);
  static const warning = Color(0xFFE0A12E);

  static const welcomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [night900, night700, ocean600],
  );
}

abstract final class AgainSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
  static const huge = 64.0;
  static const hero = 80.0;
}

abstract final class AgainRadii {
  static const control = 12.0;
  static const input = 16.0;
  static const button = 18.0;
  static const card = 24.0;
  static const hero = 32.0;
}

abstract final class AgainDurations {
  static const micro = Duration(milliseconds: 180);
  static const page = Duration(milliseconds: 340);
  static const hero = Duration(milliseconds: 700);
}

abstract final class AgainShadows {
  static const darkCard = [
    BoxShadow(color: Color(0x59000000), blurRadius: 28, offset: Offset(0, 16)),
  ];

  static const lightCard = [
    BoxShadow(color: Color(0x16041325), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const magicalGlow = [
    BoxShadow(color: Color(0x3345D6DF), blurRadius: 32, spreadRadius: 2),
  ];
}

abstract final class AgainBreakpoints {
  static const compact = 600.0;
  static const expanded = 1024.0;
  static const maxContentWidth = 1240.0;
  static const maxReadingWidth = 720.0;
}

abstract final class AgainTypography {
  static const fontFamily = 'Segoe UI';

  static TextTheme textTheme(Color color) => TextTheme(
    displayLarge: _style(48, 56, FontWeight.w900, color),
    displayMedium: _style(40, 48, FontWeight.w800, color),
    headlineLarge: _style(32, 40, FontWeight.w800, color),
    headlineMedium: _style(26, 34, FontWeight.w700, color),
    titleLarge: _style(22, 30, FontWeight.w700, color),
    titleMedium: _style(18, 26, FontWeight.w700, color),
    bodyLarge: _style(17, 27, FontWeight.w500, color),
    bodyMedium: _style(15, 23, FontWeight.w400, color),
    labelLarge: _style(15, 20, FontWeight.w700, color),
    bodySmall: _style(12, 17, FontWeight.w500, color),
  );

  static TextStyle _style(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color,
  ) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
  );
}
