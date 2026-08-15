import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../onboarding/domain/onboarding_preferences.dart';
import '../../onboarding/presentation/onboarding_controller.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../huma/presentation/huma_components.dart';
import '../../story/data/story_services.dart';
import '../domain/conversation_models.dart';
import 'conversation_controller.dart';

class HumaConversationEntryScreen extends ConsumerStatefulWidget {
  const HumaConversationEntryScreen({super.key});
  @override
  ConsumerState<HumaConversationEntryScreen> createState() =>
      _HumaConversationEntryScreenState();
}

class _HumaConversationEntryScreenState
    extends ConsumerState<HumaConversationEntryScreen> {
  ConversationMode _mode = ConversationMode.text;

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(onboardingProvider).value?.level;
    return Scaffold(
      body: OpeningAtmosphere(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const HumaHero(height: 210),
                          const SizedBox(height: 16),
                          Text(
                            'Bugün biraz İngilizce konuşalım mı?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bir senaryo seç; güvenli bir ortamda kısa bir İngilizce konuşma yapalım.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              Chip(
                                avatar: const Icon(
                                  Icons.school_outlined,
                                  size: 18,
                                ),
                                label: Text('Seviye: ${_levelLabel(level)}'),
                              ),
                              SegmentedButton<ConversationMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: ConversationMode.text,
                                    icon: Icon(Icons.keyboard_outlined),
                                    label: Text('Metin'),
                                  ),
                                  ButtonSegment(
                                    value: ConversationMode.voice,
                                    icon: Icon(Icons.mic_none),
                                    label: Text('Ses yakında'),
                                    enabled: false,
                                  ),
                                ],
                                selected: {_mode},
                                onSelectionChanged: (value) =>
                                    setState(() => _mode = value.first),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 720
                            ? 4
                            : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio:
                            MediaQuery.sizeOf(context).width >= 720
                            ? 1.05
                            : .78,
                      ),
                      itemCount: ConversationScenario.values.length,
                      itemBuilder: (context, index) {
                        final scenario = ConversationScenario.values[index];
                        final ready = scenario == ConversationScenario.cafe;
                        return AgainCard(
                          key: ValueKey('scenario-${scenario.name}'),
                          onTap: () {
                            if (!ready) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bu konuşma senaryosu yakında açılacak.',
                                  ),
                                ),
                              );
                              return;
                            }
                            ref
                                .read(conversationProvider.notifier)
                                .start(scenario, _mode);
                            context.push(AppRoutes.humaChatPath);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _scenarioIcon(scenario),
                                color: ready
                                    ? AgainColors.turquoise300
                                    : AgainColors.slate,
                                size: 32,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                scenario.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ready ? 'Hazır • 3–5 dk' : 'Yakında',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HumaConversationChatScreen extends ConsumerStatefulWidget {
  const HumaConversationChatScreen({super.key});
  @override
  ConsumerState<HumaConversationChatScreen> createState() =>
      _HumaConversationChatScreenState();
}

class _HumaConversationChatScreenState
    extends ConsumerState<HumaConversationChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AgainDurations.page,
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(conversationProvider);
    ref.listen(conversationProvider, (_, next) => _scrollDown());
    if (session == null) {
      return Scaffold(
        body: Center(
          child: AgainPrimaryButton(
            label: 'Senaryo seç',
            onPressed: () => context.go(AppRoutes.humaConversationPath),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(session.scenario.title),
        actions: [
          TextButton.icon(
            key: const Key('end-session'),
            onPressed: () {
              ref.read(conversationProvider.notifier).end();
              context.pushReplacement(AppRoutes.humaSummaryPath);
            },
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Bitir'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        session.messages.length + (session.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == session.messages.length) {
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(message: session.messages[index]);
                    },
                  ),
                ),
                if (session.suggestions.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: session.suggestions
                          .map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(text),
                                onPressed: () => ref
                                    .read(conversationProvider.notifier)
                                    .send(text),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                _Composer(
                  controller: _controller,
                  mode: session.mode,
                  enabled: !session.isTyping,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message});
  final ConversationMessage message;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.author == ConversationAuthor.user;
    final isSystem = message.author == ConversationAuthor.system;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && !isSystem) ...[
              const HumaAvatar(size: 38),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser
                      ? AgainColors.turquoise400.withValues(alpha: .24)
                      : isSystem
                      ? AgainColors.gold400.withValues(alpha: .12)
                      : AgainColors.night800,
                  borderRadius: BorderRadius.circular(AgainRadii.card),
                  border: Border.all(
                    color: isSystem
                        ? AgainColors.gold400.withValues(alpha: .45)
                        : AgainColors.turquoise300.withValues(alpha: .18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.text),
                    if (message.showTranslation &&
                        message.translation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message.translation!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AgainColors.turquoise100,
                        ),
                      ),
                    ],
                    if (!isUser && !isSystem) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 2,
                        children: [
                          TextButton(
                            key: Key('translate-${message.id}'),
                            onPressed: () => ref
                                .read(conversationProvider.notifier)
                                .toggleTranslation(message.id),
                            child: Text(
                              message.showTranslation
                                  ? 'Çeviriyi gizle'
                                  : 'Çevir',
                            ),
                          ),
                          IconButton(
                            key: Key('replay-${message.id}'),
                            tooltip: 'Cümleyi tekrar oynat',
                            onPressed: () => ref
                                .read(storyAudioServiceProvider)
                                .replayPhrase(message.text),
                            icon: const Icon(Icons.volume_up_outlined),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HumaAvatar(size: 38),
          SizedBox(width: 8),
          Chip(
            key: Key('typing-indicator'),
            avatar: SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text('Hüma yazıyor…'),
          ),
        ],
      ),
    ),
  );
}

