import '../domain/story_definition.dart';

const _gate = StoryScene(
  id: 'sea-gate',
  artKey: 'sea-kingdom-gate',
  visual: StoryVisualMetadata(
    assetPath: 'assets/images/stories/deniz_kralligi/duygular/scene_01_v1.webp',
    accessibilityDescription:
        'Açık krallık kapısının ardında ışıldayan sakin su altı meydanı.',
    alignmentY: -.08,
    overlayStrength: .57,
  ),
);
const _station = StoryScene(
  id: 'sea-station',
  artKey: 'sea-kingdom-station',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/deniz_kralligi/ulasim_araclari/scene_01_v1.webp',
    accessibilityDescription:
        'Sakin kanal, boş tekne iskelesi ve mavi rayları olan su altı istasyonu.',
    alignmentY: .08,
    overlayStrength: .6,
  ),
);
const _room = StoryScene(
  id: 'travel-room',
  artKey: 'sea-kingdom-travel-room',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/deniz_kralligi/yolculuk_hazirligi/scene_01_v1.webp',
    accessibilityDescription:
        'Çanta, mont, şişe, boş harita ve liste bulunan sakin hazırlık odası.',
    alignmentY: .16,
    overlayStrength: .64,
  ),
);

StoryVocabularyItem _word(
  String id,
  String word,
  String meaning,
  String definition,
  String example,
  String story,
) => StoryVocabularyItem(
  id: id,
  word: word,
  pronunciation: '',
  turkishMeaning: meaning,
  englishDefinition: definition,
  example: example,
  storyContext: 'Deniz Krallığı — $story',
);

