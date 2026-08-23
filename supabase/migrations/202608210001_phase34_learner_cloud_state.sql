create table if not exists public.learner_cloud_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  schema_version integer not null check (schema_version > 0),
  progress_data jsonb not null default '{}'::jsonb,
  personalization_data jsonb,
  updated_at timestamptz not null default now()
);

alter table public.learner_cloud_state enable row level security;

create policy "learner_cloud_state_select_own" on public.learner_cloud_state
for select to authenticated using ((select auth.uid()) = user_id);
create policy "learner_cloud_state_insert_own" on public.learner_cloud_state
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "learner_cloud_state_update_own" on public.learner_cloud_state
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "learner_cloud_state_delete_own" on public.learner_cloud_state
for delete to authenticated using ((select auth.uid()) = user_id);

revoke all on table public.learner_cloud_state from anon;
grant select, insert, update, delete on table public.learner_cloud_state to authenticated;
