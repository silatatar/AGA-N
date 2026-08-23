import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/again_app.dart';
import 'core/backend/supabase_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseRuntime.initialize();
  runApp(const ProviderScope(child: AgainApp()));
}
