import 'dart:io';

String temporaryVoicePath(String sessionId) {
  final safeId = sessionId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return '${Directory.systemTemp.path}${Platform.pathSeparator}again_$safeId.m4a';
}
