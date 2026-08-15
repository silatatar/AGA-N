import '../../../app/router/app_router.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../domain/huma_models.dart';

class HumaGuidanceEngine {
  const HumaGuidanceEngine();

  HumaMessage select(HumaContext context) {
    if (context.firstTimeUser) {
      return const HumaMessage(
        id: 'first-welcome',
        type: HumaMessageType.welcome,
        text:
            'Merhaba, ben Hüma. Birlikte kelimelerin ardındaki dünyaları keşfedeceğiz.',
        priority: 100,
      );
    }
    if (context.newGrowthWord case final word?) {
      return HumaMessage(
        id: 'growth-$word',
        type: HumaMessageType.vocabulary,
        text: '“$word” gerçek bir tekrarın ardından biraz daha güçlendi.',
        priority: 95,
        action: const HumaAction(
          label: 'Bahçeyi Aç',
          route: AppRoutes.vocabularyGardenPath,
        ),
      );
    }
    if (context.activeStoryRoute case final route?) {
      return HumaMessage(
        id: 'active-story-${context.currentChapterId}',
        type: HumaMessageType.story,
        text: _activeStory(context),
        priority: 80,
        action: HumaAction(label: 'Devam Et', route: route),
      );
    }
    if (context.vocabularyDueCount > 0) {
      return HumaMessage(
        id: 'due-vocabulary-${context.vocabularyDueCount}',
        type: HumaMessageType.vocabulary,
        text: _due(context),
        priority: 70,
        action: const HumaAction(
          label: 'Tekrar Et',
          route: AppRoutes.vocabularyGardenPath,
        ),
      );
    }
    final remaining = context.dailyTarget - context.dailyMinutes;
    if (remaining > 0 && remaining <= 5) {
      return HumaMessage(
        id: 'daily-near-$remaining',
        type: HumaMessageType.progress,
        text: _nearGoal(context, remaining),
        priority: 60,
        action: const HumaAction(
          label: 'Kısa Bir Yolculuk',
          route: AppRoutes.worldMapPath,
        ),
      );
    }
    if (context.newlyUnlockedWorldId case final world?) {
      return HumaMessage(
        id: 'world-unlocked-$world',
        type: HumaMessageType.world,
        text:
            '${_worldName(world)} artık açık. Yeni rotayı birlikte keşfedebiliriz.',
        priority: 55,
        action: const HumaAction(
          label: 'Haritayı Aç',
          route: AppRoutes.worldMapPath,
        ),
      );
    }
    if (context.taskCount > context.completedTaskCount) {
      final open = context.taskCount - context.completedTaskCount;
      return HumaMessage(
        id: 'tasks-$open',
        type: HumaMessageType.task,
        text: _tasks(context, open),
        priority: 45,
        action: const HumaAction(
          label: 'Görevleri Gör',
          route: AppRoutes.dailyTasksPath,
        ),
      );
    }
    if (context.dailyMinutes >= context.dailyTarget &&
        context.dailyTarget > 0) {
      return const HumaMessage(
        id: 'daily-complete',
        type: HumaMessageType.progress,
        text:
            'Bugünkü öğrenme hedefin tamamlandı. İstersen yeni bir dünyayı acele etmeden keşfedebilirsin.',
        priority: 40,
        action: HumaAction(label: 'Haritayı Aç', route: AppRoutes.worldMapPath),
      );
    }
    if (context.vocabularyCount == 0 &&
        context.screen == HumaScreen.vocabulary) {
      return const HumaMessage(
        id: 'empty-vocabulary',
        type: HumaMessageType.emptyState,
        text:
            'İlk kelimeni bir hikâyede keşfettiğinde burada ilk tohumun filizlenecek.',
        priority: 35,
        action: HumaAction(
          label: 'Hikâye Keşfet',
          route: AppRoutes.worldMapPath,
        ),
      );
    }
    if (context.returningUser && context.screen == HumaScreen.opening) {
      return HumaMessage(
        id: 'returning-${context.learnerName}',
        type: HumaMessageType.returningUser,
        text: 'Tekrar hoş geldin, ${context.learnerName}. Kaldığın yer hazır.',
        priority: 30,
      );
    }
    return HumaMessage(
      id: 'explore-${context.screen.name}',
      type: HumaMessageType.guidance,
      text: _explore(context),
      priority: 10,
      action: context.screen == HumaScreen.square
          ? const HumaAction(
              label: 'Hüma ile Konuş',
              route: AppRoutes.humaConversationPath,
            )
          : const HumaAction(
              label: 'Haritayı Aç',
              route: AppRoutes.worldMapPath,
            ),
    );
  }

  String _activeStory(HumaContext c) => switch (c.learnerType) {
    LearnerType.child =>
      'Hikâyen kaldığın yerde. Hazırsan birlikte devam edelim.',
    LearnerType.teen =>
      'Hikâyendeki bir sonraki sahne seni bekliyor. İstersen oradan devam edelim.',
    _ =>
      'Kaldığın hikâye hazır. Kısa bir bölümle yolculuğuna devam edebilirsin.',
  };

  String _due(HumaContext c) => switch (c.learnerType) {
    LearnerType.child =>
      '${c.vocabularyDueCount} kelimen tekrar bekliyor. Hazırsan birlikte bakalım.',
    LearnerType.teen =>
      'Bugün ${c.vocabularyDueCount} kelimen biraz ilgi bekliyor.',
    _ =>
      'Bugün ${c.vocabularyDueCount} kelimenin tekrar zamanı geldi. Kısa bir oturum yeterli.',
  };

  String _nearGoal(HumaContext c, int remaining) => switch (c.learnerType) {
    LearnerType.child =>
      'Bugünkü yolculuğunda $remaining dakika kaldı. Kısa bir hikâye seçebiliriz.',
    LearnerType.teen =>
      'Hedefine yalnızca $remaining dakika kaldı. Kısa bir keşifle tamamlayabilirsin.',
    _ =>
      'Bugünkü ${c.dailyTarget} dakikalık hedefinin $remaining dakikası kaldı. Kısa bir etkinlik yeterli.',
  };

  String _tasks(HumaContext c, int open) => c.learnerType == LearnerType.child
      ? 'Bugün $open küçük hedefin var. Birini birlikte seçebiliriz.'
      : 'Bugün tamamlayabileceğin $open öğrenme görevi var. En kısa olanla başlayabilirsin.';

  String _explore(HumaContext c) => switch (c.learnerType) {
    _ when c.screen == HumaScreen.square =>
      'Meydandaki pratikler gerçek kişilerle değil, benim yönettiğim güvenli örnek akışlarla çalışır.',
    LearnerType.child => 'Bugün küçük bir keşfe çıkabiliriz.',
    LearnerType.teen => 'Haritada yeni bir keşif rotası seçebilirsin.',
    _ => 'Bugünkü hedeflerine uygun yeni bir yolculuk seçebilirsin.',
  };

  String _worldName(String id) => switch (id) {
    'yasam-vadisi' => 'Yaşam Vadisi',
    'sessiz-orman' => 'Sessiz Orman',
    'deniz-kralligi' => 'Deniz Krallığı',
    _ => 'Yeni dünya',
  };
}
