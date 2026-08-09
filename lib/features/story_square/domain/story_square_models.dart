enum SquareArea {
  generalChat,
  todayTopic,
  speakingRooms,
  humaGroupPractice,
  storyDiscussion,
}

extension SquareAreaCopy on SquareArea {
  String get title => switch (this) {
    SquareArea.generalChat => 'Genel Sohbet',
    SquareArea.todayTopic => 'Bugünün Konusu',
    SquareArea.speakingRooms => 'Konuşma Odaları',
    SquareArea.humaGroupPractice => 'Hüma ile Grup Pratiği',
    SquareArea.storyDiscussion => 'Hikâye Tartışması',
  };
}

class DemoSquareRoom {
  const DemoSquareRoom({
    required this.id,
    required this.area,
    required this.title,
    required this.prompt,
    required this.level,
    required this.durationMinutes,
    required this.isHumaGuided,
  });

  final String id;
  final SquareArea area;
  final String title;
  final String prompt;
  final String level;
  final int durationMinutes;
  final bool isHumaGuided;
}

class DemoSquareActivity {
  const DemoSquareActivity({required this.name, required this.message});
  final String name;
  final String message;
}
