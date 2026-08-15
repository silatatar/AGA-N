import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/state_views.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../data/story_repository.dart';
import '../domain/story_definition.dart';
import 'story_session_controller.dart';

class DataDrivenStoryPlayerScreen extends ConsumerWidget {
  const DataDrivenStoryPlayerScreen({super.key, required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(storySessionProvider(storyId))
      .when(
        loading: () => const Scaffold(body: LoadingView()),
        error: (error, stack) =>
            _StoryError(onReturn: () => context.go('/world-map')),
        data: (state) => FutureBuilder<StoryDefinition?>(
          future: ref.read(storyRepositoryProvider).getStory(storyId),
          builder: (context, snapshot) {
            final story = snapshot.data;
            if (story == null) return const Scaffold(body: LoadingView());
            if (state.isComplete) {
              return _Completion(story: story, state: state);
            }
            final node = story.nodes[state.currentNodeId];
            if (node == null) {
              return _StoryError(onReturn: () => context.go('/world-map'));
            }
            return _Player(story: story, node: node, state: state);
          },
        ),
      );
}

class _Player extends ConsumerStatefulWidget {
  const _Player({required this.story, required this.node, required this.state});
  final StoryDefinition story;
  final StoryNode node;
  final StorySessionState state;
  @override
  ConsumerState<_Player> createState() => _PlayerState();
}

class _PlayerState extends ConsumerState<_Player> {
  final _writing = TextEditingController();
  bool _showGrammar = false;
  double _textScale = 1;

  @override
  void dispose() {
    _writing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(storySessionProvider(widget.story.id).notifier);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = _ReadingPanel(
      node: widget.node,
      state: widget.state,
      textScale: _textScale,
      showGrammar: _showGrammar,
      writing: _writing,
      onWord: (word) => _showWord(context, word),
      onChoice: controller.choose,
      onNext: controller.next,
      onComplete: controller.complete,
      onWriting: () => controller.submitWriting(_writing.text),
      onGrammar: () => setState(() => _showGrammar = !_showGrammar),
      onHelp: () => _showHelp(context),
    );
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: SafeArea(
        child: Column(
          children: [
            _StoryTopBar(
              story: widget.story,
              state: widget.state,
              onClose: context.pop,
              onTextSize: () =>
                  setState(() => _textScale = _textScale == 1 ? 1.15 : 1),
            ),
            Expanded(
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: _SceneArt(scene: widget.node.scene)),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(28),
                            child: content,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _SceneArt(scene: widget.node.scene),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: content,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => HumaHelpSheet(
      explanation:
          widget.node.humaHelp ??
          widget.node.turkishExplanation ??
          'Bu sahnede bağlam ipuçlarını takip et.',
    ),
  );

  void _showWord(BuildContext context, StoryVocabularyItem word) {
    ref.read(storySessionProvider(widget.story.id).notifier).discover(word.id);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _WordSheet(story: widget.story, word: word),
    );
  }
}

class _StoryTopBar extends StatelessWidget {
  const _StoryTopBar({
    required this.story,
    required this.state,
    required this.onClose,
    required this.onTextSize,
  });
  final StoryDefinition story;
  final StorySessionState state;
  final VoidCallback onClose, onTextSize;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Hikâyeden çık',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: (state.visitedNodeIds.length / story.nodes.length).clamp(
                  0,
                  1,
                ),
                minHeight: 4,
                color: AgainColors.turquoise300,
                backgroundColor: AgainColors.night700,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Metin boyutu',
          onPressed: onTextSize,
          icon: const Icon(Icons.text_fields_rounded),
        ),
      ],
    ),
  );
}

class _SceneArt extends StatelessWidget {
  const _SceneArt({required this.scene});
  final StoryScene scene;
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: scene.semanticLabel ?? 'Hikâye sahnesi',
    child: RepaintBoundary(
      child: SizedBox(
        height: (MediaQuery.sizeOf(context).height * .36).clamp(190, 390),
        width: double.infinity,
        child: scene.assetPath == null
            ? const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AgainColors.welcomeGradient,
                ),
              )
            : Image.asset(
                scene.assetPath!,
                fit: BoxFit.cover,
                cacheWidth: 1440,
                errorBuilder: (context, error, stack) => const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AgainColors.welcomeGradient,
                  ),
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
      ),
    ),
  );
}

