enum ChapterState { completed, current, available, locked }

class WorldChapter {
  const WorldChapter({
    required this.id,
    required this.number,
    required this.title,
    required this.level,
    required this.durationMinutes,
    required this.vocabularyCount,
    required this.hasListening,
    required this.hasSpeaking,
    required this.state,
    this.isDownloaded = false,
    this.isPremium = false,
  });

  final String id;
  final int number;
  final String title;
  final String level;
  final int durationMinutes;
  final int vocabularyCount;
  final bool hasListening;
  final bool hasSpeaking;
  final ChapterState state;
  final bool isDownloaded;
  final bool isPremium;

  bool get isSelectable => state != ChapterState.locked;
}

const denizKralligiChapters = [
  WorldChapter(
    id: 'duygular',
    number: 1,
    title: 'Duygular',
    level: 'A1',
    durationMinutes: 12,
    vocabularyCount: 14,
    hasListening: true,
    hasSpeaking: true,
    state: ChapterState.completed,
    isDownloaded: true,
  ),
  WorldChapter(
    id: 'hava-durumu',
    number: 2,
    title: 'Hava Durumu',
    level: 'A1',
    durationMinutes: 15,
    vocabularyCount: 18,
    hasListening: true,
    hasSpeaking: true,
    state: ChapterState.current,
  ),
  WorldChapter(
    id: 'ulasim-araclari',
    number: 3,
    title: 'Ulaşım Araçları',
    level: 'A1',
    durationMinutes: 14,
    vocabularyCount: 16,
    hasListening: true,
    hasSpeaking: false,
    state: ChapterState.available,
  ),
  WorldChapter(
    id: 'yolculuk-hazirligi',
    number: 4,
    title: 'Yolculuk Hazırlığı',
    level: 'A1+',
    durationMinutes: 18,
    vocabularyCount: 20,
    hasListening: true,
    hasSpeaking: true,
    state: ChapterState.available,
  ),
  WorldChapter(
    id: 'seyahat-plani',
    number: 5,
    title: 'Seyahat Planı',
    level: 'A2',
    durationMinutes: 20,
    vocabularyCount: 22,
    hasListening: true,
    hasSpeaking: true,
    state: ChapterState.locked,
  ),
  WorldChapter(
    id: 'deniz-canlilari',
    number: 6,
    title: 'Deniz Canlıları',
    level: 'A2',
    durationMinutes: 16,
    vocabularyCount: 19,
    hasListening: true,
    hasSpeaking: true,
    state: ChapterState.locked,
  ),
];

WorldChapter? denizChapterById(String id) {
  for (final chapter in denizKralligiChapters) {
    if (chapter.id == id) return chapter;
  }
  return null;
}
