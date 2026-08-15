import '../domain/conversation_models.dart';

abstract interface class HumaConversationService {
  bool get isLocalDeterministic;
  bool get supportsVoice;
  Future<HumaConversationResponse> respond(HumaConversationRequest request);
  Future<String?> correctSentence(String sentence);
}

/// Development-only scripted adapter. A secure backend can replace this
/// implementation without changing presentation or session state.
class LocalHumaConversationService implements HumaConversationService {
  @override
  bool get isLocalDeterministic => true;

  @override
  bool get supportsVoice => false;

  @override
  Future<HumaConversationResponse> respond(
    HumaConversationRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (request.scenario != ConversationScenario.cafe) {
      return const HumaConversationResponse(
        assistantText: 'Let’s continue this scenario when its lesson is ready.',
        translation: 'Bu senaryonun dersi hazır olduğunda devam edelim.',
        suggestedReplies: [],
        safetyState: HumaSafetyState.safe,
      );
    }
    final turn =
        request.history
            .where((item) => item.author == ConversationAuthor.user)
            .length -
        1;
    return switch (turn) {
      0 => const HumaConversationResponse(
        assistantText: 'Of course. What size would you like?',
        translation: 'Elbette. Hangi boyu istersiniz?',
        suggestedReplies: ['A medium, please.', 'A small one, please.'],
        vocabularySuggestions: ['size', 'medium'],
        usefulExpressions: ['I’d like a coffee, please.'],
        safetyState: HumaSafetyState.safe,
      ),
      1 => const HumaConversationResponse(
        assistantText: 'Would you like milk with your coffee?',
        translation: 'Kahvenizle süt ister misiniz?',
        suggestedReplies: ['Yes, please.', 'No, thank you.'],
        vocabularySuggestions: ['with'],
        usefulExpressions: ['A medium, please.'],
        safetyState: HumaSafetyState.safe,
      ),
      _ => const HumaConversationResponse(
        assistantText:
            'Perfect. Your coffee will be ready soon. That will be four euros.',
        translation:
            'Harika. Kahveniz yakında hazır olacak. Dört avro tutuyor.',
        suggestedReplies: ['Thank you!', 'That’s all, thank you.'],
        vocabularySuggestions: ['ready', 'soon'],
        usefulExpressions: ['No, thank you.'],
        safetyState: HumaSafetyState.safe,
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

@Deprecated('Use HumaConversationService.')
typedef ConversationRepository = HumaConversationService;

@Deprecated('Use LocalHumaConversationService.')
typedef LocalConversationRepository = LocalHumaConversationService;
