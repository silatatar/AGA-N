import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/learner_type.dart';
import 'learner_selection_controller.dart';

class LearnerProfileSelectionScreen extends ConsumerWidget {
  const LearnerProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(learnerSelectionProvider);
    final selected = selection.value;
    final wide = MediaQuery.sizeOf(context).width >= AgainBreakpoints.expanded;

    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? AgainSpacing.xxxl : AgainSpacing.lg,
              vertical: AgainSpacing.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  children: [
                    const HumaAvatar(size: 68),
                    const SizedBox(height: AgainSpacing.md),
                    Text(
                      'Kim öğreniyor?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AgainColors.gold400),
                    ),
                    const SizedBox(height: AgainSpacing.xs),
                    Text(
                      'AGAIN deneyimini sana uygun hâle getirelim.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AgainSpacing.xl),
                    selection.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(AgainSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Text(
                        'Profil tercihi yüklenemedi. Yeniden deneyebilirsin.',
                        style: const TextStyle(color: AgainColors.error),
                      ),
                      data: (_) => _ProfileGrid(
                        selected: selected,
                        onSelected: (type) => ref
                            .read(learnerSelectionProvider.notifier)
                            .select(type),
                      ),
                    ),
                    const SizedBox(height: AgainSpacing.xl),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SizedBox(
                        width: double.infinity,
                        child: AgainPrimaryButton(
                          key: const Key('learner-profile-continue'),
                          label: 'Devam Et',
                          onPressed: selected == null || selection.isLoading
                              ? null
                              : () => context.goNamed(AppRoutes.profileName),
                        ),
                      ),
                    ),
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

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.selected, required this.onSelected});
  final LearnerType? selected;
  final ValueChanged<LearnerType> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AgainBreakpoints.expanded) {
      return Column(
        children: LearnerType.values
            .map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: AgainSpacing.md),
                child: _LearnerProfileCard(
                  type: type,
                  selected: selected == type,
                  onTap: () => onSelected(type),
                ),
              ),
            )
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: LearnerType.values
          .map(
            (type) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AgainSpacing.xs,
                ),
                child: _LearnerProfileCard(
                  type: type,
                  selected: selected == type,
                  onTap: () => onSelected(type),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LearnerProfileCard extends StatefulWidget {
  const _LearnerProfileCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final LearnerType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LearnerProfileCard> createState() => _LearnerProfileCardState();
}

class _LearnerProfileCardState extends State<_LearnerProfileCard> {
  bool hovered = false;
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered || focused;
    final accent = switch (widget.type) {
      LearnerType.child => AgainColors.emerald500,
      LearnerType.teen => AgainColors.turquoise400,
      LearnerType.adult => AgainColors.gold400,
    };
    return Semantics(
      button: true,
      selected: widget.selected,
      label:
          '${widget.type.accessibilityDescription}. ${widget.type.description}',
      child: FocusableActionDetector(
        onShowHoverHighlight: (value) => setState(() => hovered = value),
        onShowFocusHighlight: (value) => setState(() => focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: AnimatedScale(
          scale: active ? 1.015 : 1,
          duration: AgainDurations.micro,
          child: AnimatedContainer(
            duration: AgainDurations.micro,
            constraints: const BoxConstraints(minHeight: 178),
            decoration: BoxDecoration(
              color: AgainColors.night800.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(AgainRadii.card),
              border: Border.all(
                color: widget.selected
                    ? accent
                    : active
                    ? accent.withValues(alpha: .58)
                    : AgainColors.slate.withValues(alpha: .22),
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: .2),
                        blurRadius: 28,
                      ),
                    ]
                  : AgainShadows.darkCard,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AgainRadii.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AgainSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _AvatarPlaceholder(type: widget.type, accent: accent),
                      const SizedBox(width: AgainSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.type.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AgainSpacing.xxs),
                            Text(
                              widget.type.ageRange,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AgainSpacing.xs),
                            Text(
                              widget.type.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (widget.selected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: accent,
                          semanticLabel: 'Seçildi',
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

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.type, required this.accent});
  final LearnerType type;
  final Color accent;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${type.title} profil illüstrasyonu için geçici avatar',
    child: Container(
      width: 82,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AgainRadii.input),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: .34),
            accent.withValues(alpha: .08),
          ],
        ),
      ),
      child: CustomPaint(painter: _AvatarPainter(accent)),
    ),
  );
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .8);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * .34),
      size.width * .19,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * .78),
          width: size.width * .58,
          height: size.height * .42,
        ),
        const Radius.circular(22),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) => oldDelegate.color != color;
}
