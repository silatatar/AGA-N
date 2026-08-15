enum ConversationScenario {
  daily,
  cafe,
  directions,
  hotel,
  airport,
  meetingSomeone,
  jobInterview,
  freeTalk,
}

extension ConversationScenarioCopy on ConversationScenario {
  String get title => switch (this) {
    ConversationScenario.daily => 'Günlük sohbet',
    ConversationScenario.cafe => 'Kafede sipariş',
    ConversationScenario.directions => 'Yol tarifi',
    ConversationScenario.hotel => 'Otel',
    ConversationScenario.airport => 'Havalimanı',
    ConversationScenario.meetingSomeone => 'Yeni biriyle tanışma',
    ConversationScenario.jobInterview => 'İş görüşmesi',
    ConversationScenario.freeTalk => 'Serbest konuşma',
  };
}

enum ConversationMode { text, voice }

enum ConversationAuthor { user, huma, system }

enum HumaSafetyProfile { child, teen, adult }

enum HumaSafetyState { safe, needsBoundary, blocked }

enum CorrectionKind { incorrect, understandable, correct, moreNatural }

class HumaConversationTurn {
  const HumaConversationTurn({required this.author, required this.text});
  final ConversationAuthor author;
  final String text;
}

class HumaConversationRequest {
  const HumaConversationRequest({
    required this.userMessage,
    required this.learnerLevel,
    required this.learnerType,
    required this.scenario,
    required this.history,
    required this.safetyProfile,
    this.learningGoals = const {},
    this.targetVocabulary = const [],
    this.storyContext,
  });
  final String userMessage, learnerLevel, learnerType;
  final ConversationScenario scenario;
  final List<HumaConversationTurn> history;
  final Set<String> learningGoals;
  final List<String> targetVocabulary;
  final String? storyContext;
  final HumaSafetyProfile safetyProfile;
}

class HumaConversationResponse {
  const HumaConversationResponse({
    required this.assistantText,
    required this.suggestedReplies,
    required this.safetyState,
    this.translation,
    this.corrections = const [],
    this.vocabularySuggestions = const [],
    this.usefulExpressions = const [],
    this.explanation,
    this.sessionMetadata = const {},
  });
  final String assistantText;
  final String? translation, explanation;
  final List<String> suggestedReplies,
      corrections,
      vocabularySuggestions,
      usefulExpressions;
  final HumaSafetyState safetyState;
  final Map<String, String> sessionMetadata;
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.author,
    required this.text,
    this.translation,
    this.showTranslation = false,
    this.isCorrection = false,
  });
  final String id;
  final ConversationAuthor author;
  final String text;
  final String? translation;
  final bool showTranslation;
  final bool isCorrection;

  ConversationMessage copyWith({bool? showTranslation}) => ConversationMessage(
    id: id,
    author: author,
    text: text,
    translation: translation,
    showTranslation: showTranslation ?? this.showTranslation,
    isCorrection: isCorrection,
  );
}

class ConversationSession {
  ConversationSession({
    required this.scenario,
    required this.mode,
    required this.messages,
    required this.suggestions,
    required this.turn,
    this.isTyping = false,
    this.isEnded = false,
    this.corrections = const [],
    this.newWords = const [],
    this.strongExpressions = const [],
    DateTime? startedAt,
    this.targetVocabulary = const [],
    this.suggestedRepliesUsed = 0,
  }) : startedAt = startedAt ?? DateTime.now();
  final ConversationScenario scenario;
  final ConversationMode mode;
  final List<ConversationMessage> messages;
  final List<String> suggestions;
  final int turn;
  final bool isTyping;
  final bool isEnded;
  final List<String> corrections;
  final List<String> newWords;
  final List<String> strongExpressions;
  final DateTime startedAt;
  final List<String> targetVocabulary;
  final int suggestedRepliesUsed;

  ConversationSession copyWith({
    List<ConversationMessage>? messages,
    List<String>? suggestions,
    int? turn,
    bool? isTyping,
    bool? isEnded,
    List<String>? corrections,
    List<String>? newWords,
    List<String>? strongExpressions,
    int? suggestedRepliesUsed,
  }) => ConversationSession(
    scenario: scenario,
    mode: mode,
    messages: messages ?? this.messages,
    suggestions: suggestions ?? this.suggestions,
    turn: turn ?? this.turn,
    isTyping: isTyping ?? this.isTyping,
    isEnded: isEnded ?? this.isEnded,
    corrections: corrections ?? this.corrections,
    newWords: newWords ?? this.newWords,
    strongExpressions: strongExpressions ?? this.strongExpressions,
    startedAt: startedAt,
    targetVocabulary: targetVocabulary,
    suggestedRepliesUsed: suggestedRepliesUsed ?? this.suggestedRepliesUsed,
  );
}

class ConversationReply {
  const ConversationReply({
    required this.text,
    required this.translation,
    required this.suggestions,
    required this.newWords,
    required this.strongExpressions,
  });
  final String text;
  final String translation;
  final List<String> suggestions;
  final List<String> newWords;
  final List<String> strongExpressions;
}
