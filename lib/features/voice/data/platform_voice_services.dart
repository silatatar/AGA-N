import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt_error;
import 'package:speech_to_text/speech_recognition_result.dart' as stt_result;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../domain/voice_models.dart';
import '../domain/voice_services.dart';
import 'temporary_voice_path.dart';
import 'unconfigured_voice_services.dart';

class PlatformVoiceRecorderService implements VoiceRecorderService {
  PlatformVoiceRecorderService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final Stopwatch _elapsed = Stopwatch();
  VoiceRecordingSession? _current;

  static const configuration = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 64000,
    sampleRate: 16000,
    numChannels: 1,
    autoGain: true,
    echoCancel: true,
    noiseSuppress: true,
  );

  @override
  Future<MicrophonePermissionState> getPermissionState() async {
    try {
      return await _recorder.hasPermission(request: false)
          ? MicrophonePermissionState.granted
          : MicrophonePermissionState.unknown;
    } catch (_) {
      return MicrophonePermissionState.unsupported;
    }
  }

  @override
  Future<MicrophonePermissionState> requestPermission() async {
    try {
      return await _recorder.hasPermission()
          ? MicrophonePermissionState.granted
          : MicrophonePermissionState.denied;
    } catch (_) {
      return MicrophonePermissionState.unsupported;
    }
  }

  @override
  Future<VoiceRecordingSession> startRecording({
    required String sessionId,
    required String ownerId,
    required VoiceSourceContext sourceContext,
  }) async {
    if (_current?.state == VoiceRecordingState.recording) {
      return _failure(
        sessionId,
        ownerId,
        sourceContext,
        VoiceFailureKind.interrupted,
      );
    }
    if (await getPermissionState() != MicrophonePermissionState.granted) {
      return _failure(
        sessionId,
        ownerId,
        sourceContext,
        VoiceFailureKind.permissionDenied,
      );
    }
    try {
      final path = temporaryVoicePath(sessionId);
      await _recorder.start(configuration, path: path);
      _elapsed
        ..reset()
        ..start();
      return _current = VoiceRecordingSession(
        sessionId: sessionId,
        ownerId: ownerId,
        state: VoiceRecordingState.recording,
        sourceContext: sourceContext,
        startedAt: DateTime.now().toUtc(),
        temporaryRecordingReference: path,
      );
    } catch (_) {
      return _failure(
        sessionId,
        ownerId,
        sourceContext,
        VoiceFailureKind.providerUnavailable,
      );
    }
  }

  @override
  Future<VoiceRecordingSession> stopRecording() async {
    final current = _current;
    if (current == null || current.state != VoiceRecordingState.recording) {
      throw const VoiceServiceUnavailable(VoiceFailureKind.interrupted);
    }
    try {
      final path = await _recorder.stop();
      _elapsed.stop();
      return _current = VoiceRecordingSession(
        sessionId: current.sessionId,
        ownerId: current.ownerId,
        state: VoiceRecordingState.completed,
        sourceContext: current.sourceContext,
        startedAt: current.startedAt,
        endedAt: DateTime.now().toUtc(),
        durationMilliseconds: _elapsed.elapsedMilliseconds,
        temporaryRecordingReference:
            path ?? current.temporaryRecordingReference,
      );
    } catch (_) {
      throw const VoiceServiceUnavailable(VoiceFailureKind.providerUnavailable);
    }
  }

  @override
  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } finally {
      _elapsed
        ..stop()
        ..reset();
      _current = null;
    }
  }

  @override
  Future<void> dispose() async {
    if (_current?.state == VoiceRecordingState.recording) {
      await cancelRecording();
    }
    await _recorder.dispose();
  }

  VoiceRecordingSession _failure(
    String sessionId,
    String ownerId,
    VoiceSourceContext sourceContext,
    VoiceFailureKind failure,
  ) => VoiceRecordingSession(
    sessionId: sessionId,
    ownerId: ownerId,
    state: VoiceRecordingState.error,
    sourceContext: sourceContext,
    failure: failure,
  );
}

