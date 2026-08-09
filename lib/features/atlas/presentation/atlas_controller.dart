import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../story/data/story_services.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../domain/atlas_models.dart';

final atlasProvider = FutureProvider.autoDispose<AtlasState>((ref) async {
  final story = await ref.read(storyProgressRepositoryProvider).readSnapshot();
  final vocabulary = await ref.watch(vocabularyProvider.future);
  final hasWeatherStory = story.completedChapters.contains('hava-durumu');
  final hasFirstStory = story.hasFirstSeed;

  final worlds = [
    AtlasWorld(
      slug: 'yasam-vadisi',
      name: 'Yaşam Vadisi',
      description:
          'İlk selamların ve yeni bağların toprağa iz bıraktığı sıcak vadi.',
      state: hasFirstStory
          ? AtlasDiscoveryState.discovered
          : AtlasDiscoveryState.partial,
      progress: hasFirstStory ? 1 : .35,
      discoveredStories: hasFirstStory ? const ['İlk Karşılaşma'] : const [],
      vocabularyThemes: const ['Selamlaşma', 'Tanışma', 'Duygular'],
      culturalNotes: const [
        'Selamlaşma biçimleri bağlama ve yakınlığa göre değişebilir.',
      ],
    ),
    AtlasWorld(
      slug: 'sessiz-orman',
      name: 'Sessiz Orman',
      description:
          'Seslerin, doğanın ve dikkatle dinlemenin yol gösterdiği kadim orman.',
      state: AtlasDiscoveryState.partial,
      progress: .2,
      discoveredStories: const [],
      vocabularyThemes: const ['Doğa', 'Sesler', 'Basit yönergeler'],
      culturalNotes: const [
        'Doğa betimlemeleri İngilizce hikâyelerde güçlü bir atmosfer kurar.',
      ],
    ),
    AtlasWorld(
      slug: 'deniz-kralligi',
      name: 'Deniz Krallığı',
      description:
          'Limanlar, değişen gökyüzü ve yolculuklarla çevrili mavi krallık.',
      state: hasWeatherStory
          ? AtlasDiscoveryState.discovered
          : AtlasDiscoveryState.partial,
      progress: hasWeatherStory ? .34 : .12,
      discoveredStories: hasWeatherStory ? const ['Hava Durumu'] : const [],
      vocabularyThemes: vocabulary.isEmpty
          ? const ['Duygular', 'Hava durumu', 'Yolculuk']
          : vocabulary.map((word) => word.word).take(4).toList(),
      culturalNotes: const [
        'Hava durumu üzerine kısa konuşmalar günlük İngilizcede yaygın bir başlangıçtır.',
      ],
    ),
  ];

  return AtlasState(
    worlds: worlds,
    characters: [
      AtlasCharacter(
        name: 'Hüma',
        isMet: true,
        relationship: 'Yol göstericin',
        storyInformation:
            'Kelimelerin ardındaki dünyaları keşfetmene yardım eder.',
      ),
      AtlasCharacter(
        name: 'Mira',
        isMet: hasFirstStory,
        relationship: hasFirstStory
            ? 'Yaşam Vadisi’nde tanıştın'
            : 'Henüz tanışılmadı',
        storyInformation: hasFirstStory
            ? 'İlk İngilizce selamını seninle paylaştı.'
            : '',
      ),
      const AtlasCharacter(
        name: 'Bilinmeyen liman sakini',
        isMet: false,
        relationship: 'Bilinmiyor',
        storyInformation: '',
      ),
    ],
    items: [
      AtlasItem(
        name: 'İlk Tohum',
        isFound: hasFirstStory,
        lore: 'Öğrenilen ilk kelimenin vadide bıraktığı canlı iz.',
      ),
      AtlasItem(
        name: 'Fırtına Tüyü',
        isFound: hasWeatherStory,
        lore: 'Değişen gökyüzünü okumayı öğrenenlere görünür.',
      ),
      AtlasItem(
        name: 'Mavi Kabuk',
        isFound: story.completedChapters.length >= 2,
        lore: 'Deniz Krallığı kıyılarından gelen eski bir hatıra.',
      ),
    ],
    discoveredCount: worlds
        .where((world) => world.state != AtlasDiscoveryState.locked)
        .length,
    totalWorldCount: 11,
  );
});
