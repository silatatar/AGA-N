import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversation_repository.dart';
import '../domain/conversation_models.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => LocalConversationRepository(),
);

final conversationProvider =
    NotifierProvider<ConversationController, ConversationSession?>(
      ConversationController.new,
    );

class ConversationController extends Notifier<ConversationSession?> {
  @override
  ConversationSession? build() => null;

  void start(ConversationScenario scenario, ConversationMode mode) {
    state = ConversationSession(
      scenario: scenario,
      mode: mode,
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
    state = session.copyWith(
      messages: [...session.messages, userMessage],
      suggestions: const [],
      isTyping: true,
    );
    final reply = await ref
        .read(conversationRepositoryProvider)
        .reply(
          scenario: session.scenario,
          userMessage: text,
          turn: session.turn,
        );
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      messages: [
        ...current.messages,
        ConversationMessage(
          id: 'huma-${current.messages.length}',
          author: ConversationAuthor.huma,
          text: reply.text,
          translation: reply.translation,
        ),
      ],
      suggestions: reply.suggestions,
      turn: current.turn + 1,
      isTyping: false,
      newWords: {...current.newWords, ...reply.newWords}.toList(),
      strongExpressions: {
        ...current.strongExpressions,
        ...reply.strongExpressions,
      }.toList(),
    );
  }

  Future<void> correct(String value) async {
    final session = state;
    if (session == null || value.trim().isEmpty) return;
    final corrected = await ref
        .read(conversationRepositoryProvider)
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
