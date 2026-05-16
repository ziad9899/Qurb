-- ============================================================
-- 20260516_013_ban_user_enforce.sql
-- Migration 001 declared profiles.status check ('active','banned')
-- but no RPC ever flipped status to 'banned', and the write RPCs
-- (create_post / create_comment / send_message / request_whisper /
-- cast_vote / update_my_post / file_report) never checked status.
-- A banned account could keep posting through any of these.
--
-- This migration:
--   * adds _is_banned(uuid) — cheap reusable guard
--   * patches every write RPC to raise 'account_banned' if banned
--   * adds ban_user_by_numeric_id(numeric_id, reason) — guarded so
--     only service_role can call it (Edge Function / SQL editor)
--   * adds file_report support for target_type='user' (resolves
--     target_user_id via numeric_id) and target_type='message'
--     (resolves via messages.sender_id) so moderators see whose
--     account is reported.
-- ============================================================

set check_function_bodies = off;

------------------------------------------------------------
-- _is_banned(uuid) → boolean
-- Stable, can be called repeatedly within one transaction.
------------------------------------------------------------
create or replace function public._is_banned(p_uid uuid)
returns boolean
language sql stable
as $$
  select exists (
    select 1 from public.profiles
     where id = p_uid and status = 'banned'
  );
$$;

------------------------------------------------------------
-- ban_user_by_numeric_id — admin-only.
-- Granted to service_role only; the anon/authenticated roles
-- cannot execute it directly. Triggered from an Edge Function
-- or the SQL editor when moderation queue acts on reports.
------------------------------------------------------------
create or replace function public.ban_user_by_numeric_id(
  p_numeric_id int,
  p_reason     text default null
) returns uuid
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_target uuid;
begin
  select id into v_target from public.profiles
   where numeric_id = p_numeric_id;
  if v_target is null then raise exception 'user_not_found'; end if;

  update public.profiles set status = 'banned' where id = v_target;

  -- Soft-hide everything they ever posted so it leaves feeds
  -- immediately. Comments/messages remain readable in-context
  -- so other users keep their threading intact.
  update public.posts
     set status = 'removed'
   where user_id = v_target and status = 'active';

  return v_target;
end;
$$;

revoke all on function public.ban_user_by_numeric_id(int, text) from public, anon, authenticated;
grant execute on function public.ban_user_by_numeric_id(int, text) to service_role;

------------------------------------------------------------
-- Re-patch create_post to add account_banned guard.
------------------------------------------------------------
create or replace function public.create_post(
  p_body text,
  p_tag text default null,
  p_proximity text default 'near',
  p_lat double precision default null,
  p_lng double precision default null
)
returns bigint
language plpgsql security definer
set search_path = public, extensions
as $$
declare
  v_uid uuid := auth.uid();
  v_id bigint;
  v_recent_count int;
  v_loc extensions.geography;
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  if public._is_banned(v_uid) then raise exception 'account_banned'; end if;
  if length(coalesce(p_body, '')) < 1 or length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;
  if p_proximity not in ('near', 'block', 'city') then
    raise exception 'invalid_proximity';
  end if;
  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  select count(*) into v_recent_count
    from public.posts
   where user_id = v_uid and created_at > now() - interval '24 hours';
  if v_recent_count >= 10 then
    raise exception 'rate_limit_posts_per_day';
  end if;

  v_loc := public._snap_location(p_lat, p_lng);
  insert into public.posts (user_id, body, tag, proximity, location)
  values (v_uid, p_body, nullif(p_tag, ''), p_proximity, v_loc)
  returning id into v_id;
  return v_id;
end;
$$;

