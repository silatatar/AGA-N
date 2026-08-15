import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../../startup/startup_decision.dart';
import 'auth_controller.dart';

class AccountDecisionScreen extends ConsumerWidget {
  const AccountDecisionScreen({super.key});

  void _unavailable(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider bağlantısı henüz hazır değil. E-posta ile devam edebilirsin.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: OpeningAtmosphere(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AgainSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AgainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: HumaAvatar(size: 82)),
                    const SizedBox(height: AgainSpacing.md),
                    Text(
                      'Yolculuğunu kaydet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AgainColors.gold400),
                    ),
                    const SizedBox(height: AgainSpacing.xs),
                    const Text(
                      'Hesabın, ilerlemeni tüm cihazlarında korur.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AgainSpacing.lg),
                    AgainPrimaryButton(
                      key: const Key('register-email'),
                      label: 'E-posta ile Kayıt Ol',
                      icon: Icons.mail_outline,
                      onPressed: () => context.go(AppRoutes.registerPath),
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    AgainSecondaryButton(
                      label: 'Google ile Devam Et',
                      onPressed: () => _unavailable(context, 'Google'),
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    AgainSecondaryButton(
                      label: 'Apple ile Devam Et',
                      onPressed: () => _unavailable(context, 'Apple'),
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    TextButton(
                      key: const Key('already-account'),
                      onPressed: () => context.go(AppRoutes.loginPath),
                      child: const Text('Zaten hesabım var'),
                    ),
                    if (ref.watch(guestModeAllowedProvider))
                      TextButton(
                        key: const Key('continue-guest'),
                        onPressed: () async {
                          await ref
                              .read(startupControllerProvider.notifier)
                              .continueAsGuest();
                          if (context.mounted) {
                            context.go(AppRoutes.storyIntroPath);
                          }
                        },
                        child: const Text('Misafir Devam Et'),
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