class PlatformTextToSpeechService implements TextToSpeechService {
  PlatformTextToSpeechService({FlutterTts? engine})
    : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  VoiceAvailability _availability = VoiceAvailability.unconfigured;
  String? _englishLanguage;

  @override
  VoiceAvailability get availability => _availability;

  Future<VoiceAvailability> initialize() async {
    try {
      final rawLanguages = await _engine.getLanguages;
      final languages = rawLanguages is List
          ? rawLanguages.whereType<Object>().map((e) => e.toString()).toList()
          : const <String>[];
      _englishLanguage = languages
          .where((language) => language.toLowerCase().startsWith('en'))
          .firstOrNull;
      if (_englishLanguage == null) {
        return _availability = VoiceAvailability.unsupportedPlatform;
      }
      await _engine.awaitSpeakCompletion(true);
      await _engine.setLanguage(_englishLanguage!);
      await _engine.setPitch(1.0);
      return _availability = VoiceAvailability.available;
    } catch (_) {
      return _availability = VoiceAvailability.temporarilyUnavailable;
    }
  }

  @override
  Future<void> speak(TextToSpeechRequest request) async {
    if (_availability != VoiceAvailability.available ||
        _englishLanguage == null) {
      throw const VoiceServiceUnavailable(VoiceFailureKind.unconfigured);
    }
    final completion = Completer<void>();
    _engine.setCompletionHandler(() {
      if (!completion.isCompleted) completion.complete();
    });
    _engine.setCancelHandler(() {
      if (!completion.isCompleted) {
        completion.completeError(
          const VoiceServiceUnavailable(VoiceFailureKind.interrupted),
        );
      }
    });
    _engine.setErrorHandler((_) {
      if (!completion.isCompleted) {
        completion.completeError(
          const VoiceServiceUnavailable(VoiceFailureKind.providerUnavailable),
        );
      }
    });
    await _engine.setSpeechRate(
      request.speed == EducationalSpeechSpeed.slow ? 0.34 : 0.47,
    );
    final result = await _engine.speak(request.text);
    if (result != 1 && !completion.isCompleted) {
      throw const VoiceServiceUnavailable(VoiceFailureKind.providerUnavailable);
    }
    await completion.future;
  }

  @override
  Future<void> stop() async {
    await _engine.stop();
  }
}

/// Live, explicit, short-utterance recognition only.
///
/// `speech_to_text` owns the microphone during this flow. It does not consume
/// files produced by [PlatformVoiceRecorderService], so recorded-audio
/// transcription remains intentionally unsupported.
class PlatformSpeechToTextService implements LiveSpeechToTextService {
  PlatformSpeechToTextService({
    stt.SpeechToText? recognizer,
    this.preferredEnglishLocale = 'en-US',
  }) : _recognizer = recognizer ?? stt.SpeechToText();

  final stt.SpeechToText _recognizer;
  final String preferredEnglishLocale;
  VoiceAvailability _availability = VoiceAvailability.unconfigured;
  String? _selectedLocale;
  Completer<SpeechRecognitionResult>? _active;
  stt_result.SpeechRecognitionResult? _lastResult;
  VoiceFailureKind? _lastFailure;

  @override
  VoiceAvailability get availability => _availability;
  @override
  String? get selectedLocale => _selectedLocale;

