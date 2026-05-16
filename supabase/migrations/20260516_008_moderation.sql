-- ============================================================
-- 20260516_008_moderation.sql
-- Server-side moderation layer:
--   * mod_stopwords table (editable list of forbidden tokens)
--   * _contains_stopword(text) — case-insensitive substring match
--   * _is_spammy(text) — phone numbers + Telegram/WhatsApp links + URLs
--   * Hook into create_post / create_comment / send_message so flagged
--     content raises `moderation_violation` and is never persisted.
-- Plus: device_tokens table (scaffold for future FCM fan-out).
-- ============================================================

set check_function_bodies = off;

------------------------------------------------------------
-- mod_stopwords — editable list, indexed for fast lookup.
-- Initial seed is intentionally small and conservative; admins
-- can append rows via SQL editor without redeploying code.
------------------------------------------------------------
create table if not exists public.mod_stopwords (
  id          bigserial primary key,
  word        text not null,
  -- 'profanity' | 'spam' | 'hate' — used for future telemetry
  category    text not null default 'profanity',
  added_at    timestamptz not null default now()
);

create unique index if not exists mod_stopwords_word_uidx
  on public.mod_stopwords (lower(word));

-- Seed (idempotent). Keep this conservative. Real lists are
-- maintained by humans; this is just the floor.
insert into public.mod_stopwords (word, category) values
  -- English profanity / slurs (samples)
  ('fuck', 'profanity'),
  ('shit', 'profanity'),
  ('bitch', 'profanity'),
  ('asshole', 'profanity'),
  ('faggot', 'hate'),
  ('nigger', 'hate'),
  -- Arabic explicit profanity (samples — admins should extend)
  ('كلب', 'profanity'),
  ('حمار', 'profanity'),
  ('خنزير', 'profanity'),
  ('قحبة', 'profanity'),
  ('شرموطة', 'profanity'),
  ('زفت', 'profanity'),
  ('عاهرة', 'profanity'),
  ('منيوك', 'profanity'),
  -- Common spam patterns / scam keywords
  ('قرض سريع', 'spam'),
  ('ربح مضمون', 'spam'),
  ('تداول العملات', 'spam'),
  ('شغل من البيت', 'spam')
on conflict (lower(word)) do nothing;

------------------------------------------------------------
-- _contains_stopword(text) → boolean
-- Case-insensitive substring search across the stopword table.
-- For a list size in the low thousands this is fine; if it
-- grows past 10k we'd switch to a tsvector + GIN index.
------------------------------------------------------------
create or replace function public._contains_stopword(p_text text)
returns boolean
language plpgsql stable
as $$
declare
  v_lower text := lower(coalesce(p_text, ''));
begin
  if v_lower = '' then return false; end if;
  return exists (
    select 1 from public.mod_stopwords s
     where position(lower(s.word) in v_lower) > 0
  );
end;
$$;

------------------------------------------------------------
-- _is_spammy(text) → boolean
-- Detects high-signal spam patterns:
--   * 9+ consecutive digits (e.g. Saudi mobile numbers)
--   * common short-link domains
--   * `t.me/` Telegram handles, `wa.me/` WhatsApp deep-links
------------------------------------------------------------
create or replace function public._is_spammy(p_text text)
returns boolean
language plpgsql immutable
as $$
declare
  v_lower text := lower(coalesce(p_text, ''));
begin
  if v_lower = '' then return false; end if;
  if v_lower ~ '\d{9,}' then return true; end if;            -- phone number
  if v_lower ~ '(bit\.ly|t\.me/|wa\.me/|tinyurl\.com|cutt\.ly)' then
    return true;
  end if;
  return false;
end;
$$;

------------------------------------------------------------
-- Patch create_post to run moderation.
-- Keeps the existing 5-arg signature from migration 007.
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
  if length(coalesce(p_body, '')) < 1 or length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;
  if p_proximity not in ('near', 'block', 'city') then
    raise exception 'invalid_proximity';
  end if;

  -- moderation: stopword + spam
  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  -- rate limit: 10 posts / 24h
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

grant execute on function public.create_post(text, text, text, double precision, double precision) to authenticated;

------------------------------------------------------------
-- Patch create_comment to run moderation.
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
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;

  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  -- rate limit: 50 comments / hour
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

grant execute on function public.create_comment(bigint, bigint, text) to authenticated;

------------------------------------------------------------
-- Patch send_message to run moderation. Pull the rest of the
-- original body intact so chat dispatch logic stays untouched.
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
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 1000 then
    raise exception 'body length out of range';
  end if;

  if public._contains_stopword(p_body) or public._is_spammy(p_body) then
    raise exception 'moderation_violation';
  end if;

  -- must be a participant of the chat
  select exists (
    select 1 from public.chats c
     where c.id = p_chat_id and (c.user_a = v_me or c.user_b = v_me)
  ) into v_participant;
  if not v_participant then raise exception 'not_in_chat'; end if;

  -- rate limit: 60 messages / minute
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

grant execute on function public.send_message(bigint, text) to authenticated;

------------------------------------------------------------
-- device_tokens — scaffold for FCM/APNs fan-out (Phase 9.5).
-- Stored per (user_id, token) so a single account can have
-- multiple devices. On token rotation the client should call
-- register_device_token again with the new value.
------------------------------------------------------------
create table if not exists public.device_tokens (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  token        text not null,
  platform     text not null check (platform in ('ios','android','web')),
  app_version  text,
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  primary key (user_id, token)
);

create index if not exists device_tokens_user_idx on public.device_tokens(user_id);

alter table public.device_tokens enable row level security;

drop policy if exists "read own tokens" on public.device_tokens;
create policy "read own tokens" on public.device_tokens
  for select using (auth.uid() = user_id);

create or replace function public.register_device_token(
  p_token text,
  p_platform text,
  p_app_version text default null
) returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  if p_platform not in ('ios','android','web') then
    raise exception 'invalid_platform';
  end if;
  if coalesce(p_token, '') = '' then raise exception 'empty_token'; end if;

  insert into public.device_tokens(user_id, token, platform, app_version)
  values (v_uid, p_token, p_platform, p_app_version)
  on conflict (user_id, token)
    do update set platform = excluded.platform,
                  app_version = excluded.app_version,
                  last_seen_at = now();
end;
$$;

create or replace function public.unregister_device_token(p_token text)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  delete from public.device_tokens where user_id = v_uid and token = p_token;
end;
$$;

grant execute on function public.register_device_token(text, text, text) to authenticated;
grant execute on function public.unregister_device_token(text) to authenticated;
