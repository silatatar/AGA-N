# AGAIN voice foundation

Phase 30 uses provider-independent boundaries for microphone recording, speech-to-text, text-to-speech, shared playback, and future pronunciation assessment. The first real platform stack is `record` 7.1.1, `speech_to_text` 7.4.0, and `flutter_tts` 4.2.5. Pronunciation assessment remains truthfully unconfigured.

Recording and live recognition are deliberately separate. Recorder activities use temporary AAC-LC `.m4a`, 16 kHz, mono, 64 kbps audio and trusted elapsed duration. `speech_to_text` owns the microphone for explicit short-utterance recognition and does not transcribe that file. Long-form/file transcription remains a future backend capability.

TTS requires a real installed English language. Completion and failure come from engine callbacks; elapsed delays never represent playback success. Capability bootstrap checks existing permissions without prompting. Microphone and speech-recognition prompts may only follow an explicit user voice action.

The intended pipeline is: microphone → temporary recording → STT → transcript confirmation → existing local scripted Hüma or future gated remote AI → response text → TTS/playback. Text learning remains available when voice is unavailable.

Raw recordings are temporary by default. They are not copied into permanent product memory, uploaded, or retained invisibly. A future provider integration must document platform support, whether audio leaves the device, processor identity, retention, deletion, permission behavior, and child/guardian requirements.

No confidence value, transcript, recording success, listening completion, speaking duration, or pronunciation score may be invented. Speaking progress can later use actual recorded duration only. Pressing a microphone button, sending text, or receiving a fake/test transcript never earns speaking time. Listening completion requires real playback and a deterministic completion threshold.

Voice telemetry may record coarse events such as permission requested, recording started/completed/cancelled, STT success/failure, and TTS started/completed. It must not include raw audio, transcript text, spoken sentences, TTS text, auth secrets, or provider secrets.

Phase 28.1 remains postponed and is still a production release blocker. Phase 30 does not modify router or startup guards.

## Runtime verification status

No Android device or emulator was connected during Slice 10; the available
targets were Windows and Edge only. Current classification is therefore:

- microphone recording: `CONFIGURED_BUT_UNVERIFIED`
- live short-utterance STT: `CONFIGURED_BUT_UNVERIFIED`
- TTS: `CONFIGURED_BUT_UNVERIFIED`
- recorded-audio transcription: `UNCONFIGURED`
- pronunciation assessment: `UNCONFIGURED`

Hüma now has one explicit user-action voice path. It requests/initializes live
recognition only after the microphone action, prevents duplicate starts,
preserves original and edited transcript text, and cancels recognition when
the interaction scope is disposed. Text input remains available throughout.
