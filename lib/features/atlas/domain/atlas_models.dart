enum AtlasDiscoveryState { discovered, partial, locked }

class AtlasWorld {
  const AtlasWorld({
    required this.slug,
    required this.name,
    required this.description,
    required this.state,
    required this.progress,
    required this.discoveredStories,
    required this.vocabularyThemes,
    required this.culturalNotes,
  });
  final String slug;
  final String name;
  final String description;
  final AtlasDiscoveryState state;
  final double progress;
  final List<String> discoveredStories;
  final List<String> vocabularyThemes;
  final List<String> culturalNotes;
}

class AtlasCharacter {
  const AtlasCharacter({
    required this.name,
    required this.isMet,
    required this.relationship,
    required this.storyInformation,
  });
  final String name;
  final bool isMet;
  final String relationship;
  final String storyInformation;
}

class AtlasItem {
  const AtlasItem({
    required this.name,
    required this.isFound,
    required this.lore,
  });
  final String name;
  final bool isFound;
  final String lore;
}

class AtlasState {
  const AtlasState({
    required this.worlds,
    required this.characters,
    required this.items,
    required this.discoveredCount,
    required this.totalWorldCount,
  });
  final List<AtlasWorld> worlds;
  final List<AtlasCharacter> characters;
  final List<AtlasItem> items;
  final int discoveredCount;
  final int totalWorldCount;
}
