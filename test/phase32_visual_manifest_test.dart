import 'dart:convert';
import 'dart:io';

import 'package:again/features/story/data/story_repository.dart';
import 'package:again/features/story/domain/story_definition.dart';
import 'package:again/features/world/domain/world_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedByWorld = {
    'yasam-vadisi': 5,
    'sessiz-orman': 3,
    'deniz-kralligi': 4,
  };

  test('canonical 12-story visual inventory is complete and valid', () {
    expect(localStoryCatalog.all, hasLength(12));
    for (final entry in expectedByWorld.entries) {
      expect(localStoryCatalog.byWorld(entry.key), hasLength(entry.value));
    }

    for (final story in localStoryCatalog.all) {
      final cover = story.coverVisual;
      expect(cover, isNotNull, reason: '${story.id} cover');
      _expectValidVisual(cover!, owner: '${story.id}:cover');

      final scenes = story.nodes.values.map((node) => node.scene).toSet();
      expect(scenes, isNotEmpty, reason: '${story.id} scenes');
      for (final scene in scenes) {
        expect(scene.visual, isNotNull, reason: '${story.id}:${scene.id}');
        _expectValidVisual(scene.visual!, owner: '${story.id}:${scene.id}');
      }
    }
  });

  test('two future Deniz chapters remain non-playable and art-free', () {
    final future = denizKralligiChapters.where(
      (chapter) => !chapter.hasPlayableContent,
    );
    expect(future.map((chapter) => chapter.id).toSet(), {
      'seyahat-plani',
      'deniz-canlilari',
    });
    for (final chapter in future) {
      expect(chapter.state, ChapterState.comingSoon);
      expect(chapter.isSelectable, isFalse);
      expect(chapter.coverAsset, isNull);
    }
  });

  test('Phase 32 assets have no exact duplicate, orphan, or PNG residue', () {
    final assetFiles = [
      ...Directory('assets/images/stories').listSync(recursive: true),
      ...Directory('assets/images/worlds').listSync(recursive: true),
    ].whereType<File>().toList();
    expect(assetFiles, hasLength(31));
    expect(assetFiles.where((file) => file.path.endsWith('.png')), isEmpty);

    final payloads = <String, String>{};
    for (final file in assetFiles) {
      final relative = file.path.replaceAll('\\', '/');
      final payload = base64Encode(file.readAsBytesSync());
      expect(
        payloads.containsKey(payload),
        isFalse,
        reason: 'duplicate: $relative == ${payloads[payload]}',
      );
      payloads[payload] = relative;
    }

    final dartSources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');
    for (final file in assetFiles) {
      final relative = file.path.replaceAll('\\', '/');
      expect(
        dartSources.contains(relative),
        isTrue,
        reason: 'orphan: $relative',
      );
    }

    final presentationSources = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.contains(
                '${Platform.pathSeparator}presentation${Platform.pathSeparator}',
              ) &&
              file.path.endsWith('.dart'),
        )
        .map((file) => file.readAsStringSync())
        .join('\n');
    expect(presentationSources.contains('assets/images/stories/'), isFalse);
    expect(presentationSources.contains('assets/images/worlds/'), isFalse);
  });
}

void _expectValidVisual(StoryVisualMetadata visual, {required String owner}) {
  expect(visual.assetPath, isNotEmpty, reason: owner);
  expect(File(visual.assetPath).existsSync(), isTrue, reason: owner);
  expect(visual.accessibilityDescription.trim(), isNotEmpty, reason: owner);
  expect(visual.alignmentX, inInclusiveRange(-1, 1), reason: owner);
  expect(visual.alignmentY, inInclusiveRange(-1, 1), reason: owner);
  expect(visual.overlayStrength, inInclusiveRange(0, 1), reason: owner);
}
