import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../../core/widgets/again_navigation.dart';
import '../../../core/widgets/state_views.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../huma/application/huma_context_provider.dart';
import '../../huma/domain/huma_models.dart';
import '../../huma/presentation/huma_components.dart';
import '../domain/story_square_models.dart';
import 'story_square_controller.dart';

class StorySquareScreen extends ConsumerWidget {
  const StorySquareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChild =
        ref.watch(learnerSelectionProvider).value == LearnerType.child;
    final square = ref.watch(storySquareProvider);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AgainColors.night950,
              AgainColors.night700,
              AgainColors.night900,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const RepaintBoundary(
              child: CustomPaint(painter: _TownSquarePainter()),
            ),
            SafeArea(
              bottom: false,
              child: square.when(
                loading: () =>
                    const LoadingView(message: 'Meydan hazırlanıyor…'),
                error: (_, _) => ErrorView(
                  title: 'Meydana ulaşılamadı',
                  message: 'Meydan şu anda hazırlanamadı.',
                  onRetry: () => ref.invalidate(storySquareProvider),
                ),
                data: (state) => _SquareContent(state: state, isChild: isChild),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _SquareBottomNav(),
      floatingActionButton: FloatingActionButton.large(
        key: const Key('square-microphone'),
        tooltip: 'Hüma rehberli konuşma pratiği',
        onPressed: () => _showGuidedPractice(context, isChild),
        backgroundColor: AgainColors.turquoise300,
        foregroundColor: AgainColors.night950,
        child: const Icon(Icons.mic_rounded, size: 34),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _SquareContent extends ConsumerWidget {
  const _SquareContent({required this.state, required this.isChild});
  final StorySquareState state;
  final bool isChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                children: [
                  Row(
                    children: [
                      const HumaAvatar(size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hikâye Meydanı',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const Text(
                              'Konuş, dinle ve hikâyeleri birlikte keşfet.',
                            ),
                          ],
                        ),
                      ),
                      const Chip(
                        avatar: Icon(Icons.science_outlined, size: 17),
                        label: Text('İç demo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  HumaGuideCard(
                    message: ref.watch(humaMessageProvider(HumaScreen.square)),
                    compact: true,
                  ),
                  const SizedBox(height: 14),
                  if (isChild)
                    const _ChildSafetyBanner()
                  else
                    const _DemoBanner(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: SquareArea.values
                          .where(
                            (area) =>
                                !isChild ||
                                area == SquareArea.humaGroupPractice,
                          )
                          .map(
                            (area) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: ValueKey('square-area-${area.name}'),
                                label: Text(area.title),
                                selected:
                                    state.selectedArea == area ||
                                    (isChild &&
                                        area == SquareArea.humaGroupPractice),
                                onSelected: (_) => ref
                                    .read(storySquareProvider.notifier)
                                    .selectArea(area),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _TodayPrompt(isChild: isChild),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isChild ? 'Hüma ile güvenli pratik' : 'Konuşma odaları',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...state.rooms
                      .where(
                        (room) =>
                            (!isChild || room.isHumaGuided) &&
                            (isChild ||
                                state.selectedArea == SquareArea.todayTopic ||
                                room.area == state.selectedArea),
                      )
                      .map((room) => _RoomCard(room: room, isChild: isChild)),
                  if (!isChild) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Meydandan örnekler',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DemoActivity(activity: state.activity),
                  ],
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();
  @override
  Widget build(BuildContext context) => AgainCard(
    padding: const EdgeInsets.all(14),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: AgainColors.gold400),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Bu meydandaki adlar, konuşmalar ve oda hareketleri kurgusal demo içeriğidir.',
          ),
        ),
      ],
    ),
  );
}

class _ChildSafetyBanner extends StatelessWidget {
  const _ChildSafetyBanner();
  @override
  Widget build(BuildContext context) => AgainCard(
    key: const Key('child-safe-square'),
    padding: const EdgeInsets.all(14),
    child: const Row(
      children: [
        Icon(Icons.shield_outlined, color: AgainColors.emerald200),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Güvenli mod açık. Burada yalnızca Hüma’nın hazırladığı yanıtlarla pratik yapılır.',
          ),
        ),
      ],
    ),
  );
}

