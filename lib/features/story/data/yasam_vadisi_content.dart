import '../domain/story_definition.dart';

const _benKimimScene = StoryScene(
  id: 'ben-kimim-reflection',
  artKey: 'valley-reflection-pool',
  visual: StoryVisualMetadata(
    assetPath: 'assets/images/stories/yasam_vadisi/ben_kimim/scene_01_v1.webp',
    accessibilityDescription:
        'Turkuaz yansıma havuzunun yanındaki sakin çayır ve taş oturma alanı.',
    alignmentY: .08,
    overlayStrength: .55,
  ),
);
const _gunlukHayatScene = StoryScene(
  id: 'gunluk-hayat-village',
  artKey: 'valley-morning-routine',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/gunluk_hayat/scene_01_v1.webp',
    accessibilityDescription:
        'Sabah ışığında kahvaltı masası, su değirmeni ve köy yolu.',
    alignmentY: .12,
    overlayStrength: .6,
  ),
);
const _sevdigimScene = StoryScene(
  id: 'sevdigim-seyler-garden',
  artKey: 'valley-preference-garden',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/sevdigim_seyler/scene_01_v1.webp',
    accessibilityDescription:
        'Müzik, oyun ve bahçe yollarını buluşturan zarif piknik alanı.',
    alignmentY: .18,
    overlayStrength: .62,
  ),
);
const _kucukGunMorningScene = StoryScene(
  id: 'kucuk-gun-morning',
  artKey: 'valley-small-day-morning',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/kucuk_bir_gun/scene_morning_v1.webp',
    accessibilityDescription:
        'Güne açılan ev kapısı, kahvaltı masası ve vadiye uzanan sabah yolu.',
    alignmentY: .14,
    overlayStrength: .58,
  ),
);
const _kucukGunFinaleScene = StoryScene(
  id: 'kucuk-gun-finale',
  artKey: 'valley-small-day-finale',
  visual: StoryVisualMetadata(
    assetPath:
        'assets/images/stories/yasam_vadisi/kucuk_bir_gun/scene_finale_v1.webp',
    accessibilityDescription:
        'Akşam ışığında vadiye bakan çayır, taş yol ve uzaktaki köy.',
    alignmentY: -.08,
    overlayStrength: .54,
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
  storyContext: 'Yaşam Vadisi — $story',
);

final yasamVadisiAdditionalStories = <String, StoryDefinition>{
  'ben-kimim': StoryDefinition(
    id: 'ben-kimim',
    worldId: 'yasam-vadisi',
    catalogOrder: 2,
    chapter: const StoryChapter(
      id: 'ben-kimim',
      number: 2,
      durationMinutes: 7,
      vocabularyCount: 6,
      hasListening: true,
      nextChapterId: 'gunluk-hayat',
    ),
    title: 'Ben Kimim?',
    description: 'Vadide yeni bir arkadaşla sevdiğin şeyleri paylaş.',
    startNodeId: 'meet-lina',
    reward: const StoryReward(xp: 15, seedGrowth: 1),
    coverVisual: const StoryVisualMetadata(
      assetPath: 'assets/images/stories/yasam_vadisi/ben_kimim/cover_v1.webp',
      accessibilityDescription:
          'Yaşam Vadisi’ne bakan turkuaz havuz ve iki taş oturma yeri.',
      alignmentY: .1,
      overlayStrength: .52,
    ),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1,
      learningGoals: [
        'Kendini basit cümlelerle anlatmak',
        'Sevdiğin bir şeyi söylemek',
      ],
      grammarTargets: ['I am…', 'I like…', "I don't like…"],
      skillFocus: {
        StorySkill.vocabulary,
        StorySkill.writing,
        StorySkill.reading,
      },
      interestTags: {'introductions', 'daily-life'},
      ttsEligible: true,
      slowReplayAllowed: true,
      expectedSpeakingPhrase: 'I like music.',
    ),
    nodes: {
      'meet-lina': StoryNode(
        id: 'meet-lina',
        scene: _benKimimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Hi! I am Lina. What do you like?',
        turkishExplanation: 'Lina sevdiğin bir şeyi soruyor.',
        vocabulary: [
          _word(
            'i-am',
            'I am',
            'Ben…im',
            'Used to say who you are.',
            'I am Lina.',
            'Ben Kimim?',
          ),
          _word(
            'i-like',
            'I like',
            'Severim',
            'Used for something you enjoy.',
            'I like music.',
            'Ben Kimim?',
          ),
          _word(
            'music',
            'music',
            'müzik',
            'Sounds arranged as songs.',
            'I like music.',
            'Ben Kimim?',
          ),
          _word(
            'animals',
            'animals',
            'hayvanlar',
            'Living creatures such as birds or cats.',
            'I like animals.',
            'Ben Kimim?',
          ),
          _word(
            'favourite',
            'favourite',
            'en sevdiğim',
            'Liked more than the others.',
            'My favourite colour is blue.',
            'Ben Kimim?',
          ),
          _word(
            'dont-like',
            "I don't like",
            'Sevmem',
            'Used for something you do not enjoy.',
            "I don't like loud noise.",
            'Ben Kimim?',
          ),
        ],
        nextNodeId: 'like-choice',
      ),
      'like-choice': const StoryNode(
        id: 'like-choice',
        scene: _benKimimScene,
        kind: StoryNodeKind.choice,
        englishText: 'What do you like?',
        choices: [
          StoryChoice(
            id: 'music',
            label: 'I like music.',
            outcome: StoryOutcome(
              nextNodeId: 'music-reaction',
              feedback: 'Lina da müziği seviyor.',
            ),
          ),
          StoryChoice(
            id: 'animals',
            label: 'I like animals.',
            outcome: StoryOutcome(
              nextNodeId: 'animal-reaction',
              feedback: 'Yakındaki kuşlar cevabına eşlik ediyor.',
            ),
          ),
        ],
      ),
      'music-reaction': const StoryNode(
        id: 'music-reaction',
        scene: _benKimimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Me too! My favourite song is gentle and bright.',
        nextNodeId: 'write-like',
      ),
      'animal-reaction': const StoryNode(
        id: 'animal-reaction',
        scene: _benKimimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Me too! The valley birds are my friends.',
        nextNodeId: 'write-like',
      ),
      'write-like': const StoryNode(
        id: 'write-like',
        scene: _benKimimScene,
        kind: StoryNodeKind.writing,
        englishText: 'Write one short sentence about something you like.',
        writingPrompt: '“I like…” ile kısa bir cümle yaz.',
        minimumWritingLength: 6,
        grammarNote:
            '“I like + isim” sevdiğin bir şeyi söylemek için kullanılır.',
        nextNodeId: 'identity-complete',
      ),
      'identity-complete': const StoryNode(
        id: 'identity-complete',
        scene: _benKimimScene,
        kind: StoryNodeKind.completion,
        englishText: 'Your voice has a place in the valley.',
        turkishExplanation: 'Vadide kendinden bir iz bıraktın.',
      ),
    },
  ),
  'gunluk-hayat': StoryDefinition(
    id: 'gunluk-hayat',
    worldId: 'yasam-vadisi',
    catalogOrder: 3,
    chapter: const StoryChapter(
      id: 'gunluk-hayat',
      number: 3,
      durationMinutes: 8,
      vocabularyCount: 7,
      hasListening: true,
      nextChapterId: 'sevdigim-seyler',
    ),
    title: 'Günlük Hayat',
    description: 'Vadide sabah başlayan küçük bir günü takip et.',
    startNodeId: 'morning',
    reward: const StoryReward(xp: 18, seedGrowth: 1),
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/yasam_vadisi/gunluk_hayat/cover_v1.webp',
      accessibilityDescription:
          'Sabah güneşiyle uyanan köy, su değirmeni ve kahvaltı terası.',
      alignmentY: .08,
      overlayStrength: .55,
    ),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1,
      learningGoals: [
        'Temel günlük rutinleri anlamak',
        'Olayları doğal sıraya koymak',
      ],
      grammarTargets: ['Simple Present with I'],
      skillFocus: {
        StorySkill.vocabulary,
        StorySkill.grammar,
        StorySkill.listening,
      },
      interestTags: {'daily-life', 'routine'},
      ttsEligible: true,
      slowReplayAllowed: true,
    ),
    nodes: {
      'morning': StoryNode(
        id: 'morning',
        scene: _gunlukHayatScene,
        kind: StoryNodeKind.narration,
        englishText: 'Morning arrives. Lina wakes up and eats breakfast.',
        turkishExplanation: 'Vadide sabah başlıyor.',
        vocabulary: [
          _word(
            'morning',
            'morning',
            'sabah',
            'The early part of the day.',
            'Good morning!',
            'Günlük Hayat',
          ),
          _word(
            'wake-up',
            'wake up',
            'uyanmak',
            'To stop sleeping.',
            'I wake up early.',
            'Günlük Hayat',
          ),
          _word(
            'breakfast',
            'breakfast',
            'kahvaltı',
            'The first meal of the day.',
            'I eat breakfast.',
            'Günlük Hayat',
          ),
          _word(
            'go',
            'go',
            'gitmek',
            'To move to another place.',
            'I go to school.',
            'Günlük Hayat',
          ),
          _word(
            'home',
            'home',
            'ev',
            'The place where you live.',
            'I come home.',
            'Günlük Hayat',
          ),
          _word(
            'evening',
            'evening',
            'akşam',
            'The later part of the day.',
            'I read in the evening.',
            'Günlük Hayat',
          ),
          _word(
            'sleep',
            'sleep',
            'uyumak',
            'To rest with your eyes closed.',
            'I sleep at night.',
            'Günlük Hayat',
          ),
        ],
        nextNodeId: 'routine-choice',
      ),
      'routine-choice': const StoryNode(
        id: 'routine-choice',
        scene: _gunlukHayatScene,
        kind: StoryNodeKind.choice,
        englishText: 'What usually comes after waking up?',
        choices: [
          StoryChoice(
            id: 'breakfast',
            label: 'I eat breakfast.',
            outcome: StoryOutcome(
              nextNodeId: 'natural-order',
              feedback: 'Bu, güne doğal bir başlangıç. ',
              isPreferred: true,
            ),
          ),
          StoryChoice(
            id: 'home',
            label: 'I come home.',
            outcome: StoryOutcome(
              nextNodeId: 'gentle-order',
              feedback: 'Bu genellikle günün daha sonraki kısmında olur.',
            ),
          ),
        ],
      ),
      'natural-order': const StoryNode(
        id: 'natural-order',
        scene: _gunlukHayatScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'Yes. I wake up, and then I eat breakfast.',
        grammarNote: 'Simple Present, düzenli yaptığın şeyleri anlatır.',
        nextNodeId: 'day-complete',
      ),
      'gentle-order': const StoryNode(
        id: 'gentle-order',
        scene: _gunlukHayatScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'Coming home is later. First, we can eat breakfast.',
        nextNodeId: 'day-complete',
      ),
      'day-complete': const StoryNode(
        id: 'day-complete',
        scene: _gunlukHayatScene,
        kind: StoryNodeKind.completion,
        englishText: 'The valley day now has a rhythm.',
        turkishExplanation: 'Günün doğal ritmini keşfettin.',
      ),
    },
  ),
  'sevdigim-seyler': StoryDefinition(
    id: 'sevdigim-seyler',
    worldId: 'yasam-vadisi',
    catalogOrder: 4,
    chapter: const StoryChapter(
      id: 'sevdigim-seyler',
      number: 4,
      durationMinutes: 8,
      vocabularyCount: 7,
      hasListening: true,
      nextChapterId: 'kucuk-bir-gun',
    ),
    title: 'Sevdiğim Şeyler',
    description: 'Vadideki piknikte tercihlerini paylaş.',
    startNodeId: 'picnic-start',
    reward: const StoryReward(xp: 18, seedGrowth: 1),
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/yasam_vadisi/sevdigim_seyler/cover_v1.webp',
      accessibilityDescription:
          'Müzik, taş oyunu ve çiçek yollarıyla hazırlanan vadi pikniği.',
      alignmentY: .15,
      overlayStrength: .58,
    ),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1Plus,
      learningGoals: [
        'Basit tercih soruları sormak',
        'Sevdiğin etkinliği söylemek',
      ],
      grammarTargets: ['Do you like…?', 'Yes, I do. / No, I don’t.'],
      skillFocus: {
        StorySkill.reading,
        StorySkill.vocabulary,
        StorySkill.listening,
      },
      interestTags: {'hobbies', 'daily-life'},
      ttsEligible: true,
      slowReplayAllowed: true,
    ),
    nodes: {
      'picnic-start': StoryNode(
        id: 'picnic-start',
        scene: _sevdigimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Welcome to our picnic! What would you like to do?',
        vocabulary: [
          _word(
            'do-you-like',
            'Do you like…?',
            '… sever misin?',
            'A question about preference.',
            'Do you like music?',
            'Sevdiğim Şeyler',
          ),
          _word(
            'yes-i-do',
            'Yes, I do.',
            'Evet, severim.',
            'A positive answer to “Do you like…?”',
            'Yes, I do.',
            'Sevdiğim Şeyler',
          ),
          _word(
            'no-i-dont',
            "No, I don't.",
            'Hayır, sevmem.',
            'A negative preference answer.',
            "No, I don't.",
            'Sevdiğim Şeyler',
          ),
          _word(
            'listen',
            'listen',
            'dinlemek',
            'To pay attention to sound.',
            'I listen to music.',
            'Sevdiğim Şeyler',
          ),
          _word(
            'game',
            'game',
            'oyun',
            'An activity with rules for fun.',
            'We play a game.',
            'Sevdiğim Şeyler',
          ),
          _word(
            'explore',
            'explore',
            'keşfetmek',
            'To look around and discover.',
            'We explore the garden.',
            'Sevdiğim Şeyler',
          ),
          _word(
            'garden',
            'garden',
            'bahçe',
            'A place where plants grow.',
            'The garden is green.',
            'Sevdiğim Şeyler',
          ),
        ],
        nextNodeId: 'activity-choice',
      ),
      'activity-choice': const StoryNode(
        id: 'activity-choice',
        scene: _sevdigimScene,
        kind: StoryNodeKind.choice,
        englishText: 'Choose an activity.',
        choices: [
          StoryChoice(
            id: 'music',
            label: 'Listen to music.',
            outcome: StoryOutcome(
              nextNodeId: 'music-picnic',
              feedback: 'Vadide yumuşak bir melodi yükseliyor.',
            ),
          ),
          StoryChoice(
            id: 'game',
            label: 'Play a game.',
            outcome: StoryOutcome(
              nextNodeId: 'game-picnic',
              feedback: 'Lina taşlarla küçük bir oyun hazırlıyor.',
            ),
          ),
          StoryChoice(
            id: 'garden',
            label: 'Explore the garden.',
            outcome: StoryOutcome(
              nextNodeId: 'garden-picnic',
              feedback: 'Bahçede yeni bir çiçek yolu açılıyor.',
            ),
          ),
        ],
      ),
      'music-picnic': const StoryNode(
        id: 'music-picnic',
        scene: _sevdigimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'I like music too. Let us listen together.',
        nextNodeId: 'preference-complete',
      ),
      'game-picnic': const StoryNode(
        id: 'game-picnic',
        scene: _sevdigimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Great choice! I like this game.',
        nextNodeId: 'preference-complete',
      ),
      'garden-picnic': const StoryNode(
        id: 'garden-picnic',
        scene: _sevdigimScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'The garden has a quiet path. Let us explore.',
        nextNodeId: 'preference-complete',
      ),
      'preference-complete': const StoryNode(
        id: 'preference-complete',
        scene: _sevdigimScene,
        kind: StoryNodeKind.completion,
        englishText: 'Sharing a preference made the picnic brighter.',
        turkishExplanation: 'Tercihini doğal bir cümleyle paylaştın.',
      ),
    },
  ),
  'kucuk-bir-gun': StoryDefinition(
    id: 'kucuk-bir-gun',
    worldId: 'yasam-vadisi',
    catalogOrder: 5,
    chapter: const StoryChapter(
      id: 'kucuk-bir-gun',
      number: 5,
      durationMinutes: 10,
      vocabularyCount: 5,
      hasListening: true,
    ),
    title: 'Küçük Bir Gün',
    description: 'Vadide öğrendiklerini doğal bir günde birleştir.',
    startNodeId: 'finale-greeting',
    reward: const StoryReward(xp: 22, seedGrowth: 1),
    coverVisual: const StoryVisualMetadata(
      assetPath:
          'assets/images/stories/yasam_vadisi/kucuk_bir_gun/cover_v1.webp',
      accessibilityDescription:
          'Sabah köyünden altın akşama uzanan taş yol ve Yaşam Vadisi.',
      alignmentY: -.08,
      overlayStrength: .52,
    ),
    learning: const StoryLearningMetadata(
      cefr: CefrLevel.a1Plus,
      learningGoals: ['Selamlaşma, rutin ve tercihleri birleştirmek'],
      grammarTargets: ['A1 structure reinforcement'],
      skillFocus: {
        StorySkill.reading,
        StorySkill.writing,
        StorySkill.vocabulary,
      },
      interestTags: {'daily-life', 'review'},
      ttsEligible: true,
      slowReplayAllowed: true,
    ),
    nodes: {
      'finale-greeting': StoryNode(
        id: 'finale-greeting',
        scene: _kucukGunMorningScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Hüma',
        englishText: 'Good morning! How will your valley day begin?',
        vocabulary: [
          _word(
            'good-morning',
            'Good morning',
            'Günaydın',
            'A greeting used in the morning.',
            'Good morning, Lina!',
            'Küçük Bir Gün',
          ),
          _word(
            'early',
            'early',
            'erken',
            'Before the usual time.',
            'I wake up early.',
            'Küçük Bir Gün',
          ),
          _word(
            'together',
            'together',
            'birlikte',
            'With another person.',
            'We walk together.',
            'Küçük Bir Gün',
          ),
          _word(
            'today',
            'today',
            'bugün',
            'The present day.',
            'Today is bright.',
            'Küçük Bir Gün',
          ),
          _word(
            'day',
            'day',
            'gün',
            'A period from morning to night.',
            'It is a good day.',
            'Küçük Bir Gün',
          ),
        ],
        nextNodeId: 'start-choice',
      ),
      'start-choice': const StoryNode(
        id: 'start-choice',
        scene: _kucukGunMorningScene,
        kind: StoryNodeKind.choice,
        englishText: 'Choose your first sentence.',
        choices: [
          StoryChoice(
            id: 'wake',
            label: 'I wake up early.',
            outcome: StoryOutcome(
              nextNodeId: 'early-path',
              feedback: 'Gün sakin bir sabahla başlıyor.',
            ),
          ),
          StoryChoice(
            id: 'breakfast',
            label: 'I eat breakfast.',
            outcome: StoryOutcome(
              nextNodeId: 'breakfast-path',
              feedback: 'Piknik masasında güne enerji katıyorsun.',
            ),
          ),
        ],
      ),
      'early-path': const StoryNode(
        id: 'early-path',
        scene: _kucukGunMorningScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'I wake up early too. Do you like morning walks?',
        nextNodeId: 'like-choice',
      ),
      'breakfast-path': const StoryNode(
        id: 'breakfast-path',
        scene: _kucukGunMorningScene,
        kind: StoryNodeKind.dialogue,
        speaker: 'Lina',
        englishText: 'Breakfast is ready. Do you like fruit?',
        nextNodeId: 'like-choice',
      ),
      'like-choice': const StoryNode(
        id: 'like-choice',
        scene: _kucukGunMorningScene,
        kind: StoryNodeKind.choice,
        englishText: 'Share your preference.',
        choices: [
          StoryChoice(
            id: 'yes',
            label: 'Yes, I do.',
            outcome: StoryOutcome(
              nextNodeId: 'write-day',
              feedback: 'Lina gülümseyerek aynı tercihi paylaşıyor.',
            ),
          ),
          StoryChoice(
            id: 'no',
            label: "No, I don't.",
            outcome: StoryOutcome(
              nextNodeId: 'write-day',
              feedback: 'Farklı tercihler de vadide kendine yer buluyor.',
            ),
          ),
        ],
      ),
      'write-day': const StoryNode(
        id: 'write-day',
        scene: _kucukGunFinaleScene,
        kind: StoryNodeKind.writing,
        englishText: 'Write two short sentences about your day.',
        writingPrompt: 'Örnek: “I wake up early. I like music.”',
        minimumWritingLength: 12,
        nextNodeId: 'valley-finale',
      ),
      'valley-finale': const StoryNode(
        id: 'valley-finale',
        scene: _kucukGunFinaleScene,
        kind: StoryNodeKind.completion,
        englishText: 'Your small day has become a living story.',
        turkishExplanation:
            'Yaşam Vadisi’ndeki ilk öğrenme yolculuğunu tamamladın.',
      ),
    },
  ),
};
