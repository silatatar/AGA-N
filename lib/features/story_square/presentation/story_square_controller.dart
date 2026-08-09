import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/story_square_repository.dart';
import '../domain/story_square_models.dart';

final storySquareRepositoryProvider = Provider<StorySquareRepository>(
  (ref) => LocalDemoStorySquareRepository(),
);

class StorySquareState {
  const StorySquareState({
    required this.rooms,
    required this.activity,
    this.selectedArea = SquareArea.todayTopic,
  });
  final List<DemoSquareRoom> rooms;
  final List<DemoSquareActivity> activity;
  final SquareArea selectedArea;

  StorySquareState copyWith({SquareArea? selectedArea}) => StorySquareState(
    rooms: rooms,
    activity: activity,
    selectedArea: selectedArea ?? this.selectedArea,
  );
}

class StorySquareController extends AsyncNotifier<StorySquareState> {
  @override
  Future<StorySquareState> build() async {
    final repository = ref.read(storySquareRepositoryProvider);
    return StorySquareState(
      rooms: await repository.readDemoRooms(),
      activity: await repository.readDemoActivity(),
    );
  }

  void selectArea(SquareArea area) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedArea: area));
    }
  }
}

final storySquareProvider =
    AsyncNotifierProvider<StorySquareController, StorySquareState>(
      StorySquareController.new,
    );
