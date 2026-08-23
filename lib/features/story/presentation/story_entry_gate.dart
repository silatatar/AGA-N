import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../foundation/presentation/not_found_screen.dart';
import '../../progression/presentation/progression_controller.dart';
import '../../world/domain/world_chapter.dart';
import '../../world/domain/world_region.dart';
import '../../world/presentation/chapter_intro_placeholder_screen.dart';
import '../data/story_repository.dart';
import '../domain/story_entry.dart';
import 'data_driven_story_player_screen.dart';

class StoryEntryGate extends ConsumerWidget {
  const StoryEntryGate({
    super.key,
    required this.region,
    required this.chapterId,
  });

  final WorldRegion region;
  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressionProvider);
    return progress.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const NotFoundScreen(),
      data: (value) {
        final entry = StoryEntryResolver(
          localStoryCatalog,
        ).resolve(worldId: region.slug, chapterId: chapterId, progress: value);
        if (entry.status == StoryEntryStatus.playable) {
          return DataDrivenStoryPlayerScreen(storyId: entry.story!.id);
        }
        if (entry.status == StoryEntryStatus.locked) {
          return const NotFoundScreen();
        }
        if (region.slug != 'deniz-kralligi') {
          return const NotFoundScreen();
        }
        final placeholder = denizChaptersFrom(
          value,
        ).where((chapter) => chapter.id == chapterId).firstOrNull;
        return placeholder == null || placeholder.state == ChapterState.locked
            ? const NotFoundScreen()
            : ChapterIntroPlaceholderScreen(
                region: region,
                chapter: placeholder,
              );
      },
    );
  }
}