final denizKralligiAdditionalStories = <String, StoryDefinition>{
  'duygular': StoryDefinition(
    id: 'duygular',
    worldId: 'deniz-kralligi',
    catalogOrder: 1,
    chapter: const StoryChapter(
      id: 'duygular',
      number: 1,
      durationMinutes: 7,
      vocabularyCount: 6,
      hasListening: true,
      nextChapterId: 'hava-durumu',
    ),
    title: 'Duygular',
    coverVisual: const StoryVisualMetadata(
      assetPath: 'assets/images/stories/deniz_kralligi/duygular/cover_v1.webp',
      accessibilityDescription:
          'Işıklı su altı meydanına açılan görkemli Deniz Krallığı kapısı.',
      alignmentY: -.1,
      overlayStrength: .53,
    ),
    description: 'Deniz Krallığı’nın kapısında basit duyguları paylaş.',
    startNodeId: 'kingdom-arrival',
    reward: const StoryReward(xp: 16, seedGrowth: 1),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1,
      learningGoals: [
        'Basit duyguları söylemek',
        'Birinin nasıl hissettiğini sormak',
      ],
      grammarTargets: ['I am + feeling', 'How do you feel?'],
      skillFocus: {
        StorySkill.vocabulary,
        StorySkill.reading,
        StorySkill.listening,
      },
      interestTags: {'feelings', 'travel'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'I am excited.',
    ),
    nodes: {
      'kingdom-arrival': StoryNode(
        id: 'kingdom-arrival',
        scene: _gate,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText:
            'Welcome to the Sea Kingdom! How do you feel about our journey?',
        turkishExplanation:
            'Bu yalnızca İngilizce duygu sözcükleri için bir hikâye seçimi.',
        vocabulary: [
          _word(
            'how-feel',
            'How do you feel?',
            'Nasıl hissediyorsun?',
            'A simple question about a feeling.',
            'How do you feel today?',
            'Duygular',
          ),
          _word(
            'happy',
            'happy',
            'mutlu',
            'Feeling pleased or glad.',
            'I am happy.',
            'Duygular',
          ),
          _word(
            'excited',
            'excited',
            'heyecanlı',
            'Feeling happy and full of energy.',
            'I am excited about the journey.',
            'Duygular',
          ),
          _word(
            'nervous',
            'nervous',
            'gergin, heyecanlı',
            'A little worried about something new.',
            'I am a little nervous.',
            'Duygular',
          ),
          _word(
            'tired',
            'tired',
            'yorgun',
            'Needing rest.',
            'I am tired after the trip.',
            'Duygular',
          ),
          _word(
            'worried',
            'worried',
            'endişeli',
            'Thinking that something may be wrong.',
            'Mira is worried about the weather.',
            'Duygular',
          ),
        ],
        nextNodeId: 'feeling-choice',
      ),
      'feeling-choice': const StoryNode(
        id: 'feeling-choice',
        scene: _gate,
        kind: StoryNodeKind.choice,
        englishText: 'Choose a practice sentence.',
        choices: [
          StoryChoice(
            id: 'excited',
            label: 'I am excited.',
            outcome: StoryOutcome(
              nextNodeId: 'excited-reaction',
              feedback: 'Mira yolculuk heyecanını paylaşıyor.',
            ),
          ),
          StoryChoice(
            id: 'nervous',
            label: 'I am a little nervous.',
            outcome: StoryOutcome(
              nextNodeId: 'nervous-reaction',
              feedback:
                  'Hüma yeni yerlerde yavaş ilerleyebileceğinizi hatırlatıyor.',
            ),
          ),
          StoryChoice(
            id: 'happy',
            label: 'I am happy.',
            outcome: StoryOutcome(
              nextNodeId: 'happy-reaction',
              feedback: 'Krallığın kapıları sıcak bir ışıkla açılıyor.',
            ),
          ),
        ],
      ),
      'excited-reaction': const StoryNode(
        id: 'excited-reaction',
        scene: _gate,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'Me too! A new journey is beginning.',
        nextNodeId: 'feelings-complete',
      ),
      'nervous-reaction': const StoryNode(
        id: 'nervous-reaction',
        scene: _gate,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'That is okay. We can explore one step at a time.',
        nextNodeId: 'feelings-complete',
      ),
      'happy-reaction': const StoryNode(
        id: 'happy-reaction',
        scene: _gate,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'I am happy you are here.',
        nextNodeId: 'feelings-complete',
      ),
      'feelings-complete': const StoryNode(
        id: 'feelings-complete',
        scene: _gate,
        kind: StoryNodeKind.completion,
        englishText: 'A clear feeling opened the kingdom gate.',
        turkishExplanation: 'Basit duygu cümlelerini kullandın.',
      ),
    },
  ),
  'ulasim-araclari': StoryDefinition(
    id: 'ulasim-araclari',
    worldId: 'deniz-kralligi',
    catalogOrder: 3,
    chapter: const StoryChapter(
      id: 'ulasim-araclari',
      number: 3,
      durationMinutes: 9,
      vocabularyCount: 8,
      hasListening: true,
      nextChapterId: 'yolculuk-hazirligi',
    ),
    title: 'Ulaşım Araçları',
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/deniz_kralligi/ulasim_araclari/cover_v1.webp',
      accessibilityDescription:
          'Tekne kanalı ile mavi rayların yan yana uzandığı su altı istasyonu.',
      alignmentY: .08,
      overlayStrength: .58,
    ),
    description: 'Hava açılırken krallıkta nasıl yolculuk edeceğini seç.',
    startNodeId: 'station-arrival',
    reward: const StoryReward(xp: 20, seedGrowth: 1),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1Plus,
      learningGoals: [
        'Temel ulaşım araçlarını söylemek',
        'Nasıl gidileceğini seçmek',
      ],
      grammarTargets: ['go by…', 'We can take…'],
      skillFocus: {
        StorySkill.vocabulary,
        StorySkill.reading,
        StorySkill.listening,
      },
      interestTags: {'travel', 'transport'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'Let us go by boat.',
    ),
    nodes: {
      'station-arrival': StoryNode(
        id: 'station-arrival',
        scene: _station,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText:
            'The weather is clear. We can travel to the blue island now.',
        vocabulary: [
          _word(
            'boat',
            'boat',
            'tekne',
            'A small vehicle that travels on water.',
            'We can take a boat.',
            'Ulaşım Araçları',
          ),
          _word(
            'ship',
            'ship',
            'gemi',
            'A large vehicle that travels on water.',
            'The ship is in the harbour.',
            'Ulaşım Araçları',
          ),
          _word(
            'train',
            'train',
            'tren',
            'A vehicle that travels on rails.',
            'The train leaves the station.',
            'Ulaşım Araçları',
          ),
          _word(
            'bus',
            'bus',
            'otobüs',
            'A large road vehicle for many people.',
            'We go by bus.',
            'Ulaşım Araçları',
          ),
          _word(
            'station',
            'station',
            'istasyon',
            'A place where buses or trains stop.',
            'Meet me at the station.',
            'Ulaşım Araçları',
          ),
          _word(
            'ticket',
            'ticket',
            'bilet',
            'A pass used for a journey.',
            'I have a train ticket.',
            'Ulaşım Araçları',
          ),
          _word(
            'travel',
            'travel',
            'seyahat etmek',
            'To go from one place to another.',
            'We travel to the island.',
            'Ulaşım Araçları',
          ),
          _word(
            'island',
            'island',
            'ada',
            'Land surrounded by water.',
            'The island is across the sea.',
            'Ulaşım Araçları',
          ),
        ],
        nextNodeId: 'transport-choice',
      ),
      'transport-choice': const StoryNode(
        id: 'transport-choice',
        scene: _station,
        kind: StoryNodeKind.choice,
        englishText: 'How should we travel?',
        choices: [
          StoryChoice(
            id: 'boat',
            label: 'Let’s go by boat.',
            outcome: StoryOutcome(
              nextNodeId: 'boat-reaction',
              feedback: 'Tekne sakin kanaldan adaya doğru ilerliyor.',
            ),
          ),
          StoryChoice(
            id: 'train',
            label: 'Let’s go by train.',
            outcome: StoryOutcome(
              nextNodeId: 'train-reaction',
              feedback: 'Mavi tren kıyı boyunca uzanan raylara giriyor.',
            ),
          ),
        ],
      ),
      'boat-reaction': const StoryNode(
        id: 'boat-reaction',
        scene: _station,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'The boat is small, but it can cross the quiet channel.',
        nextNodeId: 'transport-complete',
      ),
      'train-reaction': const StoryNode(
        id: 'train-reaction',
        scene: _station,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'The train is fast, and the sea view is beautiful.',
        nextNodeId: 'transport-complete',
      ),
      'transport-complete': const StoryNode(
        id: 'transport-complete',
        scene: _station,
        kind: StoryNodeKind.completion,
        englishText: 'Your travel choice set the journey in motion.',
        turkishExplanation:
            'Ulaşım seçimini doğal bir İngilizce cümleyle yaptın.',
      ),
    },
  ),
  'yolculuk-hazirligi': StoryDefinition(
    id: 'yolculuk-hazirligi',
    worldId: 'deniz-kralligi',
    catalogOrder: 4,
    chapter: const StoryChapter(
      id: 'yolculuk-hazirligi',
      number: 4,
      durationMinutes: 10,
      vocabularyCount: 8,
      hasListening: true,
    ),
    title: 'Yolculuk Hazırlığı',
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/deniz_kralligi/yolculuk_hazirligi/cover_v1.webp',
      accessibilityDescription:
          'Pencere önünde açık çanta, mont, şişe, boş harita ve hazırlık listesi.',
      alignmentY: .16,
      overlayStrength: .62,
    ),
    description: 'Mira ile yeni yolculuk için basit eşyaları hazırla.',
    startNodeId: 'packing-start',
    reward: const StoryReward(xp: 22, seedGrowth: 1),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1Plus,
      learningGoals: [
        'Temel yolculuk eşyalarını söylemek',
        'İhtiyaç ve sahiplik bildirmek',
      ],
      grammarTargets: ['I need…', 'I have…', 'Do you have…?'],
      skillFocus: {
        StorySkill.vocabulary,
        StorySkill.writing,
        StorySkill.reading,
      },
      interestTags: {'travel', 'preparation'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'I need a map.',
    ),
    nodes: {
      'packing-start': StoryNode(
        id: 'packing-start',
        scene: _room,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText:
            'Our next journey begins tomorrow. We need a few simple things.',
        turkishExplanation:
            'Bu kurgu yolculuğunda gerçek kimlik veya belge bilgisi istenmez.',
        vocabulary: [
          _word(
            'bag',
            'bag',
            'çanta',
            'A container used to carry things.',
            'My map is in the bag.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'map',
            'map',
            'harita',
            'A picture that shows places and routes.',
            'I need a map.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'water',
            'water',
            'su',
            'A clear drink needed by people and animals.',
            'We need water.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'coat',
            'coat',
            'mont',
            'Warm clothing worn over other clothes.',
            'I have a warm coat.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'need',
            'need',
            'ihtiyaç duymak',
            'To require something.',
            'I need a ticket.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'have',
            'have',
            'sahip olmak',
            'To own or carry something.',
            'I have a map.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'bottle',
            'bottle',
            'şişe',
            'A container for liquids.',
            'The water bottle is full.',
            'Yolculuk Hazırlığı',
          ),
          _word(
            'list',
            'list',
            'liste',
            'A group of written items.',
            'Our travel list is short.',
            'Yolculuk Hazırlığı',
          ),
        ],
        nextNodeId: 'packing-choice',
      ),
      'packing-choice': const StoryNode(
        id: 'packing-choice',
        scene: _room,
        kind: StoryNodeKind.choice,
        englishText: 'The sky may be rainy. What do we need first?',
        choices: [
          StoryChoice(
            id: 'coat',
            label: 'We need a coat.',
            outcome: StoryOutcome(
              nextNodeId: 'coat-reaction',
              feedback: 'Mont yağmurlu hava için çantaya ekleniyor.',
            ),
          ),
          StoryChoice(
            id: 'map',
            label: 'We need a map.',
            outcome: StoryOutcome(
              nextNodeId: 'map-reaction',
              feedback: 'Harita adadaki güvenli yolu gösteriyor.',
            ),
          ),
        ],
      ),
      'coat-reaction': const StoryNode(
        id: 'coat-reaction',
        scene: _room,
        kind: StoryNodeKind.dialogue,
        speaker: 'Mira',
        englishText: 'Good idea. I have a warm coat for the rain.',
        nextNodeId: 'packing-writing',
      ),
      'map-reaction': const StoryNode(
        id: 'map-reaction',
        scene: _room,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'Good idea. The map shows our island path.',
        nextNodeId: 'packing-writing',
      ),
      'packing-writing': const StoryNode(
        id: 'packing-writing',
        scene: _room,
        kind: StoryNodeKind.writing,
        englishText: 'Write one thing you need for a trip.',
        writingPrompt: '“I need…” ile kısa bir cümle yaz.',
        minimumWritingLength: 7,
        nextNodeId: 'packing-complete',
      ),
      'packing-complete': const StoryNode(
        id: 'packing-complete',
        scene: _room,
        kind: StoryNodeKind.completion,
        englishText: 'The travel bag is ready for a new chapter.',
        turkishExplanation: 'Yolculuk ihtiyacını açık bir cümleyle anlattın.',
      ),
    },
  ),
};
