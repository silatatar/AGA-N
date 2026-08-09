import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/onboarding_preferences.dart';
import 'onboarding_controller.dart';

class PersonalisedOnboardingScreen extends ConsumerStatefulWidget {
  const PersonalisedOnboardingScreen({super.key});

  @override
  ConsumerState<PersonalisedOnboardingScreen> createState() =>
      _PersonalisedOnboardingScreenState();
}

class _PersonalisedOnboardingScreenState
    extends ConsumerState<PersonalisedOnboardingScreen> {
  int _step = 0;

  static const _goals = [
    'Günlük konuşmak',
    'Seyahat etmek',
    'Film ve dizileri anlamak',
    'İş hayatında kullanmak',
    'Okul veya sınav',
    'Yurt dışında yaşamak',
    'Konuşma korkumu yenmek',
    'Kendimi geliştirmek',
  ];
  static const _interests = [
    'Mitoloji',
    'Seyahat',
    'Kültür',
    'Tarih',
    'Gizem',
    'Fantastik',
    'Sanat',
    'Müzik',
    'Sinema',
    'Bilim',
    'Teknoloji',
    'Günlük yaşam',
    'İş dünyası',
  ];
  static const _levelLabels = {
    EnglishLevel.beginner: 'Yeni başlıyorum',
    EnglishLevel.words: 'Biraz kelime biliyorum',
    EnglishLevel.simpleSentences: 'Basit cümleleri anlayabiliyorum',
    EnglishLevel.conversational: 'Konuşabiliyorum ama geliştirmek istiyorum',
    EnglishLevel.placementTest: 'Seviyemi test et',
  };

  bool _canContinue(OnboardingPreferences value) => switch (_step) {
    0 => value.goals.isNotEmpty,
    1 => value.level != null,
    2 => value.interests.isNotEmpty,
    _ => value.dailyMinutes != null,
  };

  void _back() {
    if (_step == 0) {
      context.go(AppRoutes.profileNamePath);
    } else {
      setState(() => _step--);
    }
  }

  void _continue(OnboardingPreferences value) {
    if (!_canContinue(value)) return;
    if (_step == 1 && value.level == EnglishLevel.placementTest) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seviye testi yakında'),
          content: const Text(
            'Kısa seviye testi ileride eklenecek. Şimdilik bu tercihini kaydettik.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _step++);
              },
              child: const Text('Devam Et'),
            ),
          ],
        ),
      );
    } else if (_step < 3) {
      setState(() => _step++);
    } else {
      context.go(AppRoutes.accountDecisionPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final learnerType = ref.watch(learnerSelectionProvider).value;
    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: AgainSecondaryButton(
                label: 'Tekrar dene',
                onPressed: () => ref.invalidate(onboardingProvider),
              ),
            ),
            data: (value) => SingleChildScrollView(
              padding: const EdgeInsets.all(AgainSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            key: const Key('onboarding-back'),
                            tooltip: 'Geri',
                            onPressed: _back,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: AgainSpacing.sm),
                          Expanded(
                            child: Semantics(
                              label: '4 adımın ${_step + 1}. adımı',
                              child: LinearProgressIndicator(
                                value: (_step + 1) / 4,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(99),
                                backgroundColor: AgainColors.night700,
                                color: AgainColors.turquoise300,
                              ),
                            ),
                          ),
                          const SizedBox(width: AgainSpacing.sm),
                          Text('${_step + 1}/4'),
                        ],
                      ),
                      const SizedBox(height: AgainSpacing.xl),
                      Text(
                        _question,
                        key: const Key('onboarding-question'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AgainColors.gold400),
                      ),
                      const SizedBox(height: AgainSpacing.sm),
                      Text(
                        _supportingCopy(learnerType),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AgainColors.mist),
                      ),
                      const SizedBox(height: AgainSpacing.xl),
                      AgainCard(child: _stepBody(value)),
                      if (_step == 3) ...[
                        const SizedBox(height: AgainSpacing.md),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HumaAvatar(size: 42),
                            SizedBox(width: AgainSpacing.sm),
                            Flexible(
                              child: Text(
                                'Küçük ama düzenli adımlar da harika bir başlangıç.',
                                style: TextStyle(color: AgainColors.mist),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AgainSpacing.lg),
                      AgainPrimaryButton(
                        key: const Key('onboarding-continue'),
                        label: _step == 3 ? 'Tamamla' : 'Devam Et',
                        onPressed: _canContinue(value)
                            ? () => _continue(value)
                            : null,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _question => const [
    'İngilizce sana hangi kapıları açsın?',
    'Şu anda İngilizcede kendini nerede görüyorsun?',
    'Hangi dünyaları keşfetmek istersin?',
    'Her gün ne kadar zaman ayırmak istersin?',
  ][_step];

  String _supportingCopy(LearnerType? type) => switch ((type, _step)) {
    (LearnerType.child, 0) => 'İstediğin kadarını seçebilirsin.',
    (LearnerType.teen, 0) => 'Sana uygun maceraları birlikte seçelim.',
    (LearnerType.adult, 0) => 'Deneyimini hedeflerine göre şekillendireceğiz.',
    (_, 2) => 'Birden fazla dünya seçebilirsin.',
    (_, 3) => 'Sürdürebileceğin süre, en iyi süredir.',
    _ => 'Sana en yakın seçeneği işaretle.',
  };

  Widget _stepBody(OnboardingPreferences value) => switch (_step) {
    0 => _MultiChoice(
      values: _goals,
      selected: value.goals,
      keyPrefix: 'goal',
      onChanged: ref.read(onboardingProvider.notifier).setGoals,
    ),
    1 => Column(
      children: _levelLabels.entries
          .map(
            (entry) => _SingleChoice(
              key: Key('level-${entry.key.name}'),
              label: entry.value,
              selected: value.level == entry.key,
              icon: entry.key == EnglishLevel.placementTest
                  ? Icons.science_outlined
                  : Icons.auto_stories_outlined,
              onTap: () =>
                  ref.read(onboardingProvider.notifier).setLevel(entry.key),
            ),
          )
          .toList(),
    ),
    2 => _MultiChoice(
      values: _interests,
      selected: value.interests,
      keyPrefix: 'interest',
      onChanged: ref.read(onboardingProvider.notifier).setInterests,
    ),
    _ => Column(
      children: [5, 10, 15, 20, 30]
          .map(
            (minutes) => _SingleChoice(
              key: Key('minutes-$minutes'),
              label: '$minutes dakika',
              selected: value.dailyMinutes == minutes,
              icon: Icons.schedule_rounded,
              badge: minutes == 10 || minutes == 15 ? 'Önerilen' : null,
              onTap: () => ref
                  .read(onboardingProvider.notifier)
                  .setDailyMinutes(minutes),
            ),
          )
          .toList(),
    ),
  };
}

class _MultiChoice extends StatelessWidget {
  const _MultiChoice({
    required this.values,
    required this.selected,
    required this.keyPrefix,
    required this.onChanged,
  });
  final List<String> values;
  final Set<String> selected;
  final String keyPrefix;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AgainSpacing.sm,
    runSpacing: AgainSpacing.sm,
    alignment: WrapAlignment.center,
    children: values.map((value) {
      final active = selected.contains(value);
      return FilterChip(
        key: Key('$keyPrefix-$value'),
        label: Text(value),
        selected: active,
        onSelected: (_) {
          final next = {...selected};
          active ? next.remove(value) : next.add(value);
          onChanged(next);
        },
      );
    }).toList(),
  );
}

class _SingleChoice extends StatelessWidget {
  const _SingleChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
    this.badge,
  });
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AgainSpacing.sm),
    child: Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AgainRadii.button),
        child: AnimatedContainer(
          duration: AgainDurations.micro,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: AgainSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AgainColors.turquoise300.withValues(alpha: .14)
                : AgainColors.night900.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AgainRadii.button),
            border: Border.all(
              color: selected ? AgainColors.turquoise300 : AgainColors.slate,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AgainColors.gold400 : AgainColors.mist,
              ),
              const SizedBox(width: AgainSpacing.sm),
              Expanded(child: Text(label)),
              if (badge != null)
                Text(
                  badge!,
                  style: const TextStyle(
                    color: AgainColors.emerald500,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(width: AgainSpacing.xs),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AgainColors.turquoise300 : AgainColors.slate,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
