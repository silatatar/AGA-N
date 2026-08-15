enum WordMastery { newWord, learning, familiar, mastered }

enum VocabularyGrowthState { seed, sprout, young, blooming, mastered }

extension VocabularyGrowth on VocabularyEntry {
  VocabularyGrowthState get growthState {
    if (mastery == WordMastery.mastered) return VocabularyGrowthState.mastered;
    if (mastery == WordMastery.familiar) return VocabularyGrowthState.blooming;
    if (successfulReviewCount >= 2) return VocabularyGrowthState.young;
    if (successfulReviewCount >= 1) return VocabularyGrowthState.sprout;
    return VocabularyGrowthState.seed;
  }

  int get plantVariant =>
      id.codeUnits.fold<int>(0, (sum, code) => sum + code) % 4;
}

enum ReviewMode {
  meaningRecall,
  sentenceCompletion,
  listeningRecognition,
  matching,
  useInSentence,
}

extension ReviewModeCopy on ReviewMode {
  String get title => switch (this) {
    ReviewMode.meaningRecall => 'Anlamı Hatırla',
    ReviewMode.sentenceCompletion => 'Cümleyi Tamamla',
    ReviewMode.listeningRecognition => 'Dinleyerek Tanı',
    ReviewMode.matching => 'Eşleştirme',
    ReviewMode.useInSentence => 'Cümlede Kullan',
  };
}

class VocabularyEntry {
  const VocabularyEntry({
    required this.id,
    required this.word,
    required this.turkishMeaning,
    required this.englishDefinition,
    required this.pronunciation,
    required this.exampleSentence,
    required this.storyContext,
    required this.storyTitle,
    required this.mastery,
    required this.reviewCount,
    required this.correctStreak,
    required this.intervalDays,
    required this.nextReviewAt,
    this.isFavorite = false,
    this.isDifficult = false,
    this.userExample,
    this.lastReviewMode,
    DateTime? discoveredAt,
    this.lastReviewedAt,
    this.successfulReviewCount = 0,
    this.worldId,
    this.storyId,
    this.worldTitle,
  }) : discoveredAt = discoveredAt ?? nextReviewAt;

  final String id;
  final String word;
  final String turkishMeaning;
  final String englishDefinition;
  final String pronunciation;
  final String exampleSentence;
  final String storyContext;
  final String storyTitle;
  final WordMastery mastery;
  final int reviewCount;
  final int correctStreak;
  final int intervalDays;
  final DateTime nextReviewAt;
  final bool isFavorite;
  final bool isDifficult;
  final String? userExample;
  final ReviewMode? lastReviewMode;
  final DateTime discoveredAt;
  final DateTime? lastReviewedAt;
  final int successfulReviewCount;
  final String? worldId, storyId, worldTitle;

  bool get isDue => !nextReviewAt.isAfter(DateTime.now());

  VocabularyEntry copyWith({
    WordMastery? mastery,
    int? reviewCount,
    int? correctStreak,
    int? intervalDays,
    DateTime? nextReviewAt,
    bool? isFavorite,
    bool? isDifficult,
    String? userExample,
    ReviewMode? lastReviewMode,
    DateTime? discoveredAt,
    DateTime? lastReviewedAt,
    int? successfulReviewCount,
    String? worldId,
    String? storyId,
    String? worldTitle,
  }) => VocabularyEntry(
    id: id,
    word: word,
    turkishMeaning: turkishMeaning,
    englishDefinition: englishDefinition,
    pronunciation: pronunciation,
    exampleSentence: exampleSentence,
    storyContext: storyContext,
    storyTitle: storyTitle,
    mastery: mastery ?? this.mastery,
    reviewCount: reviewCount ?? this.reviewCount,
    correctStreak: correctStreak ?? this.correctStreak,
    intervalDays: intervalDays ?? this.intervalDays,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    isFavorite: isFavorite ?? this.isFavorite,
    isDifficult: isDifficult ?? this.isDifficult,
    userExample: userExample ?? this.userExample,
    lastReviewMode: lastReviewMode ?? this.lastReviewMode,
    discoveredAt: discoveredAt ?? this.discoveredAt,
    lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    successfulReviewCount: successfulReviewCount ?? this.successfulReviewCount,
    worldId: worldId ?? this.worldId,
    storyId: storyId ?? this.storyId,
    worldTitle: worldTitle ?? this.worldTitle,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'turkishMeaning': turkishMeaning,
    'englishDefinition': englishDefinition,
    'pronunciation': pronunciation,
    'exampleSentence': exampleSentence,
    'storyContext': storyContext,
    'storyTitle': storyTitle,
    'mastery': mastery.name,
    'reviewCount': reviewCount,
    'correctStreak': correctStreak,
    'intervalDays': intervalDays,
    'nextReviewAt': nextReviewAt.toIso8601String(),
    'isFavorite': isFavorite,
    'isDifficult': isDifficult,
    'userExample': userExample,
    'lastReviewMode': lastReviewMode?.name,
    'discoveredAt': discoveredAt.toIso8601String(),
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    'successfulReviewCount': successfulReviewCount,
    'worldId': worldId,
    'storyId': storyId,
    'worldTitle': worldTitle,
  };

