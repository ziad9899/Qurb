-- Minto / قُرب — Phase 4: Whispers (private 1:1 chat)
--
-- Privacy strategy: clients never see other users' UUIDs. All whisper
-- requests originate from a post — `request_whisper(post_id, message)`
-- derives the recipient server-side. Conversations expose only the
-- counterpart's numeric_id via views.

set check_function_bodies = off;

------------------------------------------------------------
-- chat_requests — pending "may I message you?" invitations
------------------------------------------------------------
create table if not exists public.chat_requests (
  id            bigserial primary key,
  from_user_id  uuid not null references public.profiles(id) on delete cascade,
  to_user_id    uuid not null references public.profiles(id) on delete cascade,
  post_id       bigint references public.posts(id) on delete set null,
  message       text check (char_length(message) <= 500),
  status        text not null default 'pending'
                check (status in ('pending','accepted','declined','cancelled')),
  created_at    timestamptz not null default now(),
  responded_at  timestamptz,
  unique (from_user_id, to_user_id)
);

create index if not exists chat_requests_to_pending_idx
  on public.chat_requests(to_user_id, created_at desc) where status = 'pending';
create index if not exists chat_requests_from_idx
  on public.chat_requests(from_user_id, status);

------------------------------------------------------------
-- chats — accepted 1:1 conversations
------------------------------------------------------------
create table if not exists public.chats (
  id                   bigserial primary key,
  pair_key             text not null unique,
  user_a               uuid not null references public.profiles(id) on delete cascade,
  user_b               uuid not null references public.profiles(id) on delete cascade,
  created_at           timestamptz not null default now(),
  last_message_at      timestamptz,
  last_message_preview text,
  status               text not null default 'active'
                       check (status in ('active','blocked','archived'))
);

create index if not exists chats_user_a_idx
  on public.chats(user_a, last_message_at desc nulls last);
create index if not exists chats_user_b_idx
  on public.chats(user_b, last_message_at desc nulls last);

------------------------------------------------------------
-- messages
------------------------------------------------------------
create table if not exists public.messages (
  id          bigserial primary key,
  chat_id     bigint not null references public.chats(id) on delete cascade,
  sender_id   uuid not null references public.profiles(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 1000),
  created_at  timestamptz not null default now(),
  read_at     timestamptz
);

create index if not exists messages_chat_time_idx
  on public.messages(chat_id, created_at);

------------------------------------------------------------
-- helpers
------------------------------------------------------------
create or replace function public._pair_key(a uuid, b uuid)
returns text language sql immutable
set search_path = public, pg_temp
as $$
  select case when a::text < b::text
              then a::text || ':' || b::text
              else b::text || ':' || a::text end;
$$;

------------------------------------------------------------
-- request_whisper(post_id, message) — recipient derived server-side
------------------------------------------------------------
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
  select user_id into v_to from public.posts where id = p_post_id and status = 'active';
  if v_to is null then raise exception 'post_not_found'; end if;
  if v_to = v_from then raise exception 'cannot_whisper_self'; end if;
  if char_length(coalesce(p_message, '')) > 500 then raise exception 'message_too_long'; end if;

  -- if chat already exists, return its id (no new request needed)
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

