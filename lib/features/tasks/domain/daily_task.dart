import '../../story/data/story_services.dart';

class DailyReward {
  const DailyReward({
    required this.xp,
    this.seedGrowth = 0,
    this.storyUnlockProgress = 0,
    this.badgeProgress = 0,
  });
  final int xp;
  final int seedGrowth;
  final int storyUnlockProgress;
  final int badgeProgress;
}

class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.educationalPurpose,
    required this.current,
    required this.target,
    required this.iconName,
    required this.reward,
  });
  final String id;
  final String title;
  final String description;
  final String educationalPurpose;
  final int current;
  final int target;
  final String iconName;
  final DailyReward reward;

  bool get isCompleted => current >= target;
  double get progress => (current / target).clamp(0, 1);
}

List<DailyTask> dailyTasksFrom(StoryProgressSnapshot snapshot) => [
  DailyTask(
    id: 'learn-five-words',
    title: '5 kelime öğren',
    description:
        '${snapshot.savedWords.length.clamp(0, 5)} / 5 kelime kaydedildi',
    educationalPurpose:
        'Yeni kelimeleri fark etme ve aktif kelime dağarcığını büyütme.',
    current: snapshot.savedWords.length.clamp(0, 5),
    target: 5,
    iconName: 'words',
    reward: const DailyReward(xp: 10, badgeProgress: 10),
  ),
  DailyTask(
    id: 'complete-story',
    title: 'Bir hikâye bölümü tamamla',
    description: snapshot.completedChapters.contains('hava-durumu')
        ? 'Hava Durumu tamamlandı'
        : '0 / 1 bölüm tamamlandı',
    educationalPurpose:
        'Kelime, dinleme ve bağlam bilgisini tek deneyimde birleştirme.',
    current: snapshot.completedChapters.contains('hava-durumu') ? 1 : 0,
    target: 1,
    iconName: 'story',
    reward: const DailyReward(xp: 15, seedGrowth: 1),
  ),
  DailyTask(
    id: 'speaking-two-minutes',
    title: '2 dakika konuşma pratiği yap',
    description: '${snapshot.speakingMinutes.clamp(0, 2)} / 2 dakika',
    educationalPurpose: 'İngilizce üretme güvenini ve akıcılığı geliştirme.',
    current: snapshot.speakingMinutes.clamp(0, 2),
    target: 2,
    iconName: 'speaking',
    reward: const DailyReward(xp: 10, badgeProgress: 15),
  ),
  DailyTask(
    id: 'vocabulary-review',
    title: 'Kelime tekrarı yap',
    description: snapshot.vocabularyReviews > 0
        ? 'Bugünkü tekrar tamamlandı'
        : '1 kısa tekrar bekliyor',
    educationalPurpose: 'Kaydedilen kelimeleri uzun süreli hafızaya taşıma.',
    current: snapshot.vocabularyReviews.clamp(0, 1),
    target: 1,
    iconName: 'review',
    reward: const DailyReward(xp: 5, badgeProgress: 5),
  ),
  DailyTask(
    id: 'complete-listening',
    title: 'Bir dinleme etkinliği tamamla',
    description: snapshot.listeningActivities > 0
        ? 'Dinleme tamamlandı'
        : '0 / 1 etkinlik',
    educationalPurpose:
        'Doğal konuşma hızını ve sesleri ayırt etmeyi geliştirme.',
    current: snapshot.listeningActivities.clamp(0, 1),
    target: 1,
    iconName: 'listening',
    reward: const DailyReward(xp: 5, storyUnlockProgress: 1),
  ),
];
