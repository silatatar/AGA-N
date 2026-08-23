import '../../progression/domain/again_progress.dart';
import '../../story/domain/story_catalog.dart';

enum ChapterState { completed, current, available, locked, comingSoon }

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
    this.hasPlayableContent = false,
    this.isDownloaded = false,
    this.isPremium = false,
    this.coverAsset,
    this.coverAlignmentX = 0,
    this.coverAlignmentY = 0,
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
  final bool hasPlayableContent;
  final String? coverAsset;
  final double coverAlignmentX, coverAlignmentY;

  bool get isSelectable =>
      hasPlayableContent &&
      state != ChapterState.locked &&
      state != ChapterState.comingSoon;
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
    state: ChapterState.comingSoon,
    hasPlayableContent: true,
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
    hasPlayableContent: true,
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
    state: ChapterState.comingSoon,
    hasPlayableContent: true,
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
    state: ChapterState.comingSoon,
    hasPlayableContent: true,
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
    state: ChapterState.comingSoon,
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
    state: ChapterState.comingSoon,
  ),
];

WorldChapter? denizChapterById(String id) {
  for (final chapter in denizKralligiChapters) {
    if (chapter.id == id) return chapter;
  }
  return null;
}

List<WorldChapter> denizChaptersFrom(AgainProgress progress) => [
  for (final chapter in denizKralligiChapters)
    WorldChapter(
      id: chapter.id,
      number: chapter.number,
      title: chapter.title,
      level: chapter.level,
      durationMinutes: chapter.durationMinutes,
      vocabularyCount: chapter.vocabularyCount,
      hasListening: chapter.hasListening,
      hasSpeaking: chapter.hasSpeaking,
      isDownloaded: chapter.isDownloaded,
      isPremium: chapter.isPremium,
      hasPlayableContent: chapter.hasPlayableContent,
      state: !chapter.hasPlayableContent
          ? ChapterState.comingSoon
          : progress.completedChapterIds.contains(chapter.id)
          ? ChapterState.completed
          : progress.currentChapterId == chapter.id
          ? ChapterState.current
          : progress.unlockedChapterIds.contains(chapter.id)
          ? ChapterState.available
          : ChapterState.locked,
    ),
];

List<WorldChapter> catalogChaptersForWorld(
  StoryCatalog catalog,
  String worldId,
  AgainProgress progress,
) => [
  for (final story in catalog.byWorld(worldId))
    WorldChapter(
      id: story.chapter.id,
      number: story.chapter.number,
      title:
          story.chapter.displayTitle ??
          (story.title.contains('—')
              ? story.title.split('—').last.trim()
              : story.title),
      level: switch (story.learning?.cefr.name) {
        'a1Plus' => 'A1+',
        'a2' => 'A2',
        _ => 'A1',
      },
      durationMinutes: story.chapter.durationMinutes,
      vocabularyCount: story.chapter.vocabularyCount,
      hasListening: story.chapter.hasListening,
      hasSpeaking: story.chapter.hasSpeaking,
      hasPlayableContent: true,
      coverAsset: story.coverVisual?.assetPath,
      coverAlignmentX: story.coverVisual?.alignmentX ?? 0,
      coverAlignmentY: story.coverVisual?.alignmentY ?? 0,
      state: progress.completedChapterIds.contains(story.chapter.id)
          ? ChapterState.completed
          : progress.currentChapterId == story.chapter.id
          ? ChapterState.current
          : progress.unlockedChapterIds.contains(story.chapter.id)
          ? ChapterState.available
          : ChapterState.locked,
    ),
];
