import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AgainColors.welcomeGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AgainSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AgainCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HumaAvatar(size: 112),
                      const SizedBox(height: AgainSpacing.lg),
                      Text(
                        '404',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: AgainColors.gold400),
                      ),
                      const SizedBox(height: AgainSpacing.xs),
                      Text(
                        strings.notFoundTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AgainSpacing.sm),
                      Text(
                        strings.notFoundMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AgainSpacing.lg),
                      AgainPrimaryButton(
                        label: strings.returnToPreview,
                        onPressed: () => context.go('/design-system'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
