import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progression/presentation/progression_controller.dart';
import '../../vocabulary/presentation/vocabulary_controller.dart';
import '../domain/atlas_models.dart';

final atlasProvider = FutureProvider.autoDispose<AtlasState>((ref) async {
  final progress = await ref.watch(progressionProvider.future);
  final vocabulary = await ref.watch(vocabularyProvider.future);
  final hasWeatherStory = progress.completedChapterIds.contains('hava-durumu');
  const valleyChapterIds = [
    'first-encounter',
    'ben-kimim',
    'gunluk-hayat',
    'sevdigim-seyler',
    'kucuk-bir-gun',
  ];
  final completedValleyChapters = valleyChapterIds
      .where(progress.completedChapterIds.contains)
      .toList();
  final hasFirstStory = completedValleyChapters.isNotEmpty;
  final valleyUnlocked = progress.unlockedWorldIds.contains('yasam-vadisi');
  final forestUnlocked = progress.unlockedWorldIds.contains('sessiz-orman');
  final seaUnlocked = progress.unlockedWorldIds.contains('deniz-kralligi');
  const forestChapterIds = ['ormana-giris', 'kaybolan-yol', 'gece-sesleri'];
  const seaChapterIds = [
    'duygular',
    'hava-durumu',
    'ulasim-araclari',
    'yolculuk-hazirligi',
  ];
  final completedForestChapters = forestChapterIds
      .where(progress.completedChapterIds.contains)
      .toList();
  final completedSeaChapters = seaChapterIds
      .where(progress.completedChapterIds.contains)
      .toList();

  final worlds = [
    AtlasWorld(
      slug: 'yasam-vadisi',
      name: 'Yaşam Vadisi',
      description:
          'İlk selamların ve yeni bağların toprağa iz bıraktığı sıcak vadi.',
      state: hasFirstStory
          ? AtlasDiscoveryState.discovered
          : valleyUnlocked
          ? AtlasDiscoveryState.partial
          : AtlasDiscoveryState.locked,
      progress: progress.worldProgress(valleyChapterIds) / 100,
      discoveredStories: [
        for (final id in completedValleyChapters)
          switch (id) {
            'first-encounter' => 'İlk Karşılaşma',
            'ben-kimim' => 'Ben Kimim?',
            'gunluk-hayat' => 'Günlük Hayat',
            'sevdigim-seyler' => 'Sevdiğim Şeyler',
            'kucuk-bir-gun' => 'Küçük Bir Gün',
            _ => id,
          },
      ],
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
      state: completedForestChapters.length == forestChapterIds.length
          ? AtlasDiscoveryState.discovered
          : forestUnlocked
          ? AtlasDiscoveryState.partial
          : AtlasDiscoveryState.locked,
      progress: progress.worldProgress(forestChapterIds) / 100,
      discoveredStories: [
        for (final id in completedForestChapters)
          switch (id) {
            'ormana-giris' => 'Ormana Giriş',
            'kaybolan-yol' => 'Kaybolan Yol',
            'gece-sesleri' => 'Gece Sesleri',
            _ => id,
          },
      ],
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
      state: completedSeaChapters.length == seaChapterIds.length
          ? AtlasDiscoveryState.discovered
          : seaUnlocked
          ? AtlasDiscoveryState.partial
          : AtlasDiscoveryState.locked,
      progress: progress.worldProgress(seaChapterIds) / 100,
      discoveredStories: [
        for (final id in completedSeaChapters)
          switch (id) {
            'duygular' => 'Duygular',
            'hava-durumu' => 'Hava Durumu',
            'ulasim-araclari' => 'Ulaşım Araçları',
            'yolculuk-hazirligi' => 'Yolculuk Hazırlığı',
            _ => id,
          },
      ],
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
        isFound: progress.completedChapterIds.length >= 2,
        lore: 'Deniz Krallığı kıyılarından gelen eski bir hatıra.',
      ),
    ],
    discoveredCount: worlds
        .where((world) => world.state == AtlasDiscoveryState.discovered)
        .length,
    totalWorldCount: 11,
  );
});
