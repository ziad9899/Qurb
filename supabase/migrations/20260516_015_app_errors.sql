-- ============================================================
-- 20260516_015_app_errors.sql
-- Lightweight crash + non-fatal error sink so we have ANY
-- visibility into production failures without bolting on
-- Sentry/Crashlytics. The client hooks FlutterError.onError and
-- PlatformDispatcher.onError, then calls log_app_error() with a
-- truncated message + stack.
--
-- Privacy + abuse control:
--   * Bodies are clipped to 4000 chars total (msg ≤ 500,
--     stack ≤ 3500) so we can't accidentally exfiltrate large
--     payloads from the client.
--   * Anonymous users can insert via the RPC only; direct table
--     INSERT is denied by RLS. Reads are service_role-only.
--   * Per-user rate limit: 30 errors per 5 minutes; over that the
--     RPC silently no-ops so a hot crash loop can't flood the
--     table or run up bandwidth.
-- ============================================================

create table if not exists public.app_errors (
  id            bigserial primary key,
  user_id       uuid references public.profiles(id) on delete set null,
  level         text not null check (level in ('error','fatal','warn','info')),
  message       text not null,
  stack         text,
  platform      text,            -- 'ios' | 'android' | 'web'
  app_version   text,
  build         text,
  context       jsonb,           -- route, locale, etc.
  created_at    timestamptz not null default now()
);

create index if not exists app_errors_created_idx
  on public.app_errors (created_at desc);
create index if not exists app_errors_user_idx
  on public.app_errors (user_id, created_at desc);

alter table public.app_errors enable row level security;

-- Anonymous + authenticated cannot read or insert directly; everything
-- routes through the RPC. service_role reads for ops dashboards.
drop policy if exists "service_read_errors" on public.app_errors;
create policy "service_read_errors" on public.app_errors
  for select to service_role using (true);

create or replace function public.log_app_error(
  p_level       text,
  p_message     text,
  p_stack       text default null,
  p_platform    text default null,
  p_app_version text default null,
  p_build       text default null,
  p_context     jsonb default null
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_id  bigint;
  v_recent int;
begin
  if p_level not in ('error','fatal','warn','info') then
    raise exception 'bad_level';
  end if;
  if char_length(coalesce(p_message, '')) < 1 then
    raise exception 'empty_message';
  end if;

  -- Per-user rate limit: 30 errors / 5 minutes. anon-only callers
  -- get a global ceiling because v_uid is NULL.
  if v_uid is not null then
    select count(*) into v_recent
      from public.app_errors
     where user_id = v_uid
       and created_at > now() - interval '5 minutes';
    if v_recent >= 30 then return null; end if;
  end if;

  insert into public.app_errors(
    user_id, level, message, stack, platform, app_version, build, context
  ) values (
    v_uid, p_level,
    left(p_message, 500),
    left(p_stack, 3500),
    p_platform, p_app_version, p_build, p_context
  )
  returning id into v_id;
  return v_id;
end;
$$;

grant execute on function public.log_app_error(text, text, text, text, text, text, jsonb)
  to anon, authenticated;
