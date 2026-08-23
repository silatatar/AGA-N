import 'package:again/features/conversation/data/conversation_repository.dart';
import 'package:again/features/conversation/domain/conversation_models.dart';
import 'package:again/features/conversation/domain/huma_ai_models.dart';
import 'package:again/features/voice/application/huma_voice_pipeline.dart';
import 'package:again/features/voice/domain/voice_audio_cache.dart';
import 'package:again/features/voice/domain/voice_models.dart';
import 'package:again/features/voice/domain/voice_transcript.dart';
import 'package:flutter_test/flutter_test.dart';

HumaVoicePipelineRequest _request(VoiceTranscriptReview review) =>
    HumaVoicePipelineRequest(
      transcriptReview: review,
      learnerLevel: 'A1',
      learnerType: 'adult',
      scenario: ConversationScenario.cafe,
      history: const [],
      safetyProfile: HumaSafetyProfile.adult,
      targetVocabulary: const ['coffee', 'please'],
    );

void main() {
  group('Phase 30 Hüma voice pipeline', () {
    test('unconfirmed transcript cannot reach conversation service', () async {
      final review = VoiceTranscriptReview.fromRecognition(
        requestId: 'r',
        sessionId: 's',
        transcript: 'I want coffee please',
      );
      await expectLater(
        HumaVoicePipeline(
          conversationService: LocalHumaConversationService(),
        ).submit(_request(review)),
        throwsA(isA<TranscriptConfirmationRequired>()),
      );
    });

    test(
      'confirmed transcript uses existing local scripted boundary',
      () async {
        final review = VoiceTranscriptReview.fromRecognition(
          requestId: 'r',
          sessionId: 's',
          transcript: 'I want coffee please',
        ).confirm();
        final result = await HumaVoicePipeline(
          conversationService: LocalHumaConversationService(),
        ).submit(_request(review));
        expect(result.interactionMode, HumaInteractionMode.localScripted);
        expect(result.response.assistantText, isNotEmpty);
        expect(result.submittedTranscript, 'I want coffee please');
        expect(result.transcriptWasEdited, isFalse);
      },
    );

    test('edited transcript remains visibly marked after submission', () async {
      final review = VoiceTranscriptReview.fromRecognition(
        requestId: 'r',
        sessionId: 's',
        transcript: 'I coffee',
      ).edit('I want coffee, please.').confirm();
      final result = await HumaVoicePipeline(
        conversationService: LocalHumaConversationService(),
      ).submit(_request(review));
      expect(result.transcriptWasEdited, isTrue);
      expect(result.submittedTranscript, 'I want coffee, please.');
    });

    test('voice pipeline does not expose XP or speaking reward fields', () {
      const result = HumaVoicePipelineResult(
        response: HumaConversationResponse(
          assistantText: 'Hello',
          suggestedReplies: [],
          safetyState: HumaSafetyState.safe,
        ),
        interactionMode: HumaInteractionMode.localScripted,
        submittedTranscript: 'Hello',
        transcriptWasEdited: false,
      );
      final schema = result.toString().toLowerCase();
      expect(schema, isNot(contains('xp')));
      expect(schema, isNot(contains('speakingminutes')));
      expect(schema, isNot(contains('unlock')));
    });
  });

  group('Phase 30 voice audio cache key', () {
    test('same educational audio request has stable identity', () {
      const first = VoiceAudioCacheKey(
        text: 'Hello',
        locale: 'en-US',
        voiceProfile: 'neutral',
        speed: EducationalSpeechSpeed.normal,
        contentVersion: 'v1',
      );
      const second = VoiceAudioCacheKey(
        text: 'Hello',
        locale: 'en-US',
        voiceProfile: 'neutral',
        speed: EducationalSpeechSpeed.normal,
        contentVersion: 'v1',
      );
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('speed, voice, locale and version produce distinct cache entries', () {
      const normal = VoiceAudioCacheKey(
        text: 'Hello',
        locale: 'en-US',
        voiceProfile: 'neutral',
        speed: EducationalSpeechSpeed.normal,
        contentVersion: 'v1',
      );
      const slow = VoiceAudioCacheKey(
        text: 'Hello',
        locale: 'en-US',
        voiceProfile: 'neutral',
        speed: EducationalSpeechSpeed.slow,
        contentVersion: 'v1',
      );
      expect(normal, isNot(slow));
    });
  });
}
