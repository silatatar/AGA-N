import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';

enum AuthFormMode { login, register }

class AuthFormScreen extends ConsumerStatefulWidget {
  const AuthFormScreen({super.key, required this.mode});
  final AuthFormMode mode;

  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _terms = false;
  bool _privacy = false;
  bool _submitted = false;
  AuthFailure? _failure;

  bool get _register => widget.mode == AuthFormMode.register;
  String? get _emailError {
    final email = _email.text.trim();
    if (email.isEmpty) return 'E-posta adresini yazmalısın.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Geçerli bir e-posta adresi yaz.';
    }
    return null;
  }

  String? get _passwordError {
    if (_password.text.isEmpty) return 'Şifreni yazmalısın.';
    if (_password.text.length < 8) return 'Şifre en az 8 karakter olmalı.';
    return null;
  }

  bool get _valid =>
      _emailError == null &&
      _passwordError == null &&
      (!_register ||
          (_name.text.trim().length >= 2 &&
              _password.text == _confirm.text &&
              _terms &&
              _privacy));

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _failure = null;
    });
    if (!_valid) return;
    final controller = ref.read(authControllerProvider.notifier);
    final result = _register
        ? await controller.register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          )
        : await controller.login(
            email: _email.text.trim(),
            password: _password.text,
          );
    if (!mounted) return;
    if (result.isSuccess) {
      context.go(
        _register
            ? '${AppRoutes.emailVerificationPath}?email=${Uri.encodeComponent(_email.text.trim())}'
            : AppRoutes.storyIntroPath,
      );
    } else {
      setState(() => _failure = result.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () =>
                              context.go(AppRoutes.accountDecisionPath),
                          tooltip: 'Geri',
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      Text(
                        _register ? 'Hesabını oluştur' : 'Tekrar hoş geldin',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AgainColors.gold400),
                      ),
                      const SizedBox(height: AgainSpacing.lg),
                      if (_register) ...[
                        AgainTextField(
                          key: const Key('auth-name'),
                          label: 'Ad',
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          errorText: _submitted && _name.text.trim().length < 2
                              ? 'Ad en az 2 karakter olmalı.'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AgainSpacing.sm),
                      ],
                      AgainTextField(
                        key: const Key('auth-email'),
                        label: 'E-posta',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: _submitted ? _emailError : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AgainSpacing.sm),
                      AgainTextField(
                        key: const Key('auth-password'),
                        label: 'Şifre',
                        controller: _password,
                        obscureText: true,
                        textInputAction: _register
                            ? TextInputAction.next
                            : TextInputAction.done,
                        errorText: _submitted ? _passwordError : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_register) ...[
                        const SizedBox(height: AgainSpacing.sm),
                        AgainTextField(
                          key: const Key('auth-confirm'),
                          label: 'Şifreyi doğrula',
                          controller: _confirm,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          errorText:
                              _submitted && _password.text != _confirm.text
                              ? 'Şifreler birbiriyle eşleşmiyor.'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            key: const Key('terms-approval'),
                            value: _terms,
                            onChanged: (value) =>
                                setState(() => _terms = value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Kullanım koşullarını kabul ediyorum.',
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            key: const Key('privacy-approval'),
                            value: _privacy,
                            onChanged: (value) =>
                                setState(() => _privacy = value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Gizlilik politikasını kabul ediyorum.',
                            ),
                          ),
                        ),
                        if (_submitted && (!_terms || !_privacy))
                          const Text(
                            'Devam etmek için iki onayı da vermelisin.',
                            style: TextStyle(color: AgainColors.error),
                          ),
                      ],
                      if (_failure != null) ...[
                        const SizedBox(height: AgainSpacing.sm),
                        _AuthError(failure: _failure!, onRetry: _submit),
                      ],
                      const SizedBox(height: AgainSpacing.lg),
                      AgainPrimaryButton(
                        key: const Key('auth-submit'),
                        label: _register ? 'Kayıt Ol' : 'Giriş Yap',
                        isLoading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                      if (!_register)
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.passwordResetPath),
                          child: const Text('Şifremi unuttum'),
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
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.failure, required this.onRetry});
  final AuthFailure failure;
  final VoidCallback onRetry;
  String get message => switch (failure) {
    AuthFailure.network =>
      'Bağlantıda bir sorun oluştu. Tekrar deneyebilirsin.',
    AuthFailure.offline => 'İnternet bağlantısı görünmüyor.',
    AuthFailure.incorrectCredentials => 'E-posta veya şifre doğru değil.',
    AuthFailure.emailInUse => 'Bu e-posta ile daha önce hesap açılmış.',
    AuthFailure.unknown => 'Bir şeyler ters gitti. Lütfen tekrar dene.',
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AgainSpacing.sm),
    decoration: BoxDecoration(
      color: AgainColors.error.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(AgainRadii.control),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AgainColors.error),
        const SizedBox(width: AgainSpacing.sm),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
      ],
    ),
  );
}
