import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../domain/huma_models.dart';

class HumaHero extends StatelessWidget {
  const HumaHero({
    super.key,
    this.height = 280,
    this.state = HumaVisualState.idle,
  });
  final double height;
  final HumaVisualState state;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Hüma, AGAIN öğrenme rehberi',
    child: SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: height * .72,
            height: height * .72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x5500E5D5), Colors.transparent],
              ),
            ),
          ),
          Image.asset(
            'assets/images/huma.png',
            height: height,
            fit: BoxFit.contain,
            cacheHeight: (height * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
        ],
      ),
    ),
  );
}

class HumaGuideCard extends StatelessWidget {
  const HumaGuideCard({super.key, required this.message, this.compact = false});
  final HumaMessage message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: message.isMajorCelebration,
    label: 'Hüma: ${message.text}',
    child: Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AgainColors.night900.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .5)),
        boxShadow: AgainShadows.magicalGlow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HumaAvatar(size: compact ? 52 : 68, decorative: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hüma',
                  style: TextStyle(
                    color: AgainColors.gold400,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message.text, style: const TextStyle(height: 1.4)),
                if (message.action case final action?) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push(action.route),
                    child: Text(action.label),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class HumaSpeechBubble extends StatelessWidget {
  const HumaSpeechBubble({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Hüma: $text',
    child: Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AgainColors.night900,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AgainColors.turquoise300.withValues(alpha: .45),
        ),
      ),
      child: Text(text, style: const TextStyle(height: 1.4)),
    ),
  );
}

class HumaHelpSheet extends StatelessWidget {
  const HumaHelpSheet({
    super.key,
    required this.title,
    required this.explanation,
    this.examples = const [],
  });
  final String title, explanation;
  final List<String> examples;
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String explanation,
    List<String> examples = const [],
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => HumaHelpSheet(
      title: title,
      explanation: explanation,
      examples: examples,
    ),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const HumaAvatar(size: 54, decorative: true),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(explanation, style: const TextStyle(height: 1.5)),
          for (final example in examples)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('• $example'),
            ),
        ],
      ),
    ),
  );
}

class HumaCelebration extends StatelessWidget {
  const HumaCelebration({super.key, required this.message});
  final HumaMessage message;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const HumaAvatar(size: 96),
      const SizedBox(height: 12),
      HumaSpeechBubble(text: message.text),
    ],
  );
}

class HumaListeningState extends StatelessWidget {
  const HumaListeningState({super.key, this.available = false});
  final bool available;
  @override
  Widget build(BuildContext context) => Semantics(
    label: available
        ? 'Sesli pratik kullanılabilir'
        : 'Sesli pratik henüz kullanılamıyor',
    child: Chip(
      avatar: Icon(available ? Icons.mic_rounded : Icons.mic_off_outlined),
      label: Text(available ? 'Sesli pratik' : 'Sesli pratik yakında'),
    ),
  );
}
