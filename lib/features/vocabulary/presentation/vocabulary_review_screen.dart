import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../story/data/story_services.dart';
import '../domain/vocabulary_entry.dart';
import 'vocabulary_controller.dart';

class VocabularyReviewScreen extends ConsumerStatefulWidget {
  const VocabularyReviewScreen({
    super.key,
    required this.wordId,
    required this.mode,
  });
  final String wordId;
  final ReviewMode mode;
  @override
  ConsumerState<VocabularyReviewScreen> createState() =>
      _VocabularyReviewScreenState();
}

class _VocabularyReviewScreenState
    extends ConsumerState<VocabularyReviewScreen> {
  final _sentence = TextEditingController();
  bool _answered = false;
  bool _correct = false;

  @override
  void dispose() {
    _sentence.dispose();
    super.dispose();
  }

  Future<void> _answer(VocabularyEntry entry, bool correct) async {
    await ref
        .read(vocabularyProvider.notifier)
        .recordReview(entry: entry, mode: widget.mode, correct: correct);
    if (mounted) {
      setState(() {
        _answered = true;
        _correct = correct;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(vocabularyProvider).value ?? const [];
    final entry = entries.where((item) => item.id == widget.wordId).firstOrNull;
    if (entry == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Kelimeye dön',
                          onPressed: context.pop,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            widget.mode.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AgainSpacing.lg),
                    AgainCard(child: _question(entry)),
                    if (_answered) ...[
                      const SizedBox(height: AgainSpacing.md),
                      AgainCard(
                        child: Column(
                          children: [
                            Icon(
                              _correct
                                  ? Icons.check_circle_rounded
                                  : Icons.refresh_rounded,
                              size: 48,
                              color: _correct
                                  ? AgainColors.emerald200
                                  : AgainColors.gold400,
                            ),
                            const SizedBox(height: AgainSpacing.sm),
                            Text(
                              _correct
                                  ? 'İyi hatırladın.'
                                  : 'Bu kelimeyi yeniden görmek öğrenmenin bir parçası.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AgainSpacing.sm),
                            Text(
                              'Yeni prototip tekrar aralığı: ${_correct ? 1 : 1} gün',
                              style: const TextStyle(color: AgainColors.mist),
                            ),
                            const SizedBox(height: AgainSpacing.md),
                            AgainPrimaryButton(
                              key: const Key('review-finish'),
                              label: 'Kelimeye Dön',
                              onPressed: context.pop,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _question(VocabularyEntry entry) {
    if (_answered) {
      return Text(
        '${entry.word} — ${entry.turkishMeaning}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      );
    }
    return switch (widget.mode) {
      ReviewMode.meaningRecall => _OptionsQuestion(
        prompt: '“${entry.word}” ne demek?',
        options: [entry.turkishMeaning, 'güneşli', 'rüzgâr'],
        correct: entry.turkishMeaning,
        onAnswer: (answer) => _answer(entry, answer == entry.turkishMeaning),
      ),
      ReviewMode.sentenceCompletion => _OptionsQuestion(
        prompt: 'The ___ is soft today.',
        options: [entry.word, 'boat', 'sun'],
        correct: entry.word,
        onAnswer: (answer) => _answer(entry, answer == entry.word),
      ),
      ReviewMode.listeningRecognition => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton.filledTonal(
            key: const Key('review-audio'),
            tooltip: 'Kelimeyi dinle',
            onPressed: () =>
                ref.read(storyAudioServiceProvider).playPhrase(entry.word),
            icon: const Icon(Icons.volume_up_rounded),
          ),
          const SizedBox(height: AgainSpacing.md),
          _OptionsQuestion(
            prompt: 'Duyduğun kelimeyi seç.',
            options: [entry.word, 'cloud', 'wind'],
            correct: entry.word,
            onAnswer: (answer) => _answer(entry, answer == entry.word),
          ),
        ],
      ),
      ReviewMode.matching => _OptionsQuestion(
        prompt: '${entry.turkishMeaning} ile eşleşen kelime hangisi?',
        options: [entry.word, 'sunny', 'cold'],
        correct: entry.word,
        onAnswer: (answer) => _answer(entry, answer == entry.word),
      ),
      ReviewMode.useInSentence => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '“${entry.word}” kelimesini bir cümlede kullan.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AgainSpacing.md),
          AgainTextField(
            key: const Key('review-sentence-field'),
            label: 'İngilizce cümlen',
            controller: _sentence,
          ),
          const SizedBox(height: AgainSpacing.md),
          AgainPrimaryButton(
            label: 'Cümlemi Kullandım',
            onPressed: () => _answer(
              entry,
              _sentence.text.toLowerCase().contains(entry.word) &&
                  _sentence.text.trim().split(' ').length >= 3,
            ),
          ),
        ],
      ),
    };
  }
}

class _OptionsQuestion extends StatelessWidget {
  const _OptionsQuestion({
    required this.prompt,
    required this.options,
    required this.correct,
    required this.onAnswer,
  });
  final String prompt;
  final List<String> options;
  final String correct;
  final ValueChanged<String> onAnswer;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(prompt, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AgainSpacing.lg),
      for (final option in options) ...[
        AgainSecondaryButton(label: option, onPressed: () => onAnswer(option)),
        const SizedBox(height: AgainSpacing.sm),
      ],
    ],
  );
}
