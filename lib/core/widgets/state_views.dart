import 'package:flutter/material.dart';

import '../../app/theme/again_tokens.dart';
import 'again_components.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: message ?? 'Yükleniyor',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message case final value?) ...[
            const SizedBox(height: AgainSpacing.md),
            Text(value, textAlign: TextAlign.center),
          ],
        ],
      ),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.compact = false,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: Icons.error_outline_rounded,
    color: AgainColors.error,
    title: title,
    message: message,
    compact: compact,
    action: onRetry == null
        ? null
        : AgainSecondaryButton(
            label: actionLabel ?? 'Yeniden Dene',
            onPressed: onRetry,
          ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: Icons.explore_outlined,
    color: AgainColors.gold400,
    title: title,
    message: message,
    compact: compact,
  );
}

class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: Icons.check_circle_outline_rounded,
    color: AgainColors.success,
    title: title,
    message: message,
    compact: compact,
  );
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.compact,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final bool compact;
  final Widget? action;

  @override
  Widget build(BuildContext context) => AgainCard(
    padding: EdgeInsets.all(compact ? AgainSpacing.md : AgainSpacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: compact ? 28 : 36),
        const SizedBox(height: AgainSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AgainSpacing.xs),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        if (action case final value?) ...[
          const SizedBox(height: AgainSpacing.md),
          value,
        ],
      ],
    ),
  );
}
