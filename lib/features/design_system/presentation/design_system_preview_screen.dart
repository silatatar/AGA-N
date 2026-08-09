import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/responsive_shell.dart';
import '../../../core/widgets/state_views.dart';

class DesignSystemPreviewScreen extends ConsumerWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return ResponsiveShell(
      title: strings.appName,
      actions: [
        IconButton(
          tooltip: 'Tema önizlemesi',
          onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          icon: const Icon(Icons.brightness_6_outlined),
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AgainColors.welcomeGradient
              : const LinearGradient(
                  colors: [Color(0xFFF1F6F8), AgainColors.snow],
                ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal =
                  constraints.maxWidth >= AgainBreakpoints.compact;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal ? AgainSpacing.xl : AgainSpacing.lg,
                  vertical: AgainSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AgainBreakpoints.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PreviewHero(strings: strings),
                        const SizedBox(height: AgainSpacing.xl),
                        _ResponsiveSections(horizontal: horizontal),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PreviewHero extends StatelessWidget {
  const _PreviewHero({required this.strings});
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Wrap(
      spacing: AgainSpacing.lg,
      runSpacing: AgainSpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const HumaAvatar(size: 108),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AGAIN',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AgainColors.gold400,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: AgainSpacing.xs),
              Text(
                strings.previewTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AgainSpacing.xs),
              Text(strings.previewSubtitle),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResponsiveSections extends StatelessWidget {
  const _ResponsiveSections({required this.horizontal});
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final sections = [
      const _PaletteSection(),
      const _TypographySection(),
      _ControlsSection(strings: strings),
      _StatesSection(strings: strings),
    ];
    if (!horizontal) {
      return Column(
        children: sections
            .expand(
              (section) => [section, const SizedBox(height: AgainSpacing.lg)],
            )
            .toList(),
      );
    }
    return Wrap(
      spacing: AgainSpacing.lg,
      runSpacing: AgainSpacing.lg,
      children: sections
          .map((section) => SizedBox(width: 520, child: section))
          .toList(),
    );
  }
}

class _PaletteSection extends StatelessWidget {
  const _PaletteSection();

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renk Paleti', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AgainSpacing.md),
        const Wrap(
          spacing: AgainSpacing.sm,
          runSpacing: AgainSpacing.sm,
          children: [
            _ColorSwatch('Night', AgainColors.night900),
            _ColorSwatch('Ocean', AgainColors.ocean600),
            _ColorSwatch('Turkuaz', AgainColors.turquoise400),
            _ColorSwatch('Altın', AgainColors.gold400),
            _ColorSwatch('Zümrüt', AgainColors.emerald500),
            _ColorSwatch('Mor', AgainColors.purple500),
          ],
        ),
      ],
    ),
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label renk örneği',
    child: SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AgainRadii.control),
            ),
          ),
          const SizedBox(height: AgainSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipografi', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AgainSpacing.md),
        Text(
          'Her hikâye bir kelimeyle başlar.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AgainSpacing.sm),
        Text(
          'Hüma’nın rehberliğinde keşfet, konuş ve İngilizceyi yaşayarak öğren.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AgainSpacing.xs),
        Text(
          'A1 • Günlük konuşma • 8 dakika',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _ControlsSection extends StatelessWidget {
  const _ControlsSection({required this.strings});
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Kontroller', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AgainSpacing.md),
        AgainTextField(
          label: strings.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: AgainSpacing.sm),
        AgainTextField(
          label: strings.password,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
        ),
        const SizedBox(height: AgainSpacing.md),
        AgainPrimaryButton(label: strings.primaryAction, onPressed: () {}),
        const SizedBox(height: AgainSpacing.sm),
        AgainSecondaryButton(label: strings.secondaryAction, onPressed: () {}),
      ],
    ),
  );
}

class _StatesSection extends StatelessWidget {
  const _StatesSection({required this.strings});
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SuccessView(
        title: strings.successTitle,
        message: strings.successMessage,
        compact: true,
      ),
      const SizedBox(height: AgainSpacing.sm),
      ErrorView(
        title: strings.errorTitle,
        message: strings.errorMessage,
        actionLabel: strings.retry,
        onRetry: () {},
        compact: true,
      ),
      const SizedBox(height: AgainSpacing.sm),
      EmptyView(
        title: strings.emptyTitle,
        message: strings.emptyMessage,
        compact: true,
      ),
    ],
  );
}
