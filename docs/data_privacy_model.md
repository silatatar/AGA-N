# AGAIN data privacy foundation

## Stored locally

- learner display profile, learner type, avatar choice
- onboarding goals, interests, level, daily target, and locale preference
- progression, completed stories/chapters, deterministic rewards
- vocabulary entries and review history
- current guest or authenticated-session status

## Intended cloud data

- provider-owned identity reference (not password)
- learning profile and preferences
- versioned progression and daily activity
- vocabulary mastery and review state
- sync metadata required for conflict resolution

## Not stored by default

- plaintext passwords or authentication tokens in SharedPreferences
- unrestricted raw microphone recordings
- permanent arbitrary Hüma/AI conversation history
- ephemeral widget, animation, or debug state
- child public-chat content

## Safety requirements

- Every cloud document is owned by an authenticated user and protected by RLS.
- Child profiles collect only the minimum product data. `LearnerType.child` is
  not legal age verification and does not establish guardian consent.
- Guardian consent, age assurance, retention periods, export, and account/data
  deletion require legal/product approval before production launch.
- Logout removes provider credentials. Cached learning data must be namespaced
  by guest installation or authenticated user before account switching ships.