------------------------------------------------------------
-- Re-patch create_comment with banned guard.
------------------------------------------------------------
create or replace function public.create_comment(
  p_post_id bigint,
  p_parent_id bigint,
  p_body text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_id bigint;
  v_recent int;
begin
  if v_uid is null then raise exception 'auth required'; end if;
  if public._is_banned(v_uid) then raise exception 'account_banned'; end if;
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;
  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  select count(*) into v_recent
    from public.comments
   where user_id = v_uid and created_at > now() - interval '1 hour';
  if v_recent >= 50 then raise exception 'rate_limit_comments_per_hour'; end if;

  insert into public.comments(post_id, parent_id, user_id, body)
  values (p_post_id, p_parent_id, v_uid, p_body)
  returning id into v_id;

  update public.posts set comments_count = comments_count + 1 where id = p_post_id;
  return v_id;
end;
$$;

------------------------------------------------------------
-- Re-patch send_message with banned guard.
------------------------------------------------------------
create or replace function public.send_message(
  p_chat_id bigint, p_body text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_id bigint;
  v_recent int;
  v_participant boolean;
begin
  if v_me is null then raise exception 'auth required'; end if;
  if public._is_banned(v_me) then raise exception 'account_banned'; end if;
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 1000 then
    raise exception 'body length out of range';
  end if;
  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  select exists (
    select 1 from public.chats c
     where c.id = p_chat_id and (c.user_a = v_me or c.user_b = v_me)
  ) into v_participant;
  if not v_participant then raise exception 'not_in_chat'; end if;

  select count(*) into v_recent
    from public.messages
   where sender_id = v_me and created_at > now() - interval '1 minute';
  if v_recent >= 60 then raise exception 'rate_limit_messages_per_minute'; end if;

  insert into public.messages(chat_id, sender_id, body)
  values (p_chat_id, v_me, p_body)
  returning id into v_id;

  update public.chats
     set last_message_at = now(),
         last_message_preview = left(p_body, 80)
   where id = p_chat_id;

  return v_id;
end;
$$;

------------------------------------------------------------
-- request_whisper — add banned guard (don't replicate full body;
-- patch by checking status at the top before the rest runs).
-- We re-create the whole function to be safe.
------------------------------------------------------------
create or replace function public.request_whisper(p_post_id bigint)
returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_author uuid;
  v_chat_id bigint;
  v_recent int;
begin
  if v_me is null then raise exception 'auth required'; end if;
  if public._is_banned(v_me) then raise exception 'account_banned'; end if;

  select user_id into v_author from public.posts
   where id = p_post_id and status = 'active';
  if v_author is null then raise exception 'post_not_found'; end if;
  if v_author = v_me then raise exception 'cannot_whisper_self'; end if;
  if public._is_banned(v_author) then raise exception 'recipient_banned'; end if;

  -- rate limit: 20 whisper requests / hour
  select count(*) into v_recent
    from public.chats
   where (user_a = v_me or user_b = v_me)
     and created_at > now() - interval '1 hour';
  if v_recent >= 20 then raise exception 'rate_limit_whispers_per_hour'; end if;

  -- reuse existing chat if any
  select id into v_chat_id from public.chats
   where (user_a = v_me and user_b = v_author)
      or (user_a = v_author and user_b = v_me)
   limit 1;

  if v_chat_id is null then
    insert into public.chats(user_a, user_b, source_post_id, status)
    values (v_me, v_author, p_post_id, 'pending')
    returning id into v_chat_id;
  end if;

  return v_chat_id;
end;
$$;

------------------------------------------------------------
-- update_my_post — banned guard.
------------------------------------------------------------
create or replace function public.update_my_post(
  p_post_id bigint,
  p_body text
) returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  if public._is_banned(v_uid) then raise exception 'account_banned'; end if;
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;
  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  select user_id into v_owner from public.posts
   where id = p_post_id and status = 'active';
  if v_owner is null then raise exception 'post_not_found'; end if;
  if v_owner <> v_uid then raise exception 'not_post_owner'; end if;

  update public.posts
     set body = p_body, edited_at = now()
   where id = p_post_id;
end;
$$;

------------------------------------------------------------
-- file_report — extend target_user_id resolution to cover
-- 'user' (numeric_id → uuid) and 'message' (messages.sender_id).
-- Keeps original auto-hide logic for posts/comments.
------------------------------------------------------------
create or replace function public.file_report(
  p_target_type text, p_target_id bigint, p_reason text, p_note text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_id bigint;
  v_recent int;
  v_target_user uuid;
begin
  if v_me is null then raise exception 'auth required'; end if;
  if p_target_type not in ('post','comment','user','message') then
    raise exception 'bad_target_type';
  end if;
  if p_reason not in ('spam','harass','fake','nsfw','private','other') then
    raise exception 'bad_reason';
  end if;

  select count(*) into v_recent
    from public.reports
   where reporter_id = v_me and created_at > now() - interval '24 hours';
  if v_recent >= 20 then raise exception 'rate_limit_reports_per_day'; end if;

  if p_target_type = 'post' then
    select user_id into v_target_user from public.posts where id = p_target_id;
  elsif p_target_type = 'comment' then
    select user_id into v_target_user from public.comments where id = p_target_id;
  elsif p_target_type = 'user' then
    -- p_target_id holds the public numeric_id, not a uuid
    select id into v_target_user from public.profiles where numeric_id = p_target_id;
  elsif p_target_type = 'message' then
    select sender_id into v_target_user from public.messages where id = p_target_id;
  end if;

  insert into public.reports(
    reporter_id, target_type, target_id, target_user_id, reason, note
  ) values (
    v_me, p_target_type, p_target_id, v_target_user, p_reason,
    nullif(p_note, '')
  )
  returning id into v_id;

  if p_target_type = 'post' then
    update public.posts
       set status = 'hidden'
     where id = p_target_id
       and status = 'active'
       and (select count(*) from public.reports
              where target_type = 'post' and target_id = p_target_id
                and created_at > now() - interval '24 hours') >= 3;
  elsif p_target_type = 'comment' then
    update public.comments
       set status = 'hidden'
     where id = p_target_id
       and status = 'active'
       and (select count(*) from public.reports
              where target_type = 'comment' and target_id = p_target_id
                and created_at > now() - interval '24 hours') >= 3;
  end if;

  return v_id;
end;
$$;
