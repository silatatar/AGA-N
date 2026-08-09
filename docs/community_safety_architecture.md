# Hikâye Meydanı — Community Safety Architecture

This document defines launch gates for any future real community capability. Phase 15 uses local fictional demo data only and has no user-to-user transport.

## Required launch gates

- Reporting: every message, room and profile needs a reason-coded report action, evidence retention policy, acknowledgement state and trained-review queue.
- Blocking: blocking must immediately hide both parties, prevent invitations and future direct contact, and synchronize across devices.
- Moderation: server-side pre-send and post-send controls, rate limits, abuse detection, human escalation, appeal handling and auditable moderator actions are required.
- Child safety: child profiles must never enter unrestricted public chat. Only allow-listed prompts, closed cohorts with verified guardians/educators, no discoverable profiles and no direct messages may be considered after a dedicated safety review.
- Restricted messaging: links, contact details, location requests, image/file exchange and off-platform migration language must be restricted according to age and risk.
- Privacy: collect the minimum data, avoid public real names, define retention/deletion, encrypt transport and storage, provide export/deletion controls, and document processor access.

## Product and engineering controls

- Community services must sit behind authenticated repository interfaces; clients cannot mark content as moderated.
- Presence and participant counts must originate from a trusted server and must never be fabricated.
- Feature flags must be age-aware and default off.
- Safety telemetry must avoid storing conversation content unless necessary and disclosed.
- A kill switch, incident runbook, moderator tooling, child-safety threat model and privacy/legal review are mandatory before launch.
- Accessibility, localization, false-positive review and adversarial safety tests are release requirements.

## Current prototype boundary

The local adapter returns named fictional demo characters and scripted prompts. It performs no networking, discovery, messaging, recording, presence tracking, reporting or blocking. UI labels must continue to identify this state as an internal demo until the launch gates above are satisfied.
