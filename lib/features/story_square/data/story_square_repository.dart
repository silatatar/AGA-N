import '../domain/story_square_models.dart';

abstract interface class StorySquareRepository {
  Future<List<DemoSquareRoom>> readDemoRooms();
  Future<List<DemoSquareActivity>> readDemoActivity();
}

/// Internal preview data only. This adapter never represents real people,
/// presence, messages, room membership, or live network activity.
class LocalDemoStorySquareRepository implements StorySquareRepository {
  @override
  Future<List<DemoSquareRoom>> readDemoRooms() async => const [
    DemoSquareRoom(
      id: 'cafe-small-talk',
      area: SquareArea.speakingRooms,
      title: 'Kafede kısa sohbet',
      prompt: 'Sipariş verirken nazik ifadeleri birlikte prova et.',
      level: 'A1–A2',
      durationMinutes: 5,
      isHumaGuided: true,
    ),
    DemoSquareRoom(
      id: 'weather-circle',
      area: SquareArea.humaGroupPractice,
      title: 'Hava nasıl?',
      prompt: 'Hüma’nın sırayla sunduğu hava durumu cümlelerini tamamla.',
      level: 'A1',
      durationMinutes: 4,
      isHumaGuided: true,
    ),
    DemoSquareRoom(
      id: 'sea-story',
      area: SquareArea.storyDiscussion,
      title: 'Deniz Krallığı sonrası',
      prompt: 'Hikâyedeki seçimini güvenli hazır yanıtlarla değerlendir.',
      level: 'A2',
      durationMinutes: 6,
      isHumaGuided: true,
    ),
  ];

  @override
  Future<List<DemoSquareActivity>> readDemoActivity() async => const [
    DemoSquareActivity(
      name: 'Lina • demo karakter',
      message: 'Today I learned “cloudy”.',
    ),
    DemoSquareActivity(
      name: 'Arda • demo karakter',
      message: 'My favourite place is the sea.',
    ),
    DemoSquareActivity(
      name: 'Zeynep • demo karakter',
      message: 'Let’s practise polite questions.',
    ),
  ];
}