------------------------------------------------------------
-- respond_whisper_request(request_id, action) — returns chat_id when accepted
------------------------------------------------------------
create or replace function public.respond_whisper_request(
  p_request_id bigint, p_action text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_req public.chat_requests;
  v_chat_id bigint;
  v_a uuid; v_b uuid;
begin
  if v_me is null then raise exception 'auth required'; end if;
  select * into v_req from public.chat_requests where id = p_request_id;
  if v_req.id is null then raise exception 'request_not_found'; end if;
  if v_req.to_user_id <> v_me then raise exception 'not_recipient'; end if;
  if v_req.status <> 'pending' then raise exception 'already_responded'; end if;

  if p_action = 'accept' then
    if v_req.from_user_id::text < v_req.to_user_id::text then
      v_a := v_req.from_user_id; v_b := v_req.to_user_id;
    else
      v_a := v_req.to_user_id; v_b := v_req.from_user_id;
    end if;
    insert into public.chats(pair_key, user_a, user_b)
    values (public._pair_key(v_a, v_b), v_a, v_b)
    on conflict (pair_key) do update set status = 'active'
    returning id into v_chat_id;

    update public.chat_requests
       set status = 'accepted', responded_at = now()
     where id = p_request_id;

    -- carry the request's message into the chat as the first message
    if v_req.message is not null then
      insert into public.messages(chat_id, sender_id, body)
      values (v_chat_id, v_req.from_user_id, v_req.message);
      update public.chats
         set last_message_at = now(),
             last_message_preview = substring(v_req.message, 1, 80)
       where id = v_chat_id;
    end if;

    return v_chat_id;
  elsif p_action = 'decline' then
    update public.chat_requests
       set status = 'declined', responded_at = now()
     where id = p_request_id;
    return null;
  else
    raise exception 'bad_action';
  end if;
end;
$$;

------------------------------------------------------------
-- send_message(chat_id, body)
------------------------------------------------------------
create or replace function public.send_message(
  p_chat_id bigint, p_body text
) returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_chat public.chats;
  v_id bigint;
  v_recent int;
begin
  if v_me is null then raise exception 'auth required'; end if;
  select * into v_chat from public.chats where id = p_chat_id;
  if v_chat.id is null then raise exception 'chat_not_found'; end if;
  if v_chat.user_a <> v_me and v_chat.user_b <> v_me then
    raise exception 'not_participant';
  end if;
  if v_chat.status = 'blocked' then raise exception 'chat_blocked'; end if;
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 1000 then
    raise exception 'message_length_out_of_range';
  end if;

  -- rate limit: 60 messages / minute (anti-spam)
  select count(*) into v_recent from public.messages
   where sender_id = v_me and created_at > now() - interval '1 minute';
  if v_recent >= 60 then raise exception 'rate_limit_messages_per_minute'; end if;

  insert into public.messages(chat_id, sender_id, body)
  values (p_chat_id, v_me, p_body)
  returning id into v_id;

  update public.chats
     set last_message_at = now(),
         last_message_preview = substring(p_body, 1, 80)
   where id = p_chat_id;
  return v_id;
end;
$$;

------------------------------------------------------------
-- mark_read(chat_id) — marks all unread messages from the counterpart as read
------------------------------------------------------------
create or replace function public.mark_read(p_chat_id bigint)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
begin
  if v_me is null then return; end if;
  update public.messages
     set read_at = now()
   where chat_id = p_chat_id
     and sender_id <> v_me
     and read_at is null;
end;
$$;

------------------------------------------------------------
-- views — privacy-safe projections that expose only numeric_id
------------------------------------------------------------
create or replace view public.my_chats as
  select
    c.id,
    c.created_at,
    c.last_message_at,
    c.last_message_preview,
    c.status,
    case when c.user_a = auth.uid() then pb.numeric_id else pa.numeric_id end
      as other_numeric_id,
    (select count(*) from public.messages m
      where m.chat_id = c.id
        and m.sender_id <> auth.uid()
        and m.read_at is null) as unread_count
  from public.chats c
  join public.profiles pa on pa.id = c.user_a
  join public.profiles pb on pb.id = c.user_b
  where c.user_a = auth.uid() or c.user_b = auth.uid();

create or replace view public.my_incoming_whispers as
  select
    r.id,
    r.from_user_id,  -- needed only because RLS hides it from non-recipients
    pf.numeric_id as from_numeric_id,
    r.post_id,
    p.body as post_preview,
    r.message,
    r.created_at
  from public.chat_requests r
  join public.profiles pf on pf.id = r.from_user_id
  left join public.posts p on p.id = r.post_id
  where r.to_user_id = auth.uid() and r.status = 'pending';

create or replace view public.messages_for_chat as
  select m.id, m.chat_id, m.sender_id, m.body, m.created_at, m.read_at,
         (m.sender_id = auth.uid()) as is_mine
    from public.messages m
   where exists (
     select 1 from public.chats c
      where c.id = m.chat_id
        and (c.user_a = auth.uid() or c.user_b = auth.uid())
   );

------------------------------------------------------------
-- RLS
------------------------------------------------------------
alter table public.chat_requests enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;

drop policy if exists "see my chat_requests" on public.chat_requests;
create policy "see my chat_requests" on public.chat_requests
  for select using (auth.uid() = from_user_id or auth.uid() = to_user_id);

drop policy if exists "see my chats" on public.chats;
create policy "see my chats" on public.chats
  for select using (auth.uid() = user_a or auth.uid() = user_b);

drop policy if exists "see messages of my chats" on public.messages;
create policy "see messages of my chats" on public.messages
  for select using (
    exists (
      select 1 from public.chats c
       where c.id = messages.chat_id
         and (c.user_a = auth.uid() or c.user_b = auth.uid())
    )
  );

grant select on public.chat_requests, public.chats, public.messages to authenticated;
grant select on public.my_chats, public.my_incoming_whispers, public.messages_for_chat
  to authenticated;
grant execute on function public.request_whisper(bigint, text) to authenticated;
grant execute on function public.respond_whisper_request(bigint, text) to authenticated;
grant execute on function public.send_message(bigint, text) to authenticated;
grant execute on function public.mark_read(bigint) to authenticated;

------------------------------------------------------------
-- Realtime: enable replication on messages so clients can subscribe
------------------------------------------------------------
alter publication supabase_realtime add table public.messages;