class _Composer extends ConsumerWidget {
  const _Composer({
    required this.controller,
    required this.mode,
    required this.enabled,
  });
  final TextEditingController controller;
  final ConversationMode mode;
  final bool enabled;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (mode == ConversationMode.voice)
              IconButton.filledTonal(
                key: const Key('voice-placeholder'),
                tooltip: 'Sesli konuşma',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sesli giriş, güvenli ses servisi bağlandığında açılacak.',
                    ),
                  ),
                ),
                icon: const Icon(Icons.mic_none),
              ),
            Expanded(
              child: TextField(
                key: const Key('conversation-input'),
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(ref),
                decoration: const InputDecoration(
                  hintText: 'İngilizce yanıtını yaz…',
                ),
              ),
            ),
            IconButton(
              key: const Key('correct-sentence'),
              tooltip: 'Cümlemi düzelt',
              onPressed: enabled
                  ? () => ref
                        .read(conversationProvider.notifier)
                        .correct(controller.text)
                  : null,
              icon: const Icon(Icons.spellcheck),
            ),
            IconButton.filled(
              key: const Key('send-message'),
              tooltip: 'Gönder',
              onPressed: enabled ? () => _send(ref) : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    ),
  );

  void _send(WidgetRef ref) {
    final text = controller.text;
    if (text.trim().isEmpty) return;
    controller.clear();
    ref.read(conversationProvider.notifier).send(text);
  }
}

class HumaConversationSummaryScreen extends ConsumerWidget {
  const HumaConversationSummaryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(conversationProvider);
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Oturum bulunamadı.')));
    }
    return Scaffold(
      body: OpeningAtmosphere(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    const HumaAvatar(size: 92),
                    const SizedBox(height: 16),
                    Text(
                      'Konuşma tamamlandı',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kafede sipariş verirken doğal ve nazik ifadeler kullandın.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _SummarySection(
                      title: 'Güçlü ifadeler',
                      icon: Icons.auto_awesome,
                      items: session.strongExpressions.isEmpty
                          ? const ['I’d like…, please.']
                          : session.strongExpressions,
                    ),
                    _SummarySection(
                      title: 'Düzeltmeler',
                      icon: Icons.spellcheck,
                      items: session.corrections.isEmpty
                          ? const ['Bu oturumda düzeltme gerekmedi.']
                          : session.corrections,
                    ),
                    _SummarySection(
                      title: 'Yeni kelimeler',
                      icon: Icons.menu_book_outlined,
                      items: session.newWords.isEmpty
                          ? const ['size • boy', 'medium • orta']
                          : session.newWords,
                    ),
                    const _SummarySection(
                      title: 'Sıradaki öneri',
                      icon: Icons.explore_outlined,
                      items: [
                        'Yol tarifi senaryosuyla yön ifadelerini pekiştir.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    AgainPrimaryButton(
                      label: 'Ana Sayfaya Dön',
                      onPressed: () => context.go(AppRoutes.homePath),
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

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.icon,
    required this.items,
  });
  final String title;
  final IconData icon;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AgainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AgainColors.gold400),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('• $item'),
            ),
          ),
        ],
      ),
    ),
  );
}

String _levelLabel(EnglishLevel? level) => switch (level) {
  EnglishLevel.beginner => 'Başlangıç',
  EnglishLevel.words => 'Temel kelimeler',
  EnglishLevel.simpleSentences => 'Basit cümleler',
  EnglishLevel.conversational => 'Konuşma',
  EnglishLevel.placementTest => 'Belirlenecek',
  null => 'Başlangıç',
};

IconData _scenarioIcon(ConversationScenario scenario) => switch (scenario) {
  ConversationScenario.daily => Icons.chat_bubble_outline,
  ConversationScenario.cafe => Icons.local_cafe_outlined,
  ConversationScenario.directions => Icons.directions_outlined,
  ConversationScenario.hotel => Icons.hotel_outlined,
  ConversationScenario.airport => Icons.flight_outlined,
  ConversationScenario.meetingSomeone => Icons.waving_hand_outlined,
  ConversationScenario.jobInterview => Icons.work_outline,
  ConversationScenario.freeTalk => Icons.forum_outlined,
};
