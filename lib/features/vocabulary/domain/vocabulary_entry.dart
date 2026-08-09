enum WordMastery { newWord, learning, familiar, mastered }

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
  });

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
  };

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) =>
      VocabularyEntry(
        id: json['id'] as String,
        word: json['word'] as String,
        turkishMeaning: json['turkishMeaning'] as String,
        englishDefinition: json['englishDefinition'] as String,
        pronunciation: json['pronunciation'] as String,
        exampleSentence: json['exampleSentence'] as String,
        storyContext: json['storyContext'] as String,
        storyTitle: json['storyTitle'] as String,
        mastery: WordMastery.values.byName(json['mastery'] as String),
        reviewCount: json['reviewCount'] as int,
        correctStreak: json['correctStreak'] as int,
        intervalDays: json['intervalDays'] as int,
        nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
        isDifficult: json['isDifficult'] as bool? ?? false,
        userExample: json['userExample'] as String?,
        lastReviewMode: json['lastReviewMode'] == null
            ? null
            : ReviewMode.values.byName(json['lastReviewMode'] as String),
      );
}

VocabularyEntry vocabularyTemplate(String word) {
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
    id: word.toLowerCase(),
    word: word.toLowerCase(),
    turkishMeaning: data.$1,
    englishDefinition: data.$2,
    pronunciation: data.$3,
    exampleSentence: data.$4,
    storyContext: 'The sky is cloudy, and rain is coming.',
    storyTitle: 'Deniz Krallığı — Hava Durumu',
    mastery: WordMastery.newWord,
    reviewCount: 0,
    correctStreak: 0,
    intervalDays: 0,
    nextReviewAt: DateTime.now(),
  );
}
