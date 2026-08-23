import 'package:flutter/material.dart';

import '../../../app/theme/again_tokens.dart';

enum WorldAtmosphere { sunlitValley, moonlitForest, underwater }

abstract final class WorldMapAssets {
  static const baseAtlas =
      'assets/images/worlds/shared/world_map_atlas_placeholder.webp';
}

@immutable
class WorldVisualProfile {
  const WorldVisualProfile({
    required this.worldId,
    required this.eyebrow,
    required this.learningTheme,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.ambientGlow,
    required this.surfaceTint,
    required this.atmosphere,
    this.mapEnvironmentAsset,
    this.detailHeroAsset,
  });

  final String worldId;
  final String eyebrow;
  final String learningTheme;
  final String description;
  final Color primary;
  final Color secondary;
  final Color ambientGlow;
  final Color surfaceTint;
  final WorldAtmosphere atmosphere;
  final String? mapEnvironmentAsset;
  final String? detailHeroAsset;
}

abstract final class WorldVisualProfiles {
  static const lifeValley = WorldVisualProfile(
    worldId: 'yasam-vadisi',
    eyebrow: '1. DÜNYA • A1',
    learningTheme: 'Tanışma ve günlük yaşam',
    description: 'Gün ışığının izinde ilk ifadelerini filizlendir.',
    primary: AgainColors.emerald500,
    secondary: AgainColors.gold400,
    ambientGlow: Color(0xFF6ED39B),
    surfaceTint: Color(0xFF123E35),
    atmosphere: WorldAtmosphere.sunlitValley,
    mapEnvironmentAsset:
        'assets/images/worlds/yasam_vadisi/environment_v1.webp',
    detailHeroAsset: 'assets/images/worlds/yasam_vadisi/environment_v1.webp',
  );

  static const silentForest = WorldVisualProfile(
    worldId: 'sessiz-orman',
    eyebrow: '2. DÜNYA • A1',
    learningTheme: 'Yönler, sesler ve keşif',
    description: 'Ay ışıklı patikalarda dinle, seç ve yolunu bul.',
    primary: Color(0xFF168B78),
    secondary: AgainColors.turquoise300,
    ambientGlow: Color(0xFF36D7D0),
    surfaceTint: Color(0xFF0B302E),
    atmosphere: WorldAtmosphere.moonlitForest,
    mapEnvironmentAsset:
        'assets/images/worlds/sessiz_orman/environment_v1.webp',
    detailHeroAsset: 'assets/images/worlds/sessiz_orman/environment_v1.webp',
  );

  static const seaKingdom = WorldVisualProfile(
    worldId: 'deniz-kralligi',
    eyebrow: '3. DÜNYA • A1',
    learningTheme: 'Yolculuk ve günlük yaşam',
    description:
        'Dalgaların altında yeni kelimeler ve yolculuklar seni bekliyor.',
    primary: Color(0xFF0877A8),
    secondary: AgainColors.turquoise300,
    ambientGlow: Color(0xFF3ADBE8),
    surfaceTint: Color(0xFF082D4D),
    atmosphere: WorldAtmosphere.underwater,
    mapEnvironmentAsset:
        'assets/images/worlds/deniz_kralligi/environment_v1.webp',
    detailHeroAsset: 'assets/images/worlds/deniz_kralligi/hero_background.webp',
  );

  static const values = [lifeValley, silentForest, seaKingdom];

  static WorldVisualProfile forWorld(String worldId) => values.firstWhere(
    (profile) => profile.worldId == worldId,
    orElse: () => lifeValley,
  );
}
