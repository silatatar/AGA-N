import 'package:flutter/material.dart';

import 'again_tokens.dart';

abstract final class AgainTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AgainColors.night800 : AgainColors.snow;
    final onSurface = isDark ? AgainColors.snow : AgainColors.ink;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AgainColors.turquoise400,
      onPrimary: AgainColors.night950,
      primaryContainer: AgainColors.ocean700,
      onPrimaryContainer: AgainColors.turquoise100,
      secondary: AgainColors.gold400,
      onSecondary: AgainColors.night950,
      secondaryContainer: AgainColors.gold200,
      onSecondaryContainer: AgainColors.ink,
      tertiary: AgainColors.emerald500,
      onTertiary: AgainColors.night950,
      error: AgainColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outline: isDark ? AgainColors.slate : const Color(0xFF607484),
      outlineVariant: isDark
          ? const Color(0xFF29445B)
          : const Color(0xFFD2DEE6),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? AgainColors.snow : AgainColors.night800,
      onInverseSurface: isDark ? AgainColors.ink : AgainColors.snow,
      inversePrimary: AgainColors.ocean600,
    );

    final textTheme = AgainTypography.textTheme(onSurface);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AgainColors.night950
          : const Color(0xFFF1F6F8),
      fontFamily: AgainTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      focusColor: AgainColors.turquoise300.withValues(alpha: .28),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: .055) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(AgainColors.turquoise400, width: 1.6),
        errorBorder: _inputBorder(AgainColors.error),
        focusedErrorBorder: _inputBorder(AgainColors.error, width: 1.6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? AgainColors.night900 : Colors.white,
        indicatorColor: AgainColors.gold400.withValues(alpha: .18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.bodySmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AgainColors.gold400
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AgainColors.night900 : Colors.white,
        indicatorColor: AgainColors.gold400.withValues(alpha: .18),
        selectedIconTheme: const IconThemeData(color: AgainColors.gold400),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AgainColors.turquoise400,
        linearTrackColor: Color(0x33294A5E),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AgainRadii.input),
        borderSide: BorderSide(color: color, width: width),
      );
}
