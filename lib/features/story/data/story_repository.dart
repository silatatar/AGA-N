import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/story_definition.dart';

abstract interface class StoryRepository {
  Future<StoryDefinition?> getStory(String id);
  Future<List<StoryDefinition>> getStoriesForWorld(String worldId);
  Future<List<StoryChapter>> getChaptersForWorld(String worldId);
}

class LocalStoryRepository implements StoryRepository {
  LocalStoryRepository({Map<String, StoryDefinition>? stories})
    : _stories = stories ?? localStories;
  final Map<String, StoryDefinition> _stories;
  @override
  Future<StoryDefinition?> getStory(String id) async => _stories[id];
  @override
  Future<List<StoryDefinition>> getStoriesForWorld(String id) async =>
      _stories.values.where((s) => s.worldId == id).toList();
  @override
  Future<List<StoryChapter>> getChaptersForWorld(String id) async =>
      (await getStoriesForWorld(id)).map((s) => s.chapter).toList();
}

const valley = StoryScene(id: 'valley', artKey: 'valley-dawn');
const harbour = StoryScene(
  id: 'harbour',
  artKey: 'storm-harbour',
  assetPath: 'assets/images/stories/deniz_kralligi/hava_durumu/scene_01.webp',
  semanticLabel: 'Deniz Krallığı limanına yaklaşan koyu fırtına bulutları.',
);
const helloWord = StoryVocabularyItem(
  id: 'hello',
  word: 'hello',
  pronunciation: '/həˈləʊ/',
  turkishMeaning: 'merhaba',
  englishDefinition: 'A greeting used when meeting someone.',
  example: 'Hello, I am Aslı.',
  storyContext: 'Yaşam Vadisi — İlk Karşılaşma',
);
const cloudyWord = StoryVocabularyItem(
  id: 'cloudy',
  word: 'cloudy',
  pronunciation: '/ˈklaʊ.di/',
  turkishMeaning: 'bulutlu',
  englishDefinition: 'Covered with clouds.',
  example: 'It is a cloudy morning.',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);
const rainWord = StoryVocabularyItem(
  id: 'rain',
  word: 'rain',
  pronunciation: '/reɪn/',
  turkishMeaning: 'yağmur',
  englishDefinition: 'Water that falls from clouds.',
  example: 'The rain is soft today.',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);

