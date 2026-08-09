import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import 'auth_controller.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});
  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _email = TextEditingController();
  String? _message;
  bool _success = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _message = 'Geçerli bir e-posta adresi yaz.');
      return;
    }
    final result = await ref.read(authControllerProvider.notifier).reset(email);
    if (!mounted) return;
    setState(() {
      _success = result.isSuccess;
      _message = result.isSuccess
          ? 'Şifre yenileme bağlantısı gönderildi.'
          : 'Bağlantı kurulamadı. Lütfen tekrar dene.';
    });
  }

  @override
  Widget build(BuildContext context) => _AuthStateShell(
    title: 'Şifreni yenile',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Hesabına bağlı e-posta adresini yaz.'),
        const SizedBox(height: AgainSpacing.md),
        AgainTextField(
          key: const Key('reset-email'),
          label: 'E-posta',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_message != null) ...[
          const SizedBox(height: AgainSpacing.sm),
          Text(
            _message!,
            style: TextStyle(
              color: _success ? AgainColors.success : AgainColors.error,
            ),
          ),
        ],
        const SizedBox(height: AgainSpacing.lg),
        AgainPrimaryButton(
          label: 'Bağlantı Gönder',
          isLoading: ref.watch(authControllerProvider).isLoading,
          onPressed: _send,
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.loginPath),
          child: const Text('Giriş ekranına dön'),
        ),
      ],
    ),
  );
}

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});
  final String email;
  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  String? _message;
  Future<void> _resend() async {
    final result = await ref
        .read(authControllerProvider.notifier)
        .resend(widget.email);
    if (mounted) {
      setState(
        () => _message = result.isSuccess
            ? 'Doğrulama e-postası yeniden gönderildi.'
            : 'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => _AuthStateShell(
    title: 'E-postanı doğrula',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_unread_outlined,
          size: 56,
          color: AgainColors.turquoise300,
        ),
        const SizedBox(height: AgainSpacing.md),
        Text(
          '${widget.email} adresine bir doğrulama bağlantısı gönderdik.',
          textAlign: TextAlign.center,
        ),
        if (_message != null) ...[
          const SizedBox(height: AgainSpacing.sm),
          Text(_message!, textAlign: TextAlign.center),
        ],
        const SizedBox(height: AgainSpacing.lg),
        AgainPrimaryButton(
          key: const Key('verification-continue'),
          label: 'Doğruladım, Devam Et',
          onPressed: () => context.go(AppRoutes.storyIntroPath),
        ),
        TextButton(onPressed: _resend, child: const Text('Tekrar gönder')),
      ],
    ),
  );
}

class _AuthStateShell extends StatelessWidget {
  const _AuthStateShell({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
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
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AgainColors.gold400),
                    ),
                    const SizedBox(height: AgainSpacing.lg),
                    child,
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
