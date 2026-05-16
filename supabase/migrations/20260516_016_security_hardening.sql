-- ============================================================
-- 20260516_016_security_hardening.sql
-- Closes the four CRITICAL/HIGH server-side findings from the
-- security audit:
--   S-1  RLS missing on `communities`
--   S-2  Storage `legal` bucket lets anon write/overwrite anything
--   S-3  request_whisper has two overloaded signatures (one
--        introduced by mig 013 is dead code that the client never
--        calls — drop it and re-apply the banned-account guard to
--        the canonical 2-arg version)
--   S-4  RLS missing on `mod_stopwords` (lets anon read the
--        complete profanity list and craft evasions)
-- ============================================================

set check_function_bodies = off;

------------------------------------------------------------
-- S-1: communities — enable RLS, deny by default.
-- The table exists from an earlier scaffold but is unused by
-- the v1 client. We lock it down rather than removing it so
-- migrations stay additive.
------------------------------------------------------------
alter table public.communities enable row level security;

drop policy if exists "deny all reads" on public.communities;
create policy "deny all reads" on public.communities
  for select using (false);

-- No INSERT/UPDATE/DELETE policies means those operations are
-- denied by default for anon/authenticated. service_role bypasses
-- RLS so admin tooling still works.

------------------------------------------------------------
-- S-2: lock storage.objects 'legal' bucket to admin-write only.
-- Public reads stay open (it serves the privacy policy mirror).
-- Writes / deletes / replacements must now happen through
-- service_role (Edge Function or SQL editor) — anon can no longer
-- overwrite our privacy.html.
------------------------------------------------------------
drop policy if exists "legal_anon_upsert" on storage.objects;

drop policy if exists "legal_service_write" on storage.objects;
create policy "legal_service_write" on storage.objects
  for all to service_role
  using (bucket_id = 'legal')
  with check (bucket_id = 'legal');

-- legal_public_read from mig setup_legal_bucket stays as-is.

------------------------------------------------------------
-- S-3: drop the duplicate single-arg request_whisper added in
-- mig 013, and patch the canonical 2-arg version (which the
-- client actually calls) to include the banned-account guard
-- that mig 013 was trying to apply.
------------------------------------------------------------
drop function if exists public.request_whisper(bigint);

create or replace function public.request_whisper(
  p_post_id bigint, p_message text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_from uuid := auth.uid();
  v_to uuid;
  v_id bigint;
  v_recent int;
  v_existing_chat bigint;
begin
  if v_from is null then raise exception 'auth required'; end if;
  if public._is_banned(v_from) then raise exception 'account_banned'; end if;

  select user_id into v_to from public.posts
   where id = p_post_id and status = 'active';
  if v_to is null then raise exception 'post_not_found'; end if;
  if v_to = v_from then raise exception 'cannot_whisper_self'; end if;
  if public._is_banned(v_to) then raise exception 'recipient_banned'; end if;
  if char_length(coalesce(p_message, '')) > 500 then
    raise exception 'message_too_long';
  end if;

  -- if chat already exists, signal the UI to jump to it
  select id into v_existing_chat from public.chats
   where pair_key = public._pair_key(v_from, v_to);
  if v_existing_chat is not null then
    raise exception 'chat_exists:%', v_existing_chat;
  end if;

  -- rate limit: 3 requests / hour
  select count(*) into v_recent from public.chat_requests
   where from_user_id = v_from and created_at > now() - interval '1 hour';
  if v_recent >= 3 then raise exception 'rate_limit_whisper_requests_per_hour'; end if;

  -- 30-day cooldown after decline
  if exists (
    select 1 from public.chat_requests
     where from_user_id = v_from and to_user_id = v_to
       and status = 'declined'
       and responded_at > now() - interval '30 days'
  ) then
    raise exception 'declined_cooldown';
  end if;

  insert into public.chat_requests(from_user_id, to_user_id, post_id, message)
  values (v_from, v_to, p_post_id, nullif(p_message, ''))
  on conflict (from_user_id, to_user_id) do update
    set message = excluded.message,
        post_id = excluded.post_id,
        created_at = now(),
        status = 'pending',
        responded_at = null
  returning id into v_id;
  return v_id;
end;
$$;

grant execute on function public.request_whisper(bigint, text)
  to authenticated, anon;

------------------------------------------------------------
-- S-4: mod_stopwords — enable RLS, deny anon reads.
-- We don't want attackers reading our 218-row profanity list
-- to craft evasions. Reads only via the SECURITY DEFINER
-- functions (_contains_stopword), which run with definer rights
-- so they bypass RLS anyway. service_role keeps admin access.
------------------------------------------------------------
alter table public.mod_stopwords enable row level security;

-- No policies = no rows visible to anon/authenticated for
-- direct SELECT. The moderation helpers
-- (_contains_stopword, _is_spammy) are SECURITY DEFINER and
-- continue to work because they bypass RLS.
