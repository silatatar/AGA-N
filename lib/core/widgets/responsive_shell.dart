import 'package:flutter/material.dart';

import '../../app/theme/again_tokens.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.child,
    this.title = 'AGAIN',
    this.actions = const [],
  });

  final Widget child;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final expanded =
        MediaQuery.sizeOf(context).width >= AgainBreakpoints.expanded;
    return Scaffold(
      appBar: expanded ? null : AppBar(title: Text(title), actions: actions),
      body: Row(
        children: [
          if (expanded) ...[
            SafeArea(
              child: SizedBox(
                width: 248,
                child: Padding(
                  padding: const EdgeInsets.all(AgainSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AgainColors.gold400,
                              letterSpacing: 4,
                            ),
                      ),
                      const SizedBox(height: AgainSpacing.sm),
                      Text(
                        'Learn. Adventure. Grow.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      ...actions,
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