  factory VocabularyEntry.fromJson(
    Map<String, dynamic> json,
  ) => VocabularyEntry(
    id: json['id'] as String,
    word: json['word'] as String,
    turkishMeaning: json['turkishMeaning'] as String,
    englishDefinition: json['englishDefinition'] as String? ?? '',
    pronunciation: json['pronunciation'] as String? ?? '',
    exampleSentence: json['exampleSentence'] as String? ?? '',
    storyContext: json['storyContext'] as String? ?? '',
    storyTitle: json['storyTitle'] as String? ?? 'Bilinmeyen hikâye',
    mastery: WordMastery.values.byName(json['mastery'] as String? ?? 'newWord'),
    reviewCount: json['reviewCount'] as int? ?? 0,
    correctStreak: json['correctStreak'] as int? ?? 0,
    intervalDays: json['intervalDays'] as int? ?? 0,
    nextReviewAt:
        DateTime.tryParse(json['nextReviewAt'] as String? ?? '') ??
        DateTime.now(),
    isFavorite: json['isFavorite'] as bool? ?? false,
    isDifficult: json['isDifficult'] as bool? ?? false,
    userExample: json['userExample'] as String?,
    lastReviewMode: json['lastReviewMode'] == null
        ? null
        : ReviewMode.values.byName(json['lastReviewMode'] as String),
    discoveredAt: DateTime.tryParse(json['discoveredAt'] as String? ?? ''),
    lastReviewedAt: DateTime.tryParse(json['lastReviewedAt'] as String? ?? ''),
    successfulReviewCount:
        json['successfulReviewCount'] as int? ??
        (json['correctStreak'] as int? ?? 0),
    worldId: json['worldId'] as String?,
    storyId: json['storyId'] as String?,
    worldTitle: json['worldTitle'] as String?,
  );
}

VocabularyEntry applyVocabularyReview({
  required VocabularyEntry entry,
  required ReviewMode mode,
  required bool correct,
  required DateTime reviewedAt,
}) {
  final streak = correct ? entry.correctStreak + 1 : 0;
  final successfulReviews = entry.successfulReviewCount + (correct ? 1 : 0);
  final interval = correct ? const [1, 3, 7, 14][streak.clamp(1, 4) - 1] : 0;
  final mastery = !correct
      ? WordMastery.learning
      : streak >= 4
      ? WordMastery.mastered
      : streak >= 2
      ? WordMastery.familiar
      : WordMastery.learning;
  return entry.copyWith(
    mastery: mastery,
    reviewCount: entry.reviewCount + 1,
    successfulReviewCount: successfulReviews,
    correctStreak: streak,
    intervalDays: interval,
    lastReviewedAt: reviewedAt,
    nextReviewAt: correct
        ? reviewedAt.add(Duration(days: interval))
        : reviewedAt.add(const Duration(hours: 6)),
    isDifficult: correct ? entry.isDifficult : true,
    lastReviewMode: mode,
  );
}

VocabularyEntry vocabularyTemplate(
  String word, {
  String? id,
  String? turkishMeaning,
  String? englishDefinition,
  String? pronunciation,
  String? exampleSentence,
  String? storyContext,
  String? storyTitle,
  String? worldId,
  String? storyId,
  String? worldTitle,
  DateTime? now,
}) {
  final data = switch (word.toLowerCase()) {
    'cloudy' => (
      'bulutlu',
      'Covered with clouds.',
      '/ˈklaʊ.di/',
      'It is a cloudy morning.',
    ),
    'coming' => (
      'geliyor',
      'Moving or happening toward now.',
      '/ˈkʌm.ɪŋ/',
      'A storm is coming.',
    ),
    _ => (
      'yağmur',
      'Water that falls from clouds.',
      '/reɪn/',
      'The rain is soft today.',
    ),
  };
  return VocabularyEntry(
    id: id ?? word.toLowerCase(),
    word: word.toLowerCase(),
    turkishMeaning: turkishMeaning ?? data.$1,
    englishDefinition: englishDefinition ?? data.$2,
    pronunciation: pronunciation ?? data.$3,
    exampleSentence: exampleSentence ?? data.$4,
    storyContext: storyContext ?? 'The sky is cloudy, and rain is coming.',
    storyTitle: storyTitle ?? 'Deniz Krallığı — Hava Durumu',
    mastery: WordMastery.newWord,
    reviewCount: 0,
    correctStreak: 0,
    intervalDays: 0,
    nextReviewAt: now ?? DateTime.now(),
    discoveredAt: now ?? DateTime.now(),
    worldId: worldId ?? 'deniz-kralligi',
    storyId: storyId ?? 'weather-story',
    worldTitle: worldTitle ?? 'Deniz Krallığı',
  );
}