final localStories = <String, StoryDefinition>{
  'first-encounter': StoryDefinition(
    id: 'first-encounter',
    worldId: 'yasam-vadisi',
    chapter: const StoryChapter(
      id: 'first-encounter',
      number: 1,
      durationMinutes: 3,
      vocabularyCount: 1,
      hasListening: true,
      nextChapterId: 'hava-durumu',
    ),
    title: 'Yaşam Vadisi — İlk Karşılaşma',
    description: 'İlk kelimenle vadide bir iz bırak.',
    startNodeId: 'valley-intro',
    reward: const StoryReward(xp: 10, seedGrowth: 1),
    nodes: {
      'valley-intro': const StoryNode(
        id: 'valley-intro',
        scene: valley,
        kind: StoryNodeKind.narration,
        englishText: 'Welcome to the Valley of Life.',
        turkishExplanation: 'Burası Yaşam Vadisi.',
        nextNodeId: 'hello',
        speaker: 'Hüma',
      ),
      'hello': const StoryNode(
        id: 'hello',
        scene: valley,
        kind: StoryNodeKind.dialogue,
        englishText: 'Hello!',
        speaker: 'Hüma',
        vocabulary: [helloWord],
        listeningActivityId: 'first-hello-listening',
        nextNodeId: 'hello-choice',
      ),
      'hello-choice': const StoryNode(
        id: 'hello-choice',
        scene: valley,
        kind: StoryNodeKind.choice,
        englishText: 'How will you reply?',
        choices: [
          StoryChoice(
            id: 'reply-hello',
            label: 'Hello, Mira!',
            outcome: StoryOutcome(
              nextNodeId: 'valley-complete',
              feedback: 'Harika! İlk konuşman başladı.',
              isPreferred: true,
            ),
          ),
          StoryChoice(
            id: 'reply-hi',
            label: 'Hi!',
            outcome: StoryOutcome(
              nextNodeId: 'short-reply',
              feedback: 'Hi de sıcak ve doğal bir selamlamadır.',
            ),
          ),
        ],
      ),
      'warm-reply': const StoryNode(
        id: 'warm-reply',
        scene: valley,
        kind: StoryNodeKind.dialogue,
        englishText: 'Wonderful to meet you!',
        speaker: 'Hüma',
        nextNodeId: 'valley-complete',
      ),
      'short-reply': const StoryNode(
        id: 'short-reply',
        scene: valley,
        kind: StoryNodeKind.dialogue,
        englishText: 'Hi! Nice to meet you.',
        speaker: 'Hüma',
        nextNodeId: 'valley-complete',
      ),
      'valley-complete': const StoryNode(
        id: 'valley-complete',
        scene: valley,
        kind: StoryNodeKind.completion,
        englishText: 'Your first word has sprouted.',
        turkishExplanation: 'İlk kelimen filizlendi.',
      ),
    },
  ),
  'weather-storm': StoryDefinition(
    id: 'weather-storm',
    worldId: 'deniz-kralligi',
    chapter: const StoryChapter(
      id: 'hava-durumu',
      number: 2,
      durationMinutes: 15,
      vocabularyCount: 2,
      hasListening: true,
      nextChapterId: 'ulasim-araclari',
    ),
    title: 'Fırtına Öncesi',
    description: 'Hava değişirken Mira’ya yardım et.',
    startNodeId: 'clouds',
    reward: const StoryReward(xp: 25, seedGrowth: 1),
    nodes: {
      'clouds': const StoryNode(
        id: 'clouds',
        scene: harbour,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'The sky is cloudy, and rain is coming.',
        turkishExplanation: 'Gökyüzü bulutlu ve yağmur geliyor.',
        vocabulary: [cloudyWord, rainWord],
        listeningActivityId: 'weather-sentence',
        nextNodeId: 'umbrella-choice',
      ),
      'umbrella-choice': const StoryNode(
        id: 'umbrella-choice',
        scene: harbour,
        kind: StoryNodeKind.choice,
        englishText: 'What should Mira take?',
        choices: [
          StoryChoice(
            id: 'umbrella',
            label: 'Take an umbrella.',
            outcome: StoryOutcome(
              nextNodeId: 'safe-harbour',
              feedback: 'Bu ifade burada doğal ve hazırlıklı duyuluyor.',
              isPreferred: true,
            ),
          ),
          StoryChoice(
            id: 'sunglasses',
            label: 'Wear sunglasses.',
            outcome: StoryOutcome(
              nextNodeId: 'rainy-harbour',
              feedback: 'Havaya biraz daha dikkat edelim.',
            ),
          ),
        ],
      ),
      'safe-harbour': const StoryNode(
        id: 'safe-harbour',
        scene: harbour,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'Great idea! I will take my umbrella.',
        grammarNote:
            '“It is raining” yapısında is + fiil-ing, şu anda olan durumu anlatır.',
        humaHelp: 'Hava için “It is…” kalıbını kullanabilirsin.',
        nextNodeId: 'weather-writing',
      ),
      'rainy-harbour': const StoryNode(
        id: 'rainy-harbour',
        scene: harbour,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'Cloudy and rain are clues. An umbrella will help.',
        nextNodeId: 'weather-writing',
      ),
      'weather-writing': const StoryNode(
        id: 'weather-writing',
        scene: harbour,
        kind: StoryNodeKind.writing,
        englishText: 'Describe today’s weather in one English sentence.',
        writingPrompt: 'Bugünkü havayı İngilizce bir cümleyle anlat.',
        minimumWritingLength: 5,
        humaHelp:
            '“It is sunny/cloudy/raining today.” kalıbından başlayabilirsin.',
        nextNodeId: 'weather-speaking',
      ),
      'weather-speaking': const StoryNode(
        id: 'weather-speaking',
        scene: harbour,
        kind: StoryNodeKind.speaking,
        englishText: 'Say it aloud: It is cloudy today.',
        turkishExplanation: 'Sesli pratik yakında kullanılabilir olacak.',
        nextNodeId: 'weather-complete',
      ),
      'weather-complete': const StoryNode(
        id: 'weather-complete',
        scene: harbour,
        kind: StoryNodeKind.completion,
        englishText: 'The weather changed, and you progressed.',
        turkishExplanation: 'Hava değişti, sen ilerledin.',
      ),
    },
  ),
};

final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => LocalStoryRepository(),
);
