import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend_config.dart';

/// The single infrastructure boundary that owns the Supabase SDK client.
class SupabaseRuntime {
  SupabaseRuntime._();

  static BackendConfig config = BackendConfig.fromEnvironment();
  static SupabaseClient? _client;
  static SupabaseClient? get client => _client;

  static Future<void> initialize() async {
    if (!config.hasProductionBackend) return;
    final initialized = await Supabase.initialize(
      url: config.supabaseUrl!,
      publishableKey: config.supabasePublishableKey!,
    );
    _client = initialized.client;
  }
}
