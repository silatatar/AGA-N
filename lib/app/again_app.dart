import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/again_theme.dart';
import 'theme/theme_mode_controller.dart';

class AgainApp extends ConsumerWidget {
  const AgainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'AGAIN',
    debugShowCheckedModeBanner: false,
    theme: AgainTheme.light,
    darkTheme: AgainTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('tr'),
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      ...GlobalMaterialLocalizations.delegates,
    ],
    localeResolutionCallback: (locale, supportedLocales) {
      if (locale == null) return const Locale('tr');
      return supportedLocales.firstWhere(
        (item) => item.languageCode == locale.languageCode,
        orElse: () => const Locale('tr'),
      );
    },
    routerConfig: ref.watch(appRouterProvider),
  );
}
