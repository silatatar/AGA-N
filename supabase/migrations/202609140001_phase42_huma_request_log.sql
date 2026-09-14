-- Backs huma-chat's rate limiting and idempotency with durable storage.
--
-- The edge function previously tracked both in process-memory `Map`s, which
-- are per-isolate and reset whenever Deno Deploy recycles or scales the
-- function. In practice this meant the per-user daily/per-minute limits
-- reset unpredictably and the idempotency guard did not protect against a
-- retried request landing on a different isolate. This table gives both
-- concerns a single durable, RLS-scoped source of truth.
create table if not exists public.huma_request_log (
  user_id uuid not null references auth.users(id) on delete cascade,
  idempotency_key text not null,
  request_id text not null,
  session_id text not null,
  turn_id text not null,
  response jsonb not null,
  created_at timestamptz not null default now(),
  primary key (user_id, idempotency_key)
);

create index if not exists huma_request_log_user_created_idx
  on public.huma_request_log (user_id, created_at desc);

alter table public.huma_request_log enable row level security;

-- Same trust boundary as learner_cloud_state: a signed-in user may only see
-- and write their own rows. The edge function calls PostgREST with the
-- caller's own bearer token (never a service-role key), so auth.uid() is
-- the authenticated user for every request.
create policy "huma_request_log_select_own" on public.huma_request_log
for select to authenticated using ((select auth.uid()) = user_id);

create policy "huma_request_log_insert_own" on public.huma_request_log
for insert to authenticated with check ((select auth.uid()) = user_id);

-- No update/delete policy: log rows are append-only. A scheduled cleanup
-- job (service-role, outside this migration) can prune rows older than the
-- 24h rate-limit window once one is set up.
revoke all on table public.huma_request_log from anon;
grant select, insert on table public.huma_request_log to authenticated;
