import '../domain/conversation_models.dart';

abstract interface class ConversationRepository {
  Future<ConversationReply> reply({
    required ConversationScenario scenario,
    required String userMessage,
    required int turn,
  });
  Future<String?> correctSentence(String sentence);
}

/// Development-only scripted adapter. A secure backend can replace this
/// implementation without changing presentation or session state.
class LocalConversationRepository implements ConversationRepository {
  @override
  Future<ConversationReply> reply({
    required ConversationScenario scenario,
    required String userMessage,
    required int turn,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (scenario != ConversationScenario.cafe) {
      return const ConversationReply(
        text: 'Let’s continue this scenario when its lesson is ready.',
        translation: 'Bu senaryonun dersi hazır olduğunda devam edelim.',
        suggestions: [],
        newWords: [],
        strongExpressions: [],
      );
    }
    return switch (turn) {
      0 => const ConversationReply(
        text: 'Of course. What size would you like?',
        translation: 'Elbette. Hangi boyu istersiniz?',
        suggestions: ['A medium, please.', 'A small one, please.'],
        newWords: ['size', 'medium'],
        strongExpressions: ['I’d like a coffee, please.'],
      ),
      1 => const ConversationReply(
        text: 'Would you like milk with your coffee?',
        translation: 'Kahvenizle süt ister misiniz?',
        suggestions: ['Yes, please.', 'No, thank you.'],
        newWords: ['with'],
        strongExpressions: ['A medium, please.'],
      ),
      _ => const ConversationReply(
        text:
            'Perfect. Your coffee will be ready soon. That will be four euros.',
        translation:
            'Harika. Kahveniz yakında hazır olacak. Dört avro tutuyor.',
        suggestions: ['Thank you!', 'That’s all, thank you.'],
        newWords: ['ready', 'soon'],
        strongExpressions: ['No, thank you.'],
      ),
    };
  }

  @override
  Future<String?> correctSentence(String sentence) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final normal = sentence.trim().toLowerCase();
    if (normal == 'i want coffee please' || normal == 'i want a coffee') {
      return 'I’d like a coffee, please.';
    }
    if (normal == 'give me coffee') return 'Could I have a coffee, please?';
    if (sentence.trim().isEmpty) return null;
    return sentence.trim().endsWith('.')
        ? sentence.trim()
        : '${sentence.trim()}.';
  }
}
