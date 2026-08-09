import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/learner_profile.dart';
import '../domain/learner_type.dart';
import 'learner_profile_controller.dart';
import 'learner_selection_controller.dart';

class ProfileNameSetupScreen extends ConsumerStatefulWidget {
  const ProfileNameSetupScreen({super.key});

  @override
  ConsumerState<ProfileNameSetupScreen> createState() =>
      _ProfileNameSetupScreenState();
}

class _ProfileNameSetupScreenState
    extends ConsumerState<ProfileNameSetupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  LearnerAvatar _avatar = LearnerAvatar.huma;
  bool _submitted = false;
  bool _hydrated = false;

  static final _namePattern = RegExp(r"^[a-zA-ZçÇğĞıİöÖşŞüÜ '’-]+$");
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9._]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _nameError(String value) {
    final name = value.trim();
    if (name.isEmpty) return 'Görünen ad gerekli.';
    if (name.length < 2 || name.length > 24) {
      return 'Ad 2–24 karakter olmalı.';
    }
    if (!_namePattern.hasMatch(name)) {
      return 'Yalnızca harf, boşluk, tire ve kesme işareti kullan.';
    }
    return null;
  }

  String? _usernameError(String value) {
    final username = value.trim();
    if (username.isEmpty) return null;
    if (username.length < 3 || username.length > 20) {
      return 'Kullanıcı adı 3–20 karakter olmalı.';
    }
    if (!_usernamePattern.hasMatch(username)) {
      return 'Harf, rakam, nokta veya alt çizgi kullan.';
    }
    return null;
  }

  bool get _isValid =>
      _nameError(_nameController.text) == null &&
      _usernameError(_usernameController.text) == null;

  Future<void> _continue() async {
    setState(() => _submitted = true);
    if (!_isValid) return;
    final saved = await ref
        .read(learnerProfileProvider.notifier)
        .save(
          LearnerProfile(
            displayName: _nameController.text.trim(),
            username: _usernameController.text.trim().isEmpty
                ? null
                : _usernameController.text.trim(),
            avatar: _avatar,
          ),
        );
    if (saved && mounted) context.go(AppRoutes.learningGoalPath);
  }

  @override
  Widget build(BuildContext context) {
    final learnerType = ref.watch(learnerSelectionProvider).value;
    final storedProfile = ref.watch(learnerProfileProvider).value;
    if (!_hydrated && storedProfile != null) {
      _hydrated = true;
      _nameController.text = storedProfile.displayName;
      _usernameController.text = storedProfile.username ?? '';
      _avatar = storedProfile.avatar;
    }
    final isChild = learnerType == LearnerType.child;
    final profileState = ref.watch(learnerProfileProvider);
    final name = _nameController.text.trim();

    return Scaffold(
      backgroundColor: AgainColors.night950,
      body: OpeningAtmosphere(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AgainSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            key: const Key('profile-name-back'),
                            tooltip: 'Geri',
                            onPressed: () =>
                                context.go(AppRoutes.learnerProfilesPath),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(height: AgainSpacing.sm),
                        Text(
                          'Sana nasıl seslenelim?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: AgainColors.gold400),
                        ),
                        const SizedBox(height: AgainSpacing.xs),
                        const Text(
                          'Profilini sana özel hâle getirelim.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AgainColors.mist),
                        ),
                        const SizedBox(height: AgainSpacing.xl),
                        Flex(
                          direction: desktop ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: desktop ? 620 : constraints.maxWidth,
                              child: AgainCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AgainTextField(
                                      key: const Key('display-name-field'),
                                      label: 'Görünen ad',
                                      hint: 'Örneğin: Aslı',
                                      controller: _nameController,
                                      maxLength: 24,
                                      textInputAction: isChild
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      autofillHints: const [AutofillHints.name],
                                      errorText: _submitted
                                          ? _nameError(_nameController.text)
                                          : null,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    if (!isChild) ...[
                                      const SizedBox(height: AgainSpacing.sm),
                                      AgainTextField(
                                        key: const Key('username-field'),
                                        label: 'Kullanıcı adı (isteğe bağlı)',
                                        hint: 'ornek.kullanici',
                                        controller: _usernameController,
                                        maxLength: 20,
                                        textInputAction: TextInputAction.done,
                                        errorText: _submitted
                                            ? _usernameError(
                                                _usernameController.text,
                                              )
                                            : null,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ] else ...[
                                      const SizedBox(height: AgainSpacing.sm),
                                      const _PrivacyNote(),
                                    ],
                                    const SizedBox(height: AgainSpacing.md),
                                    Text(
                                      'Avatarını seç',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: AgainSpacing.sm),
                                    Wrap(
                                      spacing: AgainSpacing.sm,
                                      runSpacing: AgainSpacing.sm,
                                      children: LearnerAvatar.values
                                          .map(
                                            (avatar) => _AvatarChoice(
                                              avatar: avatar,
                                              selected: avatar == _avatar,
                                              onTap: () => setState(
                                                () => _avatar = avatar,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: AgainSpacing.sm),
                                    const _FutureUploadTile(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: desktop ? AgainSpacing.lg : 0,
                              height: desktop ? 0 : AgainSpacing.lg,
                            ),
                            SizedBox(
                              width: desktop ? 400 : constraints.maxWidth,
                              child: _HumaPreview(
                                name: name.isEmpty ? 'yeni dostum' : name,
                                avatar: _avatar,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AgainSpacing.lg),
                        Center(
                          child: SizedBox(
                            width: desktop ? 360 : double.infinity,
                            child: AgainPrimaryButton(
                              key: const Key('profile-name-continue'),
                              label: 'Devam Et',
                              isLoading: profileState.isLoading,
                              onPressed: _continue,
                              icon: Icons.arrow_forward_rounded,
                            ),
                          ),
                        ),
                        if (profileState.hasError) ...[
                          const SizedBox(height: AgainSpacing.sm),
                          const Text(
                            'Profil kaydedilemedi. Lütfen tekrar dene.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AgainColors.error),
                          ),
                        ],
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

class _HumaPreview extends StatelessWidget {
  const _HumaPreview({required this.name, required this.avatar});

  final String name;
  final LearnerAvatar avatar;

  @override
  Widget build(BuildContext context) => AgainCard(
    child: Column(
      children: [
        const HumaAvatar(size: 112),
        const SizedBox(height: AgainSpacing.md),
        AnimatedSwitcher(
          duration: AgainDurations.page,
          child: Text(
            'Tanıştığımıza sevindim, $name.',
            key: ValueKey(name),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AgainColors.turquoise100),
          ),
        ),
        const SizedBox(height: AgainSpacing.md),
        _AvatarVisual(avatar: avatar, size: 76),
        const SizedBox(height: AgainSpacing.xs),
        Text(avatar.label, style: const TextStyle(color: AgainColors.mist)),
      ],
    ),
  );
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final LearnerAvatar avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${avatar.label} avatarını seç',
    child: InkWell(
      key: Key('avatar-${avatar.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AgainRadii.card),
      child: AnimatedContainer(
        duration: AgainDurations.micro,
        width: 92,
        padding: const EdgeInsets.all(AgainSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AgainColors.turquoise300.withValues(alpha: .14)
              : AgainColors.night900.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(AgainRadii.card),
          border: Border.all(
            color: selected ? AgainColors.gold400 : AgainColors.slate,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AvatarVisual(avatar: avatar, size: 52),
            const SizedBox(height: AgainSpacing.xs),
            Text(
              avatar.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AvatarVisual extends StatelessWidget {
  const _AvatarVisual({required this.avatar, required this.size});

  final LearnerAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatar == LearnerAvatar.huma) return HumaAvatar(size: size);
    final (icon, colors) = switch (avatar) {
      LearnerAvatar.moon => (
        Icons.nightlight_round,
        [AgainColors.purple500, AgainColors.turquoise300],
      ),
      LearnerAvatar.compass => (
        Icons.explore_rounded,
        [AgainColors.gold400, AgainColors.night800],
      ),
      LearnerAvatar.forest => (
        Icons.forest_rounded,
        [AgainColors.emerald500, AgainColors.turquoise300],
      ),
      LearnerAvatar.huma => throw StateError('Handled above'),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
        border: Border.all(color: AgainColors.gold400),
      ),
      child: Icon(icon, size: size * .48, color: Colors.white),
    );
  }
}

class _FutureUploadTile extends StatelessWidget {
  const _FutureUploadTile();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Fotoğraf yükleme, yakında kullanıma açılacak',
    enabled: false,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AgainSpacing.md,
        vertical: AgainSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AgainRadii.button),
        border: Border.all(color: AgainColors.slate.withValues(alpha: .45)),
      ),
      child: const Row(
        children: [
          Icon(Icons.add_a_photo_outlined, color: AgainColors.slate),
          SizedBox(width: AgainSpacing.sm),
          Expanded(
            child: Text(
              'Fotoğraf yükle — yakında',
              style: TextStyle(color: AgainColors.slate),
            ),
          ),
          Icon(Icons.lock_outline, size: 18, color: AgainColors.slate),
        ],
      ),
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AgainSpacing.sm),
    decoration: BoxDecoration(
      color: AgainColors.emerald500.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(AgainRadii.button),
    ),
    child: const Row(
      children: [
        Icon(Icons.shield_outlined, color: AgainColors.emerald500),
        SizedBox(width: AgainSpacing.sm),
        Expanded(
          child: Text(
            'Sadece sana nasıl sesleneceğimizi soruyoruz. Kullanıcı adı daha sonra bir yetişkinle hazırlanabilir.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
