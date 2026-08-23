import '../../learner_profile/domain/learner_type.dart';

class StoryDefinition {
  const StoryDefinition({
    required this.id,
    required this.worldId,
    required this.chapter,
    required this.title,
    required this.description,
    required this.startNodeId,
    required this.nodes,
    required this.reward,
    this.learning,
    this.catalogOrder = 0,
    this.allowedLearnerTypes = LearnerType.values,
    this.minimumLevel = 1,
    this.maximumLevel,
    this.tags = const {},
    this.toneVariantKey,
    this.coverVisual,
  });
  final String id, worldId, title, description, startNodeId;
  final StoryChapter chapter;
  final Map<String, StoryNode> nodes;
  final StoryReward reward;
  final StoryLearningMetadata? learning;
  final int catalogOrder;
  final List<LearnerType> allowedLearnerTypes;
  final int minimumLevel;
  final int? maximumLevel;
  final Set<String> tags;
  final String? toneVariantKey;
  final StoryVisualMetadata? coverVisual;
  bool isEligible(LearnerType type, int level) =>
      allowedLearnerTypes.contains(type) &&
      level >= minimumLevel &&
      (maximumLevel == null || level <= maximumLevel!);
}

enum CefrLevel { a1, a1Plus, a2 }

enum StorySkill { reading, listening, writing, speaking, vocabulary, grammar }

class StoryLearningMetadata {
  const StoryLearningMetadata({
    required this.cefr,
    required this.learningGoals,
    required this.grammarTargets,
    required this.skillFocus,
    this.interestTags = const {},
    this.ttsEligible = false,
    this.slowReplayAllowed = false,
    this.expectedSpeakingPhrase,
    this.locale = 'en-US',
  });

  final CefrLevel cefr;
  final List<String> learningGoals;
  final List<String> grammarTargets;
  final Set<StorySkill> skillFocus;
  final Set<String> interestTags;
  final bool ttsEligible, slowReplayAllowed;
  final String? expectedSpeakingPhrase;
  final String locale;
}

class StoryChapter {
  const StoryChapter({
    required this.id,
    required this.number,
    required this.durationMinutes,
    required this.vocabularyCount,
    this.hasListening = false,
    this.hasSpeaking = false,
    this.nextChapterId,
    this.displayTitle,
  });
  final String id;
  final int number, durationMinutes, vocabularyCount;
  final bool hasListening, hasSpeaking;
  final String? nextChapterId;
  final String? displayTitle;
}

enum StoryNodeKind {
  narration,
  dialogue,
  choice,
  writing,
  speaking,
  completion,
}

class StoryNode {
  const StoryNode({
    required this.id,
    required this.scene,
    required this.kind,
    required this.englishText,
    this.turkishExplanation,
    this.speaker,
    this.vocabulary = const [],
    this.choices = const [],
    this.nextNodeId,
    this.listeningActivityId,
    this.speakingActivityId,
    this.grammarNote,
    this.writingPrompt,
    this.minimumWritingLength = 3,
    this.humaHelp,
  });
  final String id;
  final StoryScene scene;
  final StoryNodeKind kind;
  final String englishText;
  final String? turkishExplanation,
      speaker,
      nextNodeId,
      listeningActivityId,
      speakingActivityId;
  final String? grammarNote, writingPrompt, humaHelp;
  final int minimumWritingLength;
  final List<StoryVocabularyItem> vocabulary;
  final List<StoryChoice> choices;
}

class StoryScene {
  const StoryScene({
    required this.id,
    required this.artKey,
    this.atmosphere = const {},
    this.visual,
  });
  final String id, artKey;
  final StoryVisualMetadata? visual;
  final Map<String, String> atmosphere;
}

class StoryVisualMetadata {
  const StoryVisualMetadata({
    required this.assetPath,
    required this.accessibilityDescription,
    this.alignmentX = 0,
    this.alignmentY = 0,
    this.overlayStrength = .48,
  }) : assert(alignmentX >= -1 && alignmentX <= 1),
       assert(alignmentY >= -1 && alignmentY <= 1),
       assert(overlayStrength >= 0 && overlayStrength <= 1);

  final String assetPath;
  final String accessibilityDescription;
  final double alignmentX, alignmentY, overlayStrength;
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.label,
    required this.outcome,
  });
  final String id, label;
  final StoryOutcome outcome;
}