class _TodayPrompt extends StatelessWidget {
  const _TodayPrompt({required this.isChild});
  final bool isChild;
  @override
  Widget build(BuildContext context) => AgainCard(
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AgainColors.purple700,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AgainColors.purple200,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BUGÜNÜN KONUSU'),
              const SizedBox(height: 4),
              Text(
                isChild
                    ? 'What makes you happy?'
                    : 'What makes a place feel like home?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.isChild});
  final DemoSquareRoom room;
  final bool isChild;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AgainCard(
      key: ValueKey('demo-room-${room.id}'),
      onTap: () => _showRoom(context, room, isChild),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AgainColors.night700,
            child: Icon(
              Icons.record_voice_over_outlined,
              color: AgainColors.turquoise300,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(room.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                Text(
                  '${room.level} • ${room.durationMinutes} dk • Hüma rehberli demo',
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class _DemoActivity extends StatelessWidget {
  const _DemoActivity({required this.activity});
  final List<DemoSquareActivity> activity;
  @override
  Widget build(BuildContext context) => AgainCard(
    key: const Key('fictional-demo-activity'),
    child: Column(
      children: activity
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(item.name),
              subtitle: Text(item.message),
            ),
          )
          .toList(),
    ),
  );
}

void _showRoom(BuildContext context, DemoSquareRoom room, bool isChild) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HumaAvatar(size: 66),
            const SizedBox(height: 12),
            Text(
              room.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(room.prompt, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              isChild
                  ? 'Yalnızca hazır yanıtlar kullanılacak; başka kişilerle iletişim kurulmaz.'
                  : 'Bu önizleme yalnızca Hüma ve kurgusal demo akışıyla çalışır.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            AgainPrimaryButton(
              key: const Key('start-guided-room'),
              label: 'Rehberli Provayı Başlat',
              onPressed: () {
                Navigator.pop(context);
                _showGuidedPractice(context, isChild);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showGuidedPractice(BuildContext context, bool isChild) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _GuidedPracticeSheet(isChild: isChild),
  );
}

class _GuidedPracticeSheet extends StatefulWidget {
  const _GuidedPracticeSheet({required this.isChild});
  final bool isChild;
  @override
  State<_GuidedPracticeSheet> createState() => _GuidedPracticeSheetState();
}

class _GuidedPracticeSheetState extends State<_GuidedPracticeSheet> {
  String? selected;
  bool completed = false;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HumaAvatar(size: 72),
          const SizedBox(height: 12),
          Text('Hüma ile prova', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            widget.isChild
                ? 'Seni mutlu eden bir şeyi seç. Hüma cümleni kurmana yardım etsin.'
                : '“What makes a place feel like home?” sorusuna bir yanıt seç.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (final option
              in widget.isChild
                  ? const [
                      'My family makes me happy.',
                      'My friends make me happy.',
                    ]
                  : const [
                      'The people make it feel like home.',
                      'Familiar sounds make it feel like home.',
                    ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceChip(
                label: Text(option),
                selected: selected == option,
                onSelected: (_) => setState(() => selected = option),
              ),
            ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            AgainCard(
              key: const Key('guided-practice-feedback'),
              child: Text(
                'Hüma: Harika bir seçim. Şimdi yavaşça söyle: “$selected”',
              ),
            ),
          ],
          const SizedBox(height: 16),
          AgainPrimaryButton(
            key: const Key('complete-guided-practice'),
            label: completed ? 'Pratik Tamamlandı' : 'Provayı Bitir',
            onPressed: selected == null || completed
                ? null
                : () => setState(() => completed = true),
          ),
          if (completed) ...[
            const SizedBox(height: 8),
            AgainSecondaryButton(
              label: 'Meydana Dön',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    ),
  );
}

class _SquareBottomNav extends StatelessWidget {
  const _SquareBottomNav();
  @override
  Widget build(BuildContext context) =>
      const AgainPrimaryNavigation(selectedIndex: 2);
}

class _TownSquarePainter extends CustomPainter {
  const _TownSquarePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AgainColors.gold400.withValues(alpha: .17),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .5, size.height * .38),
              radius: size.width * .55,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .38),
      size.width * .55,
      glow,
    );
    final building = Paint()
      ..color = AgainColors.night950.withValues(alpha: .42);
    for (var i = 0; i < 7; i++) {
      final width = size.width / 6;
      final left = i * width - width * .25;
      final height = 90.0 + (i % 3) * 35;
      canvas.drawRect(
        Rect.fromLTWH(left, size.height * .22 - height, width * .82, height),
        building,
      );
      final roof = Path()
        ..moveTo(left - 8, size.height * .22 - height)
        ..lineTo(left + width * .41, size.height * .22 - height - 45)
        ..lineTo(left + width * .9, size.height * .22 - height)
        ..close();
      canvas.drawPath(roof, building);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
