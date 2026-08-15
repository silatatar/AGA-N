import 'package:flutter/material.dart';

import '../../app/theme/again_tokens.dart';

class AgainPrimaryButton extends StatelessWidget {
  const AgainPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AgainColors.turquoise300,
        foregroundColor: AgainColors.night950,
        disabledBackgroundColor: AgainColors.slate.withValues(alpha: .35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AgainRadii.button),
        ),
      ),
      child: AnimatedSwitcher(
        duration: AgainDurations.micro,
        child: isLoading
            ? const SizedBox.square(
                key: ValueKey('loading'),
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : icon == null
            ? Text(
                label,
                key: const ValueKey('label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )
            : Row(
                key: const ValueKey('labelWithIcon'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: AgainSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

class AgainSecondaryButton extends StatelessWidget {
  const AgainSecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AgainRadii.button),
        ),
      ),
      child: Text(label),
    ),
  );
}

class AgainCard extends StatelessWidget {
  const AgainCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AgainSpacing.lg),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? AgainColors.night800.withValues(alpha: .86)
            : Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(AgainRadii.card),
        border: Border.all(
          color: isDark
              ? AgainColors.turquoise300.withValues(alpha: .14)
              : const Color(0xFFD8E4EA),
        ),
        boxShadow: isDark ? AgainShadows.darkCard : AgainShadows.lightCard,
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AgainRadii.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

class AgainTextField extends StatelessWidget {
  const AgainTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.enabled = true,
    this.maxLength,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    autofillHints: autofillHints,
    onChanged: onChanged,
    enabled: enabled,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
    ),
  );
}

class HumaAvatar extends StatelessWidget {
  const HumaAvatar({super.key, this.size = 72, this.decorative = false});

  final double size;
  final bool decorative;

  @override
  Widget build(BuildContext context) => Semantics(
    excludeSemantics: decorative,
    container: !decorative,
    image: true,
    label: decorative ? null : 'Hüma, AGAIN öğrenme rehberi',
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AgainColors.night800,
        border: Border.all(color: AgainColors.gold400, width: 1.5),
        boxShadow: AgainShadows.magicalGlow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/huma.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -.62),
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      ),
    ),
  );
}
