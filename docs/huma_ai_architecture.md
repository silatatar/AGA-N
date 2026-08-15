# Hüma AI-ready architecture

Phase 24 uses `LocalHumaConversationService`, a deterministic scripted service. It is not AI and the UI must not describe it as AI.

## Production boundary

```text
Flutter client → authenticated AGAIN backend → selected AI provider
```

Never: Flutter client → secret provider API key.

The client sends a minimal `HumaConversationRequest`: current message, relevant short session history, learner band/level, selected scenario, required learning goals, target vocabulary and age-aware safety profile. It must not attach unrelated profile fields or permanent arbitrary chat history.

The backend must:

1. Authenticate the AGAIN account and authorise the learner profile.
2. Validate size, schema, scenario and allowed context.
3. Apply child/teen/adult safety policy and input moderation.
4. Assemble versioned system/personality instructions and trusted learning content.
5. Select model, enforce rate/cost/turn limits and protect the provider key.
6. Call the provider with timeouts, bounded retries and circuit breaking.
7. Moderate and validate structured output.
8. Return `HumaConversationResponse` with assistant text, supported suggestions, correction category, vocabulary suggestions, explanation and safety state.

## Privacy and operations

- Product analytics records coarse events, not raw sensitive conversation by default.
- Retention and deletion periods must be documented and user-controllable.
- Child conversations require stricter logging, contact-data protection and escalation design.
- Abuse detection, moderation decisions and operator access require audit controls.
- Do not infer permanent memory from chat. Optional memory is a separate consented future feature.
- Output failures return a safe branded state; they never fall back to unmoderated provider text.

## Replacement strategy

`HumaConversationService` is the client boundary. A future remote adapter can replace the local implementation through dependency injection. Screens, session state and summaries continue consuming the same typed request/response contracts.

## Localisation

Global Hüma guidance uses stable message identifiers and the guidance/content abstraction. Production localisation should resolve those identifiers through ARB resources. Story dialogue remains versioned story content; scenario dialogue remains versioned conversation content. New global copy should not be added directly to screens.