class StoryOutcome {
  const StoryOutcome({
    required this.nextNodeId,
    required this.feedback,
    this.isPreferred = false,
  });
  final String nextNodeId, feedback;
  final bool isPreferred;
}

class StoryVocabularyItem {
  const StoryVocabularyItem({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.turkishMeaning,
    required this.englishDefinition,
    required this.example,
    required this.storyContext,
  });
  final String id,
      word,
      pronunciation,
      turkishMeaning,
      englishDefinition,
      example,
      storyContext;
}

class StoryReward {
  const StoryReward({required this.xp, this.seedGrowth = 0});
  final int xp, seedGrowth;
}

class StorySessionState {
  const StorySessionState({
    required this.storyId,
    required this.currentNodeId,
    this.visitedNodeIds = const [],
    this.selectedChoices = const {},
    this.wordsDiscovered = const {},
    this.wordsSaved = const {},
    this.listeningActivitiesCompleted = const {},
    this.sessionXp = 0,
    this.isComplete = false,
    this.feedback,
    this.writingResponses = const {},
  });
  final String storyId, currentNodeId;
  final List<String> visitedNodeIds;
  final Map<String, String> selectedChoices;
  final Set<String> wordsDiscovered, wordsSaved, listeningActivitiesCompleted;
  final int sessionXp;
  final bool isComplete;
  final String? feedback;
  final Map<String, String> writingResponses;
  StorySessionState copyWith({
    String? currentNodeId,
    List<String>? visitedNodeIds,
    Map<String, String>? selectedChoices,
    Set<String>? wordsDiscovered,
    Set<String>? wordsSaved,
    Set<String>? listeningActivitiesCompleted,
    int? sessionXp,
    bool? isComplete,
    String? feedback,
    Map<String, String>? writingResponses,
  }) => StorySessionState(
    storyId: storyId,
    currentNodeId: currentNodeId ?? this.currentNodeId,
    visitedNodeIds: visitedNodeIds ?? this.visitedNodeIds,
    selectedChoices: selectedChoices ?? this.selectedChoices,
    wordsDiscovered: wordsDiscovered ?? this.wordsDiscovered,
    wordsSaved: wordsSaved ?? this.wordsSaved,
    listeningActivitiesCompleted:
        listeningActivitiesCompleted ?? this.listeningActivitiesCompleted,
    sessionXp: sessionXp ?? this.sessionXp,
    isComplete: isComplete ?? this.isComplete,
    feedback: feedback,
    writingResponses: writingResponses ?? this.writingResponses,
  );
}

class StoryValidationResult {
  const StoryValidationResult(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

StoryValidationResult validateStoryDefinition(StoryDefinition story) {
  final errors = <String>[];
  if (!story.nodes.containsKey(story.startNodeId)) {
    errors.add('missing-start-node');
  }
  for (final entry in story.nodes.entries) {
    final node = entry.value;
    if (entry.key != node.id) errors.add('node-id-mismatch:${entry.key}');
    if (node.nextNodeId != null && !story.nodes.containsKey(node.nextNodeId)) {
      errors.add('invalid-next:${node.id}');
    }
    for (final choice in node.choices) {
      if (!story.nodes.containsKey(choice.outcome.nextNodeId)) {
        errors.add('broken-choice:${node.id}:${choice.id}');
      }
    }
    final vocabularyIds = <String>{};
    for (final word in node.vocabulary) {
      if (word.id.isEmpty || !vocabularyIds.add(word.id)) {
        errors.add('invalid-vocabulary:${node.id}');
      }
    }
  }
  if (errors.isEmpty) {
    final reachable = <String>{};
    void visit(String id) {
      if (!reachable.add(id)) return;
      final node = story.nodes[id]!;
      if (node.nextNodeId != null) visit(node.nextNodeId!);
      for (final choice in node.choices) {
        visit(choice.outcome.nextNodeId);
      }
    }

    visit(story.startNodeId);
    if (!reachable.any(
      (id) => story.nodes[id]!.kind == StoryNodeKind.completion,
    )) {
      errors.add('unreachable-completion');
    }
  }
  return StoryValidationResult(errors);
}
