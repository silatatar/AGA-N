import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/story_repository.dart';
import '../data/story_services.dart';
import '../domain/story_definition.dart';

final storySessionProvider = AsyncNotifierProvider.autoDispose
    .family<StorySessionController, StorySessionState, String>(
      StorySessionController.new,
    );

class StorySessionController extends AsyncNotifier<StorySessionState> {
  StorySessionController(this.storyId);
  final String storyId;
  StoryDefinition? _story;
  @override
  Future<StorySessionState> build() async {
    _story = await ref.read(storyRepositoryProvider).getStory(storyId);
    if (_story == null) throw StateError('Hikâye bulunamadı: $storyId');
    if (!validateStoryDefinition(_story!).isValid) {
      throw StateError('Geçersiz hikâye tanımı');
    }
    final progress = await ref
        .read(storyProgressRepositoryProvider)
        .readSnapshot();
    return StorySessionState(
      storyId: storyId,
      currentNodeId: _story!.startNodeId,
      visitedNodeIds: [_story!.startNodeId],
      wordsSaved: progress.savedWords,
    );
  }

  StoryNode get node => _story!.nodes[state.requireValue.currentNodeId]!;
  void discover(String id) {
    final s = state.requireValue;
    state = AsyncData(s.copyWith(wordsDiscovered: {...s.wordsDiscovered, id}));
  }

  Future<void> saveWord(String id) async {
    final s = state.requireValue;
    if (s.wordsSaved.contains(id)) return;
    state = AsyncData(s.copyWith(wordsSaved: {...s.wordsSaved, id}));
    await ref.read(storyProgressRepositoryProvider).saveWord(id);
  }

  Future<void> listened(String id) async {
    final s = state.requireValue;
    if (s.listeningActivitiesCompleted.contains(id)) return;
    state = AsyncData(
      s.copyWith(
        listeningActivitiesCompleted: {...s.listeningActivitiesCompleted, id},
      ),
    );
  }

  void next() {
    final next = node.nextNodeId;
    if (next != null) _move(next);
  }

  void submitWriting(String response) {
    final value = response.trim();
    if (node.kind != StoryNodeKind.writing ||
        value.length < node.minimumWritingLength) {
      return;
    }
    final s = state.requireValue;
    state = AsyncData(
      s.copyWith(writingResponses: {...s.writingResponses, node.id: value}),
    );
    next();
  }

  void choose(StoryChoice choice) {
    final s = state.requireValue;
    state = AsyncData(
      s.copyWith(
        selectedChoices: {...s.selectedChoices, node.id: choice.id},
        feedback: choice.outcome.feedback,
      ),
    );
    _move(choice.outcome.nextNodeId, feedback: choice.outcome.feedback);
  }

  void _move(String id, {String? feedback}) {
    final s = state.requireValue;
    state = AsyncData(
      s.copyWith(
        currentNodeId: id,
        visitedNodeIds: [...s.visitedNodeIds, id],
        feedback: feedback,
      ),
    );
  }

  Future<void> complete() async {
    final s = state.requireValue;
    if (s.isComplete) return;
    final story = _story!;
    final repository = ref.read(storyProgressRepositoryProvider);
    await repository.completeChapter(
      chapterId: story.chapter.id,
      minutes: story.chapter.durationMinutes,
      xp: story.reward.xp,
      storyId: story.id,
      worldId: story.worldId,
      nextChapterId: story.chapter.nextChapterId,
      seedGrowth: story.reward.seedGrowth,
    );
    if (story.reward.seedGrowth > 0 && story.id == 'first-encounter') {
      await repository.awardFirstSeed();
    }
    state = AsyncData(s.copyWith(isComplete: true, sessionXp: story.reward.xp));
  }
}
