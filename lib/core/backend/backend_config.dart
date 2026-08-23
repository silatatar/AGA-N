enum AppEnvironment { development, staging, production }

enum BackendProvider { localDevelopment, supabase }

enum BackendStatus {
  developmentLocal,
  supabaseUnconfigured,
  supabaseConfigured,
}

class BackendConfig {
  const BackendConfig({
    required this.environment,
    required this.provider,
    this.supabaseUrl,
    this.supabasePublishableKey,
  });

  final AppEnvironment environment;
  final BackendProvider provider;
  final String? supabaseUrl;
  final String? supabasePublishableKey;

  bool get hasProductionBackend =>
      provider == BackendProvider.supabase &&
      supabaseUrl?.isNotEmpty == true &&
      supabasePublishableKey?.isNotEmpty == true;

  BackendStatus get status => switch (provider) {
    BackendProvider.localDevelopment => BackendStatus.developmentLocal,
    BackendProvider.supabase when hasProductionBackend =>
      BackendStatus.supabaseConfigured,
    BackendProvider.supabase => BackendStatus.supabaseUnconfigured,
  };

  /// Build-time public configuration only. Supply with `--dart-define`.
  /// A service-role key or database password must never be used by the app.
  static BackendConfig fromEnvironment() {
    const useDevelopment = bool.fromEnvironment(
      'AGAIN_USE_DEVELOPMENT_BACKEND',
    );
    if (useDevelopment) return development;
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    const legacyAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return BackendConfig(
      environment: AppEnvironment.production,
      provider: BackendProvider.supabase,
      supabaseUrl: url,
      supabasePublishableKey: key.isNotEmpty ? key : legacyAnonKey,
    );
  }

  static const development = BackendConfig(
    environment: AppEnvironment.development,
    provider: BackendProvider.localDevelopment,
  );
}