class _ReadingPanel extends StatelessWidget {
  const _ReadingPanel({
    required this.node,
    required this.state,
    required this.textScale,
    required this.showGrammar,
    required this.writing,
    required this.onWord,
    required this.onChoice,
    required this.onNext,
    required this.onComplete,
    required this.onWriting,
    required this.onGrammar,
    required this.onHelp,
  });
  final StoryNode node;
  final StorySessionState state;
  final double textScale;
  final bool showGrammar;
  final TextEditingController writing;
  final ValueChanged<StoryVocabularyItem> onWord;
  final ValueChanged<StoryChoice> onChoice;
  final VoidCallback onNext, onComplete, onWriting, onGrammar, onHelp;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 680),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (node.speaker == 'Hüma')
          HumaNarrationBubble(text: node.englishText)
        else ...[
          if (node.speaker != null)
            Text(
              node.speaker!,
              style: const TextStyle(
                color: AgainColors.gold400,
                fontWeight: FontWeight.w900,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            node.englishText,
            style: TextStyle(
              fontSize: 23 * textScale,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (node.turkishExplanation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              node.turkishExplanation!,
              style: const TextStyle(color: AgainColors.turquoise100),
            ),
          ),
        if (state.feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: HumaNarrationBubble(text: state.feedback!, compact: true),
          ),
        if (node.vocabulary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Wrap(
              spacing: 8,
              children: [
                for (final word in node.vocabulary)
                  ActionChip(
                    key: Key('story-word-${word.id}'),
                    label: Text(word.word),
                    avatar: const Icon(Icons.auto_stories_rounded, size: 17),
                    onPressed: () => onWord(word),
                  ),
              ],
            ),
          ),
        if (node.grammarNote != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onGrammar,
            icon: const Icon(Icons.lightbulb_outline_rounded),
            label: const Text('Dil ipucu'),
          ),
          if (showGrammar)
            AgainCard(
              child: Text(node.grammarNote!, key: const Key('grammar-note')),
            ),
        ],
        if (node.kind == StoryNodeKind.writing) ...[
          const SizedBox(height: 16),
          Text(
            node.writingPrompt ?? '',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('story-writing'),
            controller: writing,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'It is cloudy today.'),
          ),
        ],
        if (node.kind == StoryNodeKind.speaking)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: AgainCard(
              child: Text(
                'Sesli pratik yakında. Bu adım konuşma ilerlemesi kazandırmaz.',
              ),
            ),
          ),
        const SizedBox(height: 18),
        if (node.kind == StoryNodeKind.choice) ...[
          for (final choice in node.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Semantics(
                button: true,
                label: '${choice.label}. Hikâye seçimi.',
                child: AgainSecondaryButton(
                  label: choice.label,
                  onPressed: () => onChoice(choice),
                ),
              ),
            ),
        ] else
          AgainPrimaryButton(
            key: Key(
              node.kind == StoryNodeKind.completion
                  ? 'story-complete'
                  : 'story-player-next',
            ),
            label: node.kind == StoryNodeKind.completion
                ? 'Bölümü Tamamla'
                : node.kind == StoryNodeKind.writing
                ? 'Cümlemi Kaydet'
                : node.id == 'valley-intro'
                ? 'Vadiyi keşfet'
                : 'Devam Et',
            onPressed: node.kind == StoryNodeKind.completion
                ? onComplete
                : node.kind == StoryNodeKind.writing
                ? onWriting
                : onNext,
          ),
        const SizedBox(height: 8),
        AgainSecondaryButton(
          key: const Key('huma-help'),
          label: 'Hüma’ya Sor',
          onPressed: onHelp,
        ),
        if (node.listeningActivityId != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Ses yakında',
              textAlign: TextAlign.center,
              style: TextStyle(color: AgainColors.slate),
            ),
          ),
      ],
    ),
  );
}

