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
  const ConversationSession({
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
  });
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

  ConversationSession copyWith({
    List<ConversationMessage>? messages,
    List<String>? suggestions,
    int? turn,
    bool? isTyping,
    bool? isEnded,
    List<String>? corrections,
    List<String>? newWords,
    List<String>? strongExpressions,
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
