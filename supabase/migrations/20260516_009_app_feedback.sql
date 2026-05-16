-- ============================================================
-- 20260516_009_app_feedback.sql
-- Stores in-app "Report a problem" submissions. RPC enforces a
-- 5-per-hour rate limit so abuse is bounded.
-- ============================================================

create table if not exists public.app_feedback (
  id          bigserial primary key,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  subject     text,
  body        text not null check (char_length(body) between 3 and 2000),
  locale      text,
  app_version text,
  created_at  timestamptz not null default now()
);

create index if not exists app_feedback_user_idx
  on public.app_feedback(user_id, created_at desc);

alter table public.app_feedback enable row level security;

drop policy if exists "read own feedback" on public.app_feedback;
create policy "read own feedback" on public.app_feedback
  for select using (auth.uid() = user_id);

create or replace function public.submit_feedback(
  p_subject text,
  p_body text,
  p_locale text default null,
  p_app_version text default null
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_recent int;
  v_id bigint;
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  if char_length(coalesce(p_body, '')) < 3 then
    raise exception 'feedback_too_short';
  end if;
  if char_length(p_body) > 2000 then
    raise exception 'feedback_too_long';
  end if;

  -- rate limit: 5 / hour
  select count(*) into v_recent
    from public.app_feedback
   where user_id = v_uid and created_at > now() - interval '1 hour';
  if v_recent >= 5 then raise exception 'rate_limit_feedback'; end if;

  insert into public.app_feedback(user_id, subject, body, locale, app_version)
  values (v_uid, nullif(p_subject, ''), p_body, p_locale, p_app_version)
  returning id into v_id;
  return v_id;
end;
$$;

grant execute on function public.submit_feedback(text, text, text, text) to authenticated;