  @override
  Future<VoiceAvailability> initialize({bool requestPermission = false}) async {
    if (_availability == VoiceAvailability.available) return _availability;
    try {
      if (!requestPermission && !await _recognizer.hasPermission) {
        return _availability = VoiceAvailability.permissionRequired;
      }
      final initialized = await _recognizer.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        finalTimeout: const Duration(seconds: 2),
      );
      if (!initialized) {
        return _availability = VoiceAvailability.permissionDenied;
      }
      final locales = await _recognizer.locales();
      final english = locales
          .where((locale) => locale.localeId.toLowerCase().startsWith('en'))
          .toList();
      if (english.isEmpty) {
        return _availability = VoiceAvailability.unsupportedPlatform;
      }
      final preferred = english.where(
        (locale) =>
            locale.localeId.toLowerCase() ==
            preferredEnglishLocale.toLowerCase(),
      );
      if (preferred.isNotEmpty) {
        _selectedLocale = preferred.first.localeId;
      } else {
        final system = await _recognizer.systemLocale();
        final systemEnglish = english.where(
          (locale) => locale.localeId == system?.localeId,
        );
        _selectedLocale = systemEnglish.isNotEmpty
            ? systemEnglish.first.localeId
            : english.first.localeId;
      }
      return _availability = VoiceAvailability.available;
    } catch (_) {
      return _availability = VoiceAvailability.temporarilyUnavailable;
    }
  }

  @override
  Future<SpeechRecognitionResult> transcribe(
    SpeechRecognitionRequest request,
  ) async {
    if (request.mode != SpeechRecognitionMode.liveShortUtterance) {
      return const SpeechRecognitionResult.failure(
        VoiceFailureKind.unconfigured,
      );
    }
    if (_availability != VoiceAvailability.available ||
        _selectedLocale == null) {
      return const SpeechRecognitionResult.failure(
        VoiceFailureKind.providerUnavailable,
      );
    }
    if (_active != null) {
      return const SpeechRecognitionResult.failure(
        VoiceFailureKind.interrupted,
      );
    }

    _lastResult = null;
    _lastFailure = null;
    final completer = Completer<SpeechRecognitionResult>();
    _active = completer;
    try {
      await _recognizer.listen(
        onResult: _handleResult,
        listenOptions: stt.SpeechListenOptions(
          localeId: _selectedLocale,
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
      request.onStarted?.call();
      return await completer.future.timeout(
        const Duration(seconds: 16),
        onTimeout: () async {
          await _recognizer.cancel();
          return const SpeechRecognitionResult.failure(
            VoiceFailureKind.timeout,
          );
        },
      );
    } catch (_) {
      return SpeechRecognitionResult.failure(
        _lastFailure ?? VoiceFailureKind.providerUnavailable,
      );
    } finally {
      _active = null;
      _lastResult = null;
      _lastFailure = null;
    }
  }

  @override
  Future<void> stop() => _recognizer.stop();
  @override
  Future<void> cancel() => _recognizer.cancel();

  @override
  Future<void> dispose() async {
    await _recognizer.cancel();
    _active = null;
  }

  void _handleResult(stt_result.SpeechRecognitionResult result) {
    _lastResult = result;
    if (result.finalResult) _completeFromLastResult();
  }

  void _handleStatus(String status) {
    if ((status == stt.SpeechToText.doneStatus ||
            status == stt.SpeechToText.notListeningStatus) &&
        _active != null) {
      _completeFromLastResult();
    }
  }

  void _handleError(stt_error.SpeechRecognitionError error) {
    final message = error.errorMsg.toLowerCase();
    _lastFailure = message.contains('permission')
        ? VoiceFailureKind.permissionDenied
        : message.contains('timeout') || message.contains('no_match')
        ? VoiceFailureKind.timeout
        : VoiceFailureKind.providerUnavailable;
    final active = _active;
    if (active != null && !active.isCompleted) {
      active.complete(SpeechRecognitionResult.failure(_lastFailure!));
    }
  }

  void _completeFromLastResult() {
    final active = _active;
    if (active == null || active.isCompleted) return;
    final result = _lastResult;
    final transcript = result?.recognizedWords.trim() ?? '';
    if (transcript.isEmpty) {
      active.complete(
        const SpeechRecognitionResult.failure(VoiceFailureKind.emptyTranscript),
      );
      return;
    }
    final alternatives = result!.alternates
        .map((value) => value.recognizedWords.trim())
        .where((value) => value.isNotEmpty && value != transcript)
        .toSet()
        .toList();
    active.complete(
      SpeechRecognitionResult.success(
        transcript: transcript,
        alternatives: alternatives,
        confidence: result.hasConfidenceRating ? result.confidence : null,
        detectedLocale: _selectedLocale,
      ),
    );
  }
}
