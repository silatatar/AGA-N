import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../story/data/story_services.dart';
import '../domain/vocabulary_entry.dart';
import 'vocabulary_controller.dart';
import 'vocabulary_garden_screen.dart';

class WordDetailScreen extends ConsumerStatefulWidget {
  const WordDetailScreen({super.key, required this.wordId});
  final String wordId;
  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  final _example = TextEditingController();
  @override
  void dispose() {
    _example.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vocabularyProvider);
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Kelime yüklenemedi.')),
            data: (entries) {
              final entry = entries
                  .where((item) => item.id == widget.wordId)
                  .firstOrNull;
              if (entry == null) {
                return const Center(child: Text('Kelime bulunamadı.'));
              }
              if (_example.text.isEmpty && entry.userExample != null) {
                _example.text = entry.userExample!;
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AgainSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Kelime Bahçesi’ne dön',
                            onPressed: context.pop,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        AgainCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.word,
                                      key: const Key('word-detail-title'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            color: AgainColors.gold400,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    key: const Key('word-pronunciation-audio'),
                                    tooltip:
                                        ref.watch(
                                          storyAudioAvailabilityProvider,
                                        )
                                        ? 'Kelimeyi dinle'
                                        : 'Ses henüz kullanılamıyor',
                                    onPressed:
                                        ref.watch(
                                          storyAudioAvailabilityProvider,
                                        )
                                        ? () => ref
                                              .read(storyAudioServiceProvider)
                                              .playPhrase(entry.word)
                                        : null,
                                    icon: const Icon(Icons.volume_up_rounded),
                                  ),
                                  IconButton(
                                    key: const Key('toggle-favorite'),
                                    tooltip: 'Favori',
                                    onPressed: () => ref
                                        .read(vocabularyProvider.notifier)
                                        .toggleFavorite(entry),
                                    icon: Icon(
                                      entry.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: AgainColors.gold400,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                entry.pronunciation,
                                style: const TextStyle(
                                  color: AgainColors.turquoise100,
                                ),
                              ),
                              const SizedBox(height: AgainSpacing.md),
                              Text(
                                entry.turkishMeaning,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AgainSpacing.sm),
                              Text(entry.englishDefinition),
                              const SizedBox(height: AgainSpacing.md),
                              _DetailBlock(
                                title: 'Örnek',
                                text: entry.exampleSentence,
                              ),
                              const SizedBox(height: AgainSpacing.sm),
                              _DetailBlock(
                                title: 'Hikâyedeki bağlam',
                                text: entry.storyContext,
                              ),
                              const SizedBox(height: AgainSpacing.sm),
                              Text(
                                entry.storyTitle,
                                style: const TextStyle(color: AgainColors.mist),
                              ),
                              const SizedBox(height: AgainSpacing.xs),
                              Text(
                                'Keşfedildi: ${_date(entry.discoveredAt)}',
                                style: const TextStyle(
                                  color: AgainColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AgainSpacing.md),
                        AgainCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Öğrenme durumu',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AgainSpacing.sm),
                              LinearProgressIndicator(
                                value: entry.correctStreak.clamp(0, 4) / 4,
                                minHeight: 9,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              const SizedBox(height: AgainSpacing.xs),
                              Text(
                                '${growthLabel(entry.growthState)} · ${entry.reviewCount} gerçek tekrar · ${entry.successfulReviewCount} başarılı',
                              ),
                              const SizedBox(height: AgainSpacing.xs),
                              Text(
                                'Son tekrar: ${entry.lastReviewedAt == null ? 'Henüz yok' : _date(entry.lastReviewedAt!)}\nSıradaki tekrar: ${_date(entry.nextReviewAt)}',
                                style: const TextStyle(color: AgainColors.mist),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: entry.isDifficult,
                                  onChanged: (_) => ref
                                      .read(vocabularyProvider.notifier)
                                      .toggleDifficult(entry),
                                  title: const Text('Bu kelimede zorlanıyorum'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AgainSpacing.md),
                        AgainCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AgainTextField(
                                key: const Key('user-example-field'),
                                label: 'Kendi örneğin',
                                hint: 'Bu kelimeyle bir İngilizce cümle yaz.',
                                controller: _example,
                              ),
                              const SizedBox(height: AgainSpacing.sm),
                              AgainSecondaryButton(
                                label: 'Örneği Kaydet',
                                onPressed: () => ref
                                    .read(vocabularyProvider.notifier)
                                    .saveUserExample(entry, _example.text),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AgainSpacing.lg),
                        Text(
                          'Tekrar modu seç',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AgainSpacing.sm),
                        for (final mode in const [
                          ReviewMode.meaningRecall,
                          ReviewMode.matching,
                          ReviewMode.sentenceCompletion,
                        ])
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AgainSpacing.sm,
                            ),
                            child: AgainSecondaryButton(
                              label: mode.title,
                              onPressed: () => context.push(
                                '/vocabulary/${entry.id}/review/${mode.name}',
                              ),
                            ),
                          ),
                        const SizedBox(height: AgainSpacing.md),
                        AgainSecondaryButton(
                          label: 'Bahçeden Kaldır',
                          onPressed: () => _confirmRemove(context, ref, entry),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String _date(DateTime value) => '${value.day}.${value.month}.${value.year}';

Future<void> _confirmRemove(
  BuildContext context,
  WidgetRef ref,
  VocabularyEntry entry,
) async {
  final remove = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Kelime bahçeden kaldırılsın mı?'),
      content: Text(
        '${entry.word} ve inceleme geçmişi bu cihazdan kaldırılacak.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Vazgeç'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Kaldır'),
        ),
      ],
    ),
  );
  if (remove != true || !context.mounted) return;
  await ref.read(vocabularyProvider.notifier).removeWord(entry.id);
  if (context.mounted) context.go('/vocabulary');
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AgainSpacing.sm),
    decoration: BoxDecoration(
      color: AgainColors.night900.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(AgainRadii.control),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AgainColors.slate)),
        const SizedBox(height: AgainSpacing.xxs),
        Text(text),
      ],
    ),
  );
}
