import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../world/domain/world_chapter.dart';
import '../../world/domain/world_region.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../data/story_services.dart';

class InteractiveStoryPlayerScreen extends ConsumerStatefulWidget {
  const InteractiveStoryPlayerScreen({
    super.key,
    required this.region,
    required this.chapter,
  });
  final WorldRegion region;
  final WorldChapter chapter;

  @override
  ConsumerState<InteractiveStoryPlayerScreen> createState() =>
      _InteractiveStoryPlayerScreenState();
}

class _InteractiveStoryPlayerScreenState
    extends ConsumerState<InteractiveStoryPlayerScreen> {
  int _stage = 0;
  double _textScale = 1;
  bool _showTurkish = false;
  bool _playing = false;
  final Set<String> _savedWords = {};
  String? _choice;

  static const _sentence = 'The sky is cloudy, and rain is coming.';
  static const _words = <String, _WordInfo>{
    'cloudy': _WordInfo(
      word: 'cloudy',
      pronunciation: '/ˈklaʊ.di/',
      meaning: 'bulutlu',
      definition: 'Covered with clouds.',
      example: 'It is a cloudy morning.',
    ),
    'rain': _WordInfo(
      word: 'rain',
      pronunciation: '/reɪn/',
      meaning: 'yağmur',
      definition: 'Water that falls from clouds.',
      example: 'The rain is soft today.',
    ),
    'coming': _WordInfo(
      word: 'coming',
      pronunciation: '/ˈkʌm.ɪŋ/',
      meaning: 'geliyor',
      definition: 'Moving or happening toward now.',
      example: 'A storm is coming.',
    ),
  };

  double get _progress => const [.2, .5, .75, 1.0][_stage];

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final snapshot = await ref
          .read(storyProgressRepositoryProvider)
          .readSnapshot();
      if (mounted) setState(() => _savedWords.addAll(snapshot.savedWords));
    });
  }

  Future<void> _finishChapter() async {
    await ref
        .read(storyProgressRepositoryProvider)
        .completeChapter(
          chapterId: widget.chapter.id,
          minutes: widget.chapter.durationMinutes,
          xp: 25,
        );
    if (mounted) setState(() => _stage = 3);
  }

  Future<void> _toggleAudio() async {
    final service = ref.read(storyAudioServiceProvider);
    if (_playing) {
      await service.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    await service.playPhrase(_sentence);
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _replay() async {
    setState(() => _playing = true);
    await ref.read(storyAudioServiceProvider).replayPhrase(_sentence);
    if (mounted) setState(() => _playing = false);
  }

  void _showReaderControls() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, modalSetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Okuma ayarları',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AgainSpacing.md),
                Row(
                  children: [
                    const Expanded(child: Text('Yazı boyutu')),
                    IconButton(
                      tooltip: 'Yazıyı küçült',
                      onPressed: _textScale > .85
                          ? () {
                              setState(() => _textScale -= .15);
                              modalSetState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.text_decrease_rounded),
                    ),
                    Text('${(_textScale * 100).round()}%'),
                    IconButton(
                      tooltip: 'Yazıyı büyüt',
                      onPressed: _textScale < 1.45
                          ? () {
                              setState(() => _textScale += .15);
                              modalSetState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.text_increase_rounded),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Türkçe açıklamayı göster'),
                  value: _showTurkish,
                  onChanged: (value) {
                    setState(() => _showTurkish = value);
                    modalSetState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWord(_WordInfo word) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, modalSetState) {
          final saved = _savedWords.contains(word.word);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AgainSpacing.lg,
                AgainSpacing.sm,
                AgainSpacing.lg,
                AgainSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          word.word,
                          key: const Key('word-panel-title'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AgainColors.gold400),
                        ),
                      ),
                      IconButton(
                        key: const Key('word-audio'),
                        tooltip: 'Kelimeyi dinle',
                        onPressed: () => ref
                            .read(storyAudioServiceProvider)
                            .playPhrase(word.word),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                    ],
                  ),
                  Text(
                    word.pronunciation,
                    style: const TextStyle(color: AgainColors.turquoise100),
                  ),
                  const SizedBox(height: AgainSpacing.md),
                  Text(
                    word.meaning,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AgainSpacing.sm),
                  Text(word.definition),
                  const SizedBox(height: AgainSpacing.sm),
                  Text(
                    word.example,
                    style: const TextStyle(
                      color: AgainColors.mist,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AgainSpacing.lg),
                  AgainPrimaryButton(
                    key: const Key('word-save'),
                    label: saved ? 'Kaydedildi' : 'Kelimeyi Kaydet',
                    icon: saved ? Icons.bookmark : Icons.bookmark_border,
                    onPressed: () async {
                      final repository = ref.read(
                        storyProgressRepositoryProvider,
                      );
                      if (saved) {
                        await repository.removeWord(word.word);
                        await ref
                            .read(vocabularyProvider.notifier)
                            .removeWord(word.word);
                      } else {
                        await repository.saveWord(word.word);
                        await ref
                            .read(vocabularyProvider.notifier)
                            .saveStoryWord(word.word);
                      }
                      if (!mounted) return;
                      setState(() {
                        saved
                            ? _savedWords.remove(word.word)
                            : _savedWords.add(word.word);
                      });
                      modalSetState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHumaHelp() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AgainSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HumaAvatar(size: 64),
              SizedBox(width: AgainSpacing.md),
              Expanded(
                child: Text(
                  'Cümlede “cloudy” gökyüzünü, “rain” ise yaklaşan hava olayını anlatıyor. Kelimelere dokunup ayrıntılarını görebilirsin.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == 3) return _completion(context);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      appBar: AppBar(
        backgroundColor: AgainColors.night900.withValues(alpha: .94),
        leading: IconButton(
          tooltip: 'Bölümlere dön',
          onPressed: context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chapter.title, style: const TextStyle(fontSize: 16)),
            Text(
              '${widget.region.title} · ${widget.chapter.number}. Bölüm',
              style: const TextStyle(fontSize: 11, color: AgainColors.mist),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('reader-settings'),
            tooltip: 'Okuma ayarları',
            onPressed: _showReaderControls,
            icon: const Icon(Icons.text_fields_rounded),
          ),
          IconButton(
            key: const Key('huma-help'),
            tooltip: 'Hüma’dan yardım al',
            onPressed: _showHumaHelp,
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 7,
            backgroundColor: AgainColors.night700,
            color: AgainColors.turquoise300,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AgainSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _StormHarbourPainter()),
                  ),
                ),
                const SizedBox(height: AgainSpacing.lg),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AgainDurations.page,
                  child: _stageContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stageContent(BuildContext context) => switch (_stage) {
    0 => AgainCard(
      key: const ValueKey('narrative'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fırtına Öncesi',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AgainColors.gold400),
          ),
          const SizedBox(height: AgainSpacing.md),
          Text(
            'Mira looks at the harbour. The boats move gently on the water.',
            textScaler: TextScaler.linear(_textScale),
          ),
          const SizedBox(height: AgainSpacing.md),
          Text(
            'Mira: “The sky is cloudy, and rain is coming.”',
            textScaler: TextScaler.linear(_textScale),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AgainSpacing.md),
          Wrap(
            spacing: AgainSpacing.xs,
            runSpacing: AgainSpacing.xs,
            children: [
              const Text('The sky is'),
              _TappableWord(
                info: _words['cloudy']!,
                onTap: () => _openWord(_words['cloudy']!),
              ),
              const Text(', and'),
              _TappableWord(
                info: _words['rain']!,
                onTap: () => _openWord(_words['rain']!),
              ),
              const Text('is'),
              _TappableWord(
                info: _words['coming']!,
                onTap: () => _openWord(_words['coming']!),
              ),
            ],
          ),
          if (_showTurkish) ...[
            const SizedBox(height: AgainSpacing.md),
            const Text(
              'Türkçe: Gökyüzü bulutlu ve yağmur geliyor.',
              style: TextStyle(color: AgainColors.turquoise100),
            ),
          ],
          const SizedBox(height: AgainSpacing.md),
          Row(
            children: [
              Expanded(
                child: AgainSecondaryButton(
                  key: const Key('audio-play-pause'),
                  label: _playing ? 'Duraklat' : 'Dinle',
                  onPressed: _toggleAudio,
                ),
              ),
              const SizedBox(width: AgainSpacing.sm),
              IconButton.outlined(
                key: const Key('replay-sentence'),
                tooltip: 'Cümleyi yeniden dinle',
                onPressed: _replay,
                icon: const Icon(Icons.replay_rounded),
              ),
            ],
          ),
          const SizedBox(height: AgainSpacing.md),
          AgainPrimaryButton(
            key: const Key('story-player-next'),
            label: 'Hikâyeye Devam Et',
            onPressed: () => setState(() => _stage = 1),
          ),
        ],
      ),
    ),
    1 => AgainCard(
      key: const ValueKey('choice'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mira limana gitmek istiyor. Ona ne söylersin?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AgainSpacing.md),
          for (final choice in const [
            'Take an umbrella.',
            'Wear sunglasses.',
            'The water is blue.',
          ]) ...[
            AgainSecondaryButton(
              label: choice,
              onPressed: () => setState(() {
                _choice = choice;
                _stage = 2;
              }),
            ),
            const SizedBox(height: AgainSpacing.sm),
          ],
        ],
      ),
    ),
    _ => AgainCard(
      key: const ValueKey('feedback'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            _choice == 'Take an umbrella.'
                ? Icons.check_circle_rounded
                : Icons.lightbulb_outline_rounded,
            size: 48,
            color: _choice == 'Take an umbrella.'
                ? AgainColors.emerald200
                : AgainColors.gold400,
          ),
          const SizedBox(height: AgainSpacing.md),
          Text(
            _choice == 'Take an umbrella.'
                ? 'İyi düşünce!'
                : 'Mantıklı bir cümle, ama havaya biraz daha dikkat edelim.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AgainSpacing.sm),
          Text(
            _choice == 'Take an umbrella.'
                ? 'Mira: “Great idea! I will take my umbrella.”'
                : 'Hüma: “Cloudy ve rain bize şemsiyenin iyi bir seçim olduğunu söylüyor.”',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AgainSpacing.md),
          Text(
            _choice == 'Take an umbrella.'
                ? '“Take an umbrella” yağmur beklerken nazik ve yararlı bir öneridir.'
                : 'En uygun yanıt: “Take an umbrella.”',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AgainColors.mist),
          ),
          const SizedBox(height: AgainSpacing.lg),
          AgainPrimaryButton(
            key: const Key('story-complete'),
            label: 'Bölümü Tamamla',
            onPressed: _finishChapter,
          ),
        ],
      ),
    ),
  };

  Widget _completion(BuildContext context) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _CompletionPainter()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    const SizedBox(height: AgainSpacing.xl),
                    const Icon(
                      Icons.spa_rounded,
                      size: 92,
                      color: AgainColors.emerald200,
                    ),
                    const SizedBox(height: AgainSpacing.md),
                    Text(
                      'Hava değişti, sen ilerledin.',
                      key: const Key('story-completion-title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AgainColors.gold400),
                    ),
                    const SizedBox(height: AgainSpacing.xs),
                    const Text(
                      'Hava Durumu bölümü tamamlandı.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AgainSpacing.xl),
                    AgainCard(
                      child: Column(
                        children: [
                          const _ResultRow(
                            icon: Icons.chat_bubble_outline,
                            label: 'Öğrenilen ifadeler',
                            value: '3',
                          ),
                          _ResultRow(
                            icon: Icons.bookmark_outline,
                            label: 'Kaydedilen kelimeler',
                            value: '${_savedWords.length}',
                          ),
                          const _ResultRow(
                            icon: Icons.hearing_rounded,
                            label: 'Dinleme',
                            value: 'Tamamlandı',
                          ),
                          const _ResultRow(
                            icon: Icons.mic_none_rounded,
                            label: 'Konuşma fırsatı',
                            value: 'Sunuldu',
                          ),
                          const _ResultRow(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Kazanılan XP',
                            value: '+25 XP',
                          ),
                          const _ResultRow(
                            icon: Icons.eco_outlined,
                            label: 'Tohum gelişimi',
                            value: '+1 yaprak',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AgainSpacing.lg),
                    AgainPrimaryButton(
                      key: const Key('completion-continue'),
                      label: 'Devam Et',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/world/${widget.region.slug}'),
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

class _TappableWord extends StatelessWidget {
  const _TappableWord({required this.info, required this.onTap});
  final _WordInfo info;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    key: Key('story-word-${info.word}'),
    tooltip: '${info.word} kelimesinin anlamını gör',
    label: Text(info.word),
    onPressed: onTap,
  );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AgainSpacing.sm),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(
                color: AgainColors.slate.withValues(alpha: .22),
              ),
            ),
    ),
    child: Row(
      children: [
        Icon(icon, color: AgainColors.turquoise300),
        const SizedBox(width: AgainSpacing.sm),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _WordInfo {
  const _WordInfo({
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.definition,
    required this.example,
  });
  final String word;
  final String pronunciation;
  final String meaning;
  final String definition;
  final String example;
}

class _StormHarbourPainter extends CustomPainter {
  const _StormHarbourPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(AgainRadii.card)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF263A56), Color(0xFF305E70), Color(0xFF073A55)],
        ).createShader(rect),
    );
    final cloud = Paint()
      ..color = const Color(0xFFB8C5CE).withValues(alpha: .55);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(size.width * (.12 + i * .16), size.height * (.2 + i % 2 * .06)),
        size.height * .12,
        cloud,
      );
    }
    final water = Paint()
      ..color = AgainColors.turquoise300.withValues(alpha: .2)
      ..strokeWidth = 2;
    for (var i = 0; i < 7; i++) {
      canvas.drawArc(
        Rect.fromLTWH(
          -20 + i * 30,
          size.height * .67 + i * 7,
          size.width * .62,
          18,
        ),
        0,
        math.pi,
        false,
        water,
      );
    }
    final boat = Paint()..color = AgainColors.gold500;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .63, size.height * .63)
        ..lineTo(size.width * .86, size.height * .63)
        ..lineTo(size.width * .81, size.height * .76)
        ..lineTo(size.width * .68, size.height * .76)
        ..close(),
      boat,
    );
    canvas.drawLine(
      Offset(size.width * .74, size.height * .63),
      Offset(size.width * .74, size.height * .34),
      Paint()
        ..color = AgainColors.gold200
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompletionPainter extends CustomPainter {
  const _CompletionPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            Color(0xFF126978),
            AgainColors.night900,
            AgainColors.night950,
          ],
        ).createShader(rect),
    );
    final sparkle = Paint()..color = AgainColors.gold200.withValues(alpha: .55);
    for (var i = 0; i < 24; i++) {
      canvas.drawCircle(
        Offset((i * 71.0) % size.width, (i * 113.0) % size.height),
        i.isEven ? 1.5 : .8,
        sparkle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
