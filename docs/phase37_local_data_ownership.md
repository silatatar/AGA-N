# Phase 37 — Local Data Ownership

## Boundary

Learner-owned records are stored under `DataOwner.storageKey(logicalKey)`.
The namespace is either `guest:<stable-installation-id>` or
`user:<trusted-auth-user-id>`. Switching the active owner changes which local
record is read; it never deletes another owner's record.

## Owner-scoped records

- `again.progression.v1`: XP, world/chapter/story progression, activity,
  rewards, seed growth, streak inputs and progression word IDs.
- `again.learner_profile.v1`: learner type, identity, onboarding answers and
  onboarding completion.
- `again.vocabulary_entries`: saved vocabulary and review/mastery state.
- Corrupt progression and personalization backups use the same owner namespace.

## Installation-scoped records

- `again.installation_id.v1`: stable anonymous guest identity.
- `again.data_owner.v1`: pointer to the currently active owner.
- `again.startup.v1`: active authentication/startup session envelope. Learner
  content referenced during startup remains in the owner-scoped stores.
- `again.guest_adoption.v1.<user-id>`: idempotency marker for a completed guest
  adoption by that authenticated account.

## Legacy migration

Old unscoped canonical and individual keys are treated as unclaimed
installation data. They may migrate only into the stable guest namespace.
They are never inferred to belong to a signed-in account. Copying is
idempotent: once a guest-scoped canonical record exists, it remains the source
of truth.

## Guest adoption

Guest data is retained while the cloud sync is attempted. Only after a
successful sync does the service switch to the trusted authenticated owner,
write the adopted account-scoped records and mark adoption complete. A local
write failure restores the guest owner. An unconfigured or failed cloud sync
leaves guest data and ownership untouched.

## Deliberately transient data

In-flight story presentation state, Hüma conversation UI state and voice
capture temporary files are not durable learner records. They require no local
owner namespace.

## Deferred

Router restructuring remains deferred under Phase 28.1. Phase 37 changes only
storage and authentication lifecycle boundaries.