class HumaNarrationBubble extends StatelessWidget {
  const HumaNarrationBubble({
    super.key,
    required this.text,
    this.compact = false,
  });
  final String text;
  final bool compact;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HumaAvatar(size: compact ? 42 : 58),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: compact ? 15 : 18,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class HumaHelpSheet extends StatelessWidget {
  const HumaHelpSheet({super.key, required this.explanation});
  final String explanation;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: HumaNarrationBubble(text: explanation),
    ),
  );
}

class _WordSheet extends ConsumerWidget {
  const _WordSheet({required this.story, required this.word});
  final StoryDefinition story;
  final StoryVocabularyItem word;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved =
        ref
            .watch(storySessionProvider(story.id))
            .value
            ?.wordsSaved
            .contains(word.id) ??
        false;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              word.word,
              key: const Key('word-panel-title'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AgainColors.gold400),
            ),
            Text(word.pronunciation),
            const SizedBox(height: 8),
            Text(
              word.turkishMeaning,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(word.englishDefinition),
            const SizedBox(height: 8),
            Text(word.example),
            const SizedBox(height: 16),
            if (story.id == 'first-encounter') ...[
              AgainSecondaryButton(
                key: const Key('story-phrase-continue'),
                label: 'Devam Et',
                onPressed: () {
                  ref.read(storySessionProvider(story.id).notifier).next();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
            AgainPrimaryButton(
              key: const Key('word-save'),
              label: saved ? 'Kaydedildi' : 'Kelime Bahçesine Ekle',
              onPressed: saved
                  ? null
                  : () async {
                      await ref
                          .read(storySessionProvider(story.id).notifier)
                          .saveWord(word.id);
                      await ref
                          .read(vocabularyProvider.notifier)
                          .saveStoryVocabularyItem(
                            item: word,
                            storyId: story.id,
                            storyTitle: story.title,
                            worldId: story.worldId,
                            worldTitle: story.worldId == 'deniz-kralligi'
                                ? 'Deniz Krallığı'
                                : 'Yaşam Vadisi',
                          );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _Completion extends StatelessWidget {
  const _Completion({required this.story, required this.state});
  final StoryDefinition story;
  final StorySessionState state;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                const HumaAvatar(size: 92),
                const SizedBox(height: 16),
                Text(
                  story.id == 'first-encounter'
                      ? 'İlk kelimen filizlendi.'
                      : 'Fırtına Öncesi tamamlandı',
                  key: const Key('story-completion-title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AgainColors.gold400,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bu bölümde hava durumunu bağlam içinde kullandın.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                AgainCard(
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 22,
                    runSpacing: 14,
                    children: [
                      _Result('${state.wordsDiscovered.length}', 'Keşfedilen'),
                      _Result('${state.wordsSaved.length}', 'Kaydedilen'),
                      _Result('${state.selectedChoices.length}', 'Seçim'),
                      _Result('+${story.reward.xp} XP', 'Ödül'),
                      _Result('${state.writingResponses.length}', 'Yazma'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AgainPrimaryButton(
                  key: Key(
                    story.id == 'first-encounter'
                        ? 'story-to-map'
                        : 'completion-continue',
                  ),
                  label: 'Dünya’ya Dön',
                  onPressed: () => context.go('/world-map'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Result extends StatelessWidget {
  const _Result(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AgainColors.turquoise100,
        ),
      ),
      Text(label),
    ],
  );
}

class _StoryError extends StatelessWidget {
  const _StoryError({required this.onReturn});
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HumaAvatar(size: 84),
              const SizedBox(height: 16),
              const Text(
                'Bu hikâyede küçük bir sorun oluştu.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AgainPrimaryButton(label: 'Dünya’ya Dön', onPressed: onReturn),
            ],
          ),
        ),
      ),
    ),
  );
}
