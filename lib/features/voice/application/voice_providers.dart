import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/platform_voice_services.dart';
import '../domain/voice_models.dart';

class VoicePlatformRuntime {
  VoicePlatformRuntime({
    required this.recorder,
    required this.speechToText,
    required this.textToSpeech,
    required this.capabilities,
  });

  final PlatformVoiceRecorderService recorder;
  final PlatformSpeechToTextService speechToText;
  final PlatformTextToSpeechService textToSpeech;
  final VoiceCapabilities capabilities;

  static Future<VoicePlatformRuntime> bootstrap() async {
    final recorder = PlatformVoiceRecorderService();
    final speechToText = PlatformSpeechToTextService();
    final textToSpeech = PlatformTextToSpeechService();

    final microphonePermission = await recorder.getPermissionState();
    final sttAvailability = await speechToText.initialize(
      requestPermission: false,
    );
    final ttsAvailability = await textToSpeech.initialize();
    final microphoneAvailability = switch (microphonePermission) {
      MicrophonePermissionState.granted => VoiceAvailability.available,
      MicrophonePermissionState.denied => VoiceAvailability.permissionDenied,
      MicrophonePermissionState.permanentlyDenied =>
        VoiceAvailability.permanentlyDenied,
      MicrophonePermissionState.unsupported =>
        VoiceAvailability.unsupportedPlatform,
      _ => VoiceAvailability.permissionRequired,
    };

    return VoicePlatformRuntime(
      recorder: recorder,
      speechToText: speechToText,
      textToSpeech: textToSpeech,
      capabilities: VoiceCapabilities(
        microphoneRecording: microphoneAvailability,
        speechToText: sttAvailability,
        textToSpeech: ttsAvailability,
        pronunciationAssessment: VoiceAvailability.unconfigured,
      ),
    );
  }

  Future<void> dispose() async {
    await speechToText.dispose();
    await textToSpeech.stop();
    await recorder.dispose();
  }
}

final voicePlatformRuntimeProvider = FutureProvider<VoicePlatformRuntime>((
  ref,
) async {
  final runtime = await VoicePlatformRuntime.bootstrap();
  ref.onDispose(() => unawaited(runtime.dispose()));
  return runtime;
});

final voiceCapabilitiesProvider = Provider<VoiceCapabilities>((ref) {
  return ref.watch(voicePlatformRuntimeProvider).value?.capabilities ??
      VoiceCapabilities.unconfigured;
});
