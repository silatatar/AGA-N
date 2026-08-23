abstract final class VoiceProgressPolicy {
  static const double listeningCompletionThreshold = 0.8;

  static bool listeningCompleted({
    required bool playbackActuallyStarted,
    required int playedMilliseconds,
    required int totalMilliseconds,
  }) {
    if (!playbackActuallyStarted ||
        playedMilliseconds <= 0 ||
        totalMilliseconds <= 0) {
      return false;
    }
    return playedMilliseconds / totalMilliseconds >=
        listeningCompletionThreshold;
  }

  static int speakingSecondsFromRecording({
    required bool recorderActuallyStarted,
    required bool testAdapter,
    required int durationMilliseconds,
  }) {
    if (!recorderActuallyStarted || testAdapter || durationMilliseconds <= 0) {
      return 0;
    }
    return durationMilliseconds ~/ Duration.millisecondsPerSecond;
  }
}

class SpeakingDurationAccumulator {
  int _milliseconds = 0;

  int get totalMilliseconds => _milliseconds;
  int get completedSeconds => _milliseconds ~/ Duration.millisecondsPerSecond;
  double get displayMinutes => _milliseconds / Duration.millisecondsPerMinute;

  void addActualRecording({
    required bool recorderActuallyStarted,
    required bool testAdapter,
    required int durationMilliseconds,
  }) {
    if (!recorderActuallyStarted || testAdapter || durationMilliseconds <= 0) {
      return;
    }
    _milliseconds += durationMilliseconds;
  }
}
