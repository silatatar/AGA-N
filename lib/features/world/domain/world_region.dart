import '../../progression/domain/again_progress.dart';

enum WorldRegionState { completed, current, available, locked }

class WorldRegion {
  const WorldRegion({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.progress,
  });

  final String slug;
  final String title;
  final String subtitle;
  final WorldRegionState state;
  final double progress;
}

const worldRegions = [
  WorldRegion(
    slug: 'yasam-vadisi',
    title: 'Yaşam Vadisi',
    subtitle: 'Selamlaşmalar ve ilk bağlar',
    state: WorldRegionState.completed,
    progress: 1,
  ),
  WorldRegion(
    slug: 'sessiz-orman',
    title: 'Sessiz Orman',
    subtitle: 'Sesler, doğa ve basit cümleler',
    state: WorldRegionState.current,
    progress: .2,
  ),
  WorldRegion(
    slug: 'deniz-kralligi',
    title: 'Deniz Krallığı',
    subtitle: 'Duygular ve günlük ifadeler',
    state: WorldRegionState.available,
    progress: 0,
  ),
];

WorldRegion? regionBySlug(String slug) {
  for (final region in worldRegions) {
    if (region.slug == slug) return region;
  }
  return null;
}

List<WorldRegion> worldRegionsFrom(AgainProgress progress) => [
  _derived(worldRegions[0], progress, const ['first-encounter']),
  _derived(worldRegions[1], progress, const []),
  _derived(worldRegions[2], progress, const ['hava-durumu']),
];

WorldRegion _derived(
  WorldRegion catalog,
  AgainProgress progress,
  List<String> required,
) {
  final percent = progress.worldProgress(required) / 100;
  final unlocked = progress.unlockedWorldIds.contains(catalog.slug);
  final state = !unlocked
      ? WorldRegionState.locked
      : percent == 1
      ? WorldRegionState.completed
      : progress.currentWorldId == catalog.slug
      ? WorldRegionState.current
      : WorldRegionState.available;
  return WorldRegion(
    slug: catalog.slug,
    title: catalog.title,
    subtitle: catalog.subtitle,
    state: state,
    progress: percent,
  );
}
