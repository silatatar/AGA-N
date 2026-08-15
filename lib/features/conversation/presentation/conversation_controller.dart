import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversation_repository.dart';
import '../domain/conversation_models.dart';
import '../../learner_profile/domain/learner_type.dart';
import '../../learner_profile/presentation/learner_selection_controller.dart';
import '../../onboarding/presentation/onboarding_controller.dart';

final humaConversationServiceProvider = Provider<HumaConversationService>(
  (ref) => LocalHumaConversationService(),
);

@Deprecated('Use humaConversationServiceProvider.')
final conversationRepositoryProvider = humaConversationServiceProvider;

final conversationProvider =
    NotifierProvider<ConversationController, ConversationSession?>(
      ConversationController.new,
    );

class ConversationController extends Notifier<ConversationSession?> {
  @override
  ConversationSession? build() => null;

  void start(ConversationScenario scenario, ConversationMode mode) {
    final effectiveMode =
        ref.read(humaConversationServiceProvider).supportsVoice
        ? mode
        : ConversationMode.text;
    state = ConversationSession(
      scenario: scenario,
      mode: effectiveMode,
      messages: const [
        ConversationMessage(
          id: 'huma-0',
          author: ConversationAuthor.huma,
          text: 'Welcome to the Blue Shell Café! What would you like?',
          translation: 'Mavi Kabuk Kafe’ye hoş geldin! Ne istersin?',
        ),
      ],
      suggestions: const [
        'I’d like a coffee, please.',
        'Could I have some tea?',
      ],
      turn: 0,
      targetVocabulary: const ['coffee', 'size', 'please'],
    );
  }

  Future<void> send(String value) async {
    final session = state;
    final text = value.trim();
    if (session == null || text.isEmpty || session.isTyping) return;
    final userMessage = ConversationMessage(
      id: 'user-${session.messages.length}',
      author: ConversationAuthor.user,
      text: text,
    );
    final usedSuggestion = session.suggestions.contains(text);
    state = session.copyWith(
      messages: [...session.messages, userMessage],
      suggestions: const [],
      isTyping: true,
    );
    final learnerType = ref.read(learnerSelectionProvider).value;
    final onboarding = ref.read(onboardingProvider).value;
    final request = HumaConversationRequest(
      userMessage: text,
      learnerLevel: onboarding?.level?.name ?? 'unspecified',
      learnerType: learnerType?.name ?? 'unspecified',
      scenario: session.scenario,
      history: [
        for (final message in [...session.messages, userMessage])
          HumaConversationTurn(author: message.author, text: message.text),
      ],
      safetyProfile: switch (learnerType) {
        LearnerType.child => HumaSafetyProfile.child,
        LearnerType.teen => HumaSafetyProfile.teen,
        _ => HumaSafetyProfile.adult,
      },
      learningGoals: onboarding?.goals ?? const {},
      targetVocabulary: session.targetVocabulary,
    );
    final reply = await ref
        .read(humaConversationServiceProvider)
        .respond(request);
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      messages: [
        ...current.messages,
        ConversationMessage(
          id: 'huma-${current.messages.length}',
          author: ConversationAuthor.huma,
          text: reply.assistantText,
          translation: reply.translation,
        ),
      ],
      suggestions: reply.suggestedReplies,
      turn: current.turn + 1,
      isTyping: false,
      newWords: {...current.newWords, ...reply.vocabularySuggestions}.toList(),
      strongExpressions: {
        ...current.strongExpressions,
        ...reply.usefulExpressions,
      }.toList(),
      suggestedRepliesUsed:
          current.suggestedRepliesUsed + (usedSuggestion ? 1 : 0),
    );
  }

  Future<void> correct(String value) async {
    final session = state;
    if (session == null || value.trim().isEmpty) return;
    final corrected = await ref
        .read(humaConversationServiceProvider)
        .correctSentence(value);
    if (corrected == null || corrected == value.trim()) return;
    final current = state;
    if (current == null) return;
    final note = '${value.trim()} → $corrected';
    state = current.copyWith(
      messages: [
        ...current.messages,
        ConversationMessage(
          id: 'correction-${current.messages.length}',
          author: ConversationAuthor.system,
          text: 'Daha doğal: $corrected',
          isCorrection: true,
        ),
      ],
      corrections: {...current.corrections, note}.toList(),
    );
  }

  void toggleTranslation(String id) {
    final session = state;
    if (session == null) return;
    state = session.copyWith(
      messages: session.messages
          .map(
            (message) => message.id == id
                ? message.copyWith(showTranslation: !message.showTranslation)
                : message,
          )
          .toList(),
    );
  }

  void end() {
    final session = state;
    if (session != null) state = session.copyWith(isEnded: true);
  }
}
