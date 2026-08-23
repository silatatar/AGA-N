import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../data/story_services.dart';

class GuidedStoryIntroScreen extends ConsumerStatefulWidget {
  const GuidedStoryIntroScreen({super.key});

  @override
  ConsumerState<GuidedStoryIntroScreen> createState() =>
      _GuidedStoryIntroScreenState();
}

class _GuidedStoryIntroScreenState
    extends ConsumerState<GuidedStoryIntroScreen> {
  int _stage = 0;
  bool _playing = false;
  bool _defined = false;
  String? _reply;

  Future<void> _listen() async {
    setState(() => _playing = true);
    await ref.read(storyAudioServiceProvider).playPhrase('Hello, I am Mira.');
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _complete() async {
    await ref.read(storyProgressRepositoryProvider).awardFirstSeed();
    if (mounted) setState(() => _stage = 4);
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(learnerSelectionProvider).value;
    final level = ref.watch(onboardingProvider).value?.level;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final audioAvailable = ref.watch(storyAudioAvailabilityProvider);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _ValleyPainter()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AgainColors.night950.withValues(alpha: .25),
                  AgainColors.night950.withValues(alpha: .94),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AgainSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    children: [
                      const _StoryHeader(),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height < 700
                            ? AgainSpacing.lg
                            : AgainSpacing.huge,
                      ),
                      AnimatedSlide(
                        duration: reduceMotion
                            ? Duration.zero
                            : AgainDurations.hero,
                        offset: _stage >= 0 ? Offset.zero : const Offset(0, .1),
                        child: const HumaAvatar(size: 106),
                      ),
                      const SizedBox(height: AgainSpacing.md),
                      AgainCard(
                        child: AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : AgainDurations.page,
                          child: _storyContent(type, level, audioAvailable),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyContent(
    LearnerType? type,
    EnglishLevel? level,
    bool audioAvailable,
  ) => switch (_stage) {
    0 => _Dialogue(
      key: const ValueKey(0),
      title: 'Burası Yaşam Vadisi.',
      body: _introCopy(type),
      action: 'Vadiyi keşfet',
      onPressed: () => setState(() => _stage = 1),
    ),
    1 => Column(
      key: const ValueKey(1),
      children: [
        const Text('İlk kelimemizle başlayalım.', textAlign: TextAlign.center),
        const SizedBox(height: AgainSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AgainSpacing.sm,
          children: [
            Semantics(
              button: true,
              label: 'Hello kelimesinin anlamını aç',
              child: ActionChip(
                key: const Key('story-word-hello'),
                avatar: const Icon(Icons.touch_app_outlined, size: 18),
                label: const Text(
                  'Hello',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                onPressed: () => setState(() => _defined = true),
              ),
            ),
            const Text(', I am Mira.', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: AgainSpacing.md),
        IconButton.filledTonal(
          key: const Key('story-listen'),
          tooltip: audioAvailable
              ? (_playing ? 'Dinleniyor' : 'Cümleyi dinle')
              : 'Ses henüz kullanılamıyor',
          onPressed: !audioAvailable || _playing ? null : _listen,
          icon: Icon(
            _playing ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
          ),
        ),
        AnimatedSize(
          duration: AgainDurations.micro,
          child: _defined
              ? Container(
                  margin: const EdgeInsets.only(top: AgainSpacing.md),
                  padding: const EdgeInsets.all(AgainSpacing.sm),
                  decoration: BoxDecoration(
                    color: AgainColors.turquoise300.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AgainRadii.control),
                  ),
                  child: const Text(
                    'Hello — Merhaba. Birini selamlamak için kullanılır.',
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: AgainSpacing.lg),
        AgainPrimaryButton(
          key: const Key('story-phrase-continue'),
          label: 'Yanıtla',
          onPressed: _defined ? () => setState(() => _stage = 2) : null,
        ),
      ],
    ),
    2 => Column(
      key: const ValueKey(2),
      children: [
        Text(
          level == EnglishLevel.beginner
              ? 'Mira’ya nasıl karşılık verirsin?'
              : 'Mira seni selamladı. Yanıtını seç.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AgainSpacing.md),
        for (final choice in const ['Hello, Mira!', 'Goodbye, Mira.'])
          Padding(
            padding: const EdgeInsets.only(bottom: AgainSpacing.sm),
            child: AgainSecondaryButton(
              label: choice,
              onPressed: () {
                setState(() {
                  _reply = choice;
                  _stage = 3;
                });
              },
            ),
          ),
      ],
    ),
    3 => _Dialogue(
      key: const ValueKey(3),
      title: _reply == 'Hello, Mira!' ? 'Mira gülümsedi.' : 'Mira el salladı.',
      body: _reply == 'Hello, Mira!'
          ? '“Hello!” Vadideki ilk bağını kurdun.'
          : '“Goodbye” vedalaşmak demek. Mira yeniden denemen için burada.',
      action: _reply == 'Hello, Mira!'
          ? 'İlk tohumunu al'
          : 'Yanıtı yeniden seç',
      onPressed: _reply == 'Hello, Mira!'
          ? _complete
          : () => setState(() => _stage = 2),
    ),
    _ => Column(
      key: const ValueKey(4),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AgainDurations.hero,
          builder: (_, value, child) =>
              Transform.scale(scale: .7 + value * .3, child: child),
          child: const Icon(
            Icons.spa_rounded,
            size: 78,
            color: AgainColors.emerald200,
          ),
        ),
        const SizedBox(height: AgainSpacing.md),
        Text(
          'İlk kelimen filizlendi.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AgainColors.gold400),
        ),
        const SizedBox(height: AgainSpacing.xs),
        const Text(
          'İlk tohumun Yaşam Vadisi’ne eklendi.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AgainSpacing.lg),
        AgainPrimaryButton(
          key: const Key('story-to-map'),
          label: 'Dünya Haritasına Git',
          icon: Icons.map_outlined,
          onPressed: () => context.go(AppRoutes.worldMapPath),
        ),
      ],
    ),
  };

  String _introCopy(LearnerType? type) => switch (type) {
    LearnerType.child =>
      'Her yeni kelime vadinde küçük bir iz bırakır. Hazır mısın?',
    LearnerType.teen => 'Her kelime yeni bir hikâyenin kilidini açar.',
    LearnerType.adult =>
      'Her yeni kelime, dünyayı biraz daha yakından anlamanı sağlar.',
    null => 'Her yeni kelime, vadinde bir iz bırakır.',
  };
}

class _Dialogue extends StatelessWidget {
  const _Dialogue({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });
  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AgainColors.turquoise100),
      ),
      const SizedBox(height: AgainSpacing.sm),
      Text(body, textAlign: TextAlign.center),
      const SizedBox(height: AgainSpacing.lg),
      AgainPrimaryButton(label: action, onPressed: onPressed),
    ],
  );
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader();
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text(
        'YAŞAM VADİSİ',
        style: TextStyle(
          color: AgainColors.gold400,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      SizedBox(height: AgainSpacing.xxs),
      Text('İlk Karşılaşma', style: TextStyle(color: AgainColors.mist)),
    ],
  );
}

class _ValleyPainter extends CustomPainter {
  const _ValleyPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF071633), Color(0xFF126978), Color(0xFF183D35)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    final moon = Paint()..color = AgainColors.gold200.withValues(alpha: .75);
    canvas.drawCircle(Offset(size.width * .78, size.height * .18), 34, moon);
    final mountain = Paint()..color = const Color(0xFF123D45);
    final path = Path()..moveTo(0, size.height * .62);
    for (var i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      final y = size.height * (.42 + .12 * math.sin(i * 1.7));
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, mountain);
    final meadow = Paint()..color = const Color(0xFF174F3F);
    canvas.drawOval(
      Rect.fromLTRB(
        -80,
        size.height * .62,
        size.width + 80,
        size.height * 1.15,
      ),
      meadow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
