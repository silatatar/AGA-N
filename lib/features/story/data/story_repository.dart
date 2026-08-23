import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/story_catalog.dart';
import '../domain/story_definition.dart';
import 'deniz_kralligi_content.dart';
import 'sessiz_orman_content.dart';
import 'yasam_vadisi_content.dart';

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

final localStoryCatalog = StoryCatalog(localStories.values);

const firstEncounterCover = StoryVisualMetadata(
  assetPath: 'assets/images/stories/yasam_vadisi/ilk_karsilasma/cover_v1.webp',
  accessibilityDescription:
      'Altın şafakta zümrüt Yaşam Vadisi’ne uzanan taş patika.',
  alignmentY: -.18,
  overlayStrength: .5,
);
const valleyArrival = StoryScene(
  id: 'valley-arrival',
  artKey: 'valley-arrival-dawn',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/ilk_karsilasma/scene_arrival_v1.webp',
    accessibilityDescription:
        'Ağaç kemerinin altından Yaşam Vadisi’ne açılan taş patika.',
    alignmentY: -.12,
    overlayStrength: .5,
  ),
);
// Stable compatibility alias for existing content-validation fixtures.
const valley = valleyArrival;
const valleyMeeting = StoryScene(
  id: 'valley-meeting',
  artKey: 'valley-meeting-overlook',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/ilk_karsilasma/scene_meeting_v1.webp',
    accessibilityDescription:
        'Turkuaz derenin yanında ilk karşılaşma için aydınlanan taş meydan.',
    alignmentY: .12,
    overlayStrength: .58,
  ),
);
const harbour = StoryScene(
  id: 'harbour',
  artKey: 'storm-harbour',
  visual: StoryVisualMetadata(
    assetPath: 'assets/images/stories/deniz_kralligi/hava_durumu/scene_01.webp',
    accessibilityDescription:
        'Deniz Krallığı limanına yaklaşan koyu fırtına bulutları.',
  ),
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
const hiWord = StoryVocabularyItem(
  id: 'hi',
  word: 'hi',
  pronunciation: '',
  turkishMeaning: 'selam',
  englishDefinition: 'A short, friendly greeting.',
  example: 'Hi, I am Lina.',
  storyContext: 'Yaşam Vadisi — İlk Karşılaşma',
);
const myNameWord = StoryVocabularyItem(
  id: 'my-name-is',
  word: 'My name is',
  pronunciation: '',
  turkishMeaning: 'Benim adım',
  englishDefinition: 'Used to tell someone your name.',
  example: 'My name is Lina.',
  storyContext: 'Yaşam Vadisi — İlk Karşılaşma',
);
const niceToMeetWord = StoryVocabularyItem(
  id: 'nice-to-meet-you',
  word: 'Nice to meet you',
  pronunciation: '',
  turkishMeaning: 'Tanıştığımıza memnun oldum',
  englishDefinition: 'A friendly phrase used after an introduction.',
  example: 'Nice to meet you, Lina.',
  storyContext: 'Yaşam Vadisi — İlk Karşılaşma',
);
const yourNameWord = StoryVocabularyItem(
  id: 'what-is-your-name',
  word: 'What is your name?',
  pronunciation: '',
  turkishMeaning: 'Adın ne?',
  englishDefinition: 'A question used to ask a first name.',
  example: 'Hello. What is your name?',
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
const sunnyWord = StoryVocabularyItem(
  id: 'sunny',
  word: 'sunny',
  pronunciation: '',
  turkishMeaning: 'güneşli',
  englishDefinition: 'Bright with light from the sun.',
  example: 'It is sunny today.',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);
const windyWord = StoryVocabularyItem(
  id: 'windy',
  word: 'windy',
  pronunciation: '',
  turkishMeaning: 'rüzgârlı',
  englishDefinition: 'Having a lot of moving air.',
  example: 'The harbour is windy.',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);
const stormWord = StoryVocabularyItem(
  id: 'storm',
  word: 'storm',
  pronunciation: '',
  turkishMeaning: 'fırtına',
  englishDefinition: 'Very strong wind and rain.',
  example: 'A storm is coming.',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);
const weatherQuestionWord = StoryVocabularyItem(
  id: 'weather-question',
  word: 'What is the weather like?',
  pronunciation: '',
  turkishMeaning: 'Hava nasıl?',
  englishDefinition: 'A question used to ask about the weather.',
  example: 'What is the weather like today?',
  storyContext: 'Deniz Krallığı — Hava Durumu',
);

final localStories = <String, StoryDefinition>{
  ...yasamVadisiAdditionalStories,
  ...sessizOrmanStories,
  ...denizKralligiAdditionalStories,
  'first-encounter': StoryDefinition(
    id: 'first-encounter',
    worldId: 'yasam-vadisi',
    chapter: const StoryChapter(
      id: 'first-encounter',
      number: 1,
      durationMinutes: 3,
      vocabularyCount: 5,
      hasListening: true,
      nextChapterId: 'ben-kimim',
    ),
    title: 'Yaşam Vadisi — İlk Karşılaşma',
    description: 'İlk cümlelerinle vadide bir iz bırak.',
    startNodeId: 'valley-intro',
    reward: const StoryReward(xp: 10, seedGrowth: 1),
    catalogOrder: 1,
    coverVisual: firstEncounterCover,
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1,
      learningGoals: ['Selam vermek', 'Kendini basitçe tanıtmak'],
      grammarTargets: ['Hello / Hi', 'My name is…', 'I am…'],
      skillFocus: {StorySkill.listening, StorySkill.vocabulary},
      interestTags: {'daily-life', 'introductions'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'Hello!',
    ),
    nodes: {
      'valley-intro': const StoryNode(
        id: 'valley-intro',
        scene: valleyArrival,
        kind: StoryNodeKind.narration,
        englishText: 'Welcome to the Valley of Life.',
        turkishExplanation: 'Burası Yaşam Vadisi.',
        nextNodeId: 'hello',
        speaker: 'Hüma',
      ),
      'hello': const StoryNode(
        id: 'hello',
        scene: valleyMeeting,
        kind: StoryNodeKind.dialogue,
        englishText: 'Hello!',
        speaker: 'Hüma',
        vocabulary: [
          helloWord,
          hiWord,
          myNameWord,
          niceToMeetWord,
          yourNameWord,
        ],
        listeningActivityId: 'first-hello-listening',
        nextNodeId: 'introduction',
      ),
      'introduction': const StoryNode(
        id: 'introduction',
        scene: valleyMeeting,
        kind: StoryNodeKind.dialogue,
        englishText: 'My name is Hüma. What is your name?',
        turkishExplanation:
            'Hüma kendini tanıtıyor. Eğitim için yalnızca örnek bir ilk ad kullanabilirsin.',
        speaker: 'Hüma',
        nextNodeId: 'hello-choice',
      ),
      'hello-choice': const StoryNode(
        id: 'hello-choice',
        scene: valleyMeeting,
        kind: StoryNodeKind.choice,
        englishText: 'How will you reply?',
        choices: [
          StoryChoice(
            id: 'reply-hello',
            label: 'Hello! My name is Ada.',
            outcome: StoryOutcome(
              nextNodeId: 'warm-reply',
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
        scene: valleyMeeting,
        kind: StoryNodeKind.dialogue,
        englishText: 'Wonderful to meet you!',
        speaker: 'Hüma',
        nextNodeId: 'valley-complete',
      ),
      'short-reply': const StoryNode(
        id: 'short-reply',
        scene: valleyMeeting,
        kind: StoryNodeKind.dialogue,
        englishText: 'Hi! Nice to meet you.',
        speaker: 'Hüma',
        nextNodeId: 'valley-complete',
      ),
      'valley-complete': const StoryNode(
        id: 'valley-complete',
        scene: valleyMeeting,
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
      vocabularyCount: 6,
      hasListening: true,
      nextChapterId: 'ulasim-araclari',
      displayTitle: 'Hava Durumu',
    ),
    title: 'Fırtına Öncesi',
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/deniz_kralligi/hava_durumu/cover_v1.webp',
      accessibilityDescription:
          'Koyu akıntı bulutları yaklaşırken aydınlık kalan su altı limanı.',
      alignmentY: -.08,
      overlayStrength: .56,
    ),
    description: 'Hava değişirken Mira’ya yardım et.',
    startNodeId: 'clouds',
    reward: const StoryReward(xp: 25, seedGrowth: 1),
    catalogOrder: 2,
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1,
      learningGoals: [
        'Basit hava durumunu anlamak',
        'Hava durumunu tarif etmek',
      ],
      grammarTargets: ['It is + weather adjective', 'Present continuous'],
      skillFocus: {
        StorySkill.listening,
        StorySkill.writing,
        StorySkill.vocabulary,
      },
      interestTags: {'travel', 'weather'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'It is cloudy today.',
    ),
    nodes: {
      'clouds': const StoryNode(
        id: 'clouds',
        scene: harbour,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'The sky is cloudy, and rain is coming.',
        turkishExplanation: 'Gökyüzü bulutlu ve yağmur geliyor.',
        vocabulary: [
          cloudyWord,
          rainWord,
          sunnyWord,
          windyWord,
          stormWord,
          weatherQuestionWord,
        ],
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
