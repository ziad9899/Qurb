-- Minto / قُرب — Phase 3 schema
-- posts + comments + votes + cast_vote/create_post/create_comment RPCs
-- Strategy: all writes go through SECURITY DEFINER RPCs so the client never
-- INSERTs directly. This makes rate-limiting and validation server-enforced.

set check_function_bodies = off;

------------------------------------------------------------
-- posts
------------------------------------------------------------
create table if not exists public.posts (
  id              bigserial primary key,
  user_id         uuid not null references public.profiles(id) on delete cascade,
  body            text not null check (char_length(body) between 1 and 500),
  tag             text,
  proximity       text not null check (proximity in ('near','block','city')),
  score           integer not null default 0,
  comments_count  integer not null default 0,
  has_image       boolean not null default false,
  status          text not null default 'active' check (status in ('active','hidden','removed')),
  created_at      timestamptz not null default now(),
  expires_at      timestamptz not null default (now() + interval '24 hours')
);

create index if not exists posts_active_created_idx
  on public.posts(created_at desc) where status = 'active';
create index if not exists posts_user_idx on public.posts(user_id);
create index if not exists posts_active_hot_idx
  on public.posts(score desc, created_at desc) where status = 'active';

------------------------------------------------------------
-- comments  (1-level threading: parent_id may reference another comment)
------------------------------------------------------------
create table if not exists public.comments (
  id          bigserial primary key,
  post_id     bigint not null references public.posts(id) on delete cascade,
  parent_id   bigint references public.comments(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 500),
  score       integer not null default 0,
  status      text not null default 'active' check (status in ('active','hidden','removed')),
  created_at  timestamptz not null default now()
);

create index if not exists comments_post_idx on public.comments(post_id, created_at);
create index if not exists comments_user_idx on public.comments(user_id);

------------------------------------------------------------
-- votes
------------------------------------------------------------
create table if not exists public.votes (
  user_id     uuid not null references public.profiles(id) on delete cascade,
  target_type text not null check (target_type in ('post','comment')),
  target_id   bigint not null,
  value       smallint not null check (value in (-1, 1)),
  created_at  timestamptz not null default now(),
  primary key (user_id, target_type, target_id)
);

create index if not exists votes_target_idx on public.votes(target_type, target_id);

------------------------------------------------------------
-- cast_vote(target_type, target_id, value)
-- value: 1 = up, -1 = down, 0 = clear
-- returns the new score for the target.
------------------------------------------------------------
create or replace function public.cast_vote(
  p_target_type text,
  p_target_id bigint,
  p_value smallint
) returns int
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_old smallint;
  v_delta int := 0;
  v_score int;
begin
  if v_uid is null then raise exception 'auth required'; end if;
  if p_target_type not in ('post','comment') then raise exception 'bad target_type'; end if;
  if p_value not in (-1::smallint, 0::smallint, 1::smallint) then raise exception 'bad value'; end if;

  select value into v_old from public.votes
   where user_id = v_uid and target_type = p_target_type and target_id = p_target_id;

  if p_value = 0 then
    if v_old is not null then
      delete from public.votes
       where user_id = v_uid and target_type = p_target_type and target_id = p_target_id;
      v_delta := -v_old;
    end if;
  else
    if v_old is null then
      insert into public.votes(user_id, target_type, target_id, value)
      values (v_uid, p_target_type, p_target_id, p_value);
      v_delta := p_value;
    elsif v_old <> p_value then
      update public.votes
         set value = p_value, created_at = now()
       where user_id = v_uid and target_type = p_target_type and target_id = p_target_id;
      v_delta := p_value - v_old;
    end if;
  end if;

  if p_target_type = 'post' then
    update public.posts set score = score + v_delta
     where id = p_target_id returning score into v_score;
  else
    update public.comments set score = score + v_delta
     where id = p_target_id returning score into v_score;
  end if;
  return coalesce(v_score, 0);
end;
$$;

------------------------------------------------------------
-- create_post(body, tag, proximity) — enforces rate limits, validation
------------------------------------------------------------
create or replace function public.create_post(
  p_body text,
  p_tag text,
  p_proximity text
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
  if p_proximity not in ('near','block','city') then raise exception 'bad proximity'; end if;
  if char_length(coalesce(p_body, '')) < 1 or char_length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;

  -- rate limit: 10 posts / 24h
  select count(*) into v_recent
    from public.posts
   where user_id = v_uid and created_at > now() - interval '24 hours';
  if v_recent >= 10 then raise exception 'rate_limit_posts_per_day'; end if;

  insert into public.posts(user_id, body, tag, proximity)
  values (v_uid, p_body, nullif(p_tag, ''), p_proximity)
  returning id into v_id;
  return v_id;
end;
$$;

------------------------------------------------------------
-- create_comment(post_id, parent_id, body)
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

------------------------------------------------------------
-- feed view that joins author's numeric_id (needed for IDBadge display)
------------------------------------------------------------
create or replace view public.posts_feed as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at,
    pr.numeric_id as author_numeric_id
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.status = 'active' and pr.status = 'active' and p.expires_at > now();

create or replace view public.comments_for_post as
  select
    c.id, c.post_id, c.parent_id, c.body, c.score, c.created_at,
    pr.numeric_id as author_numeric_id
  from public.comments c
  join public.profiles pr on pr.id = c.user_id
  where c.status = 'active' and pr.status = 'active';

------------------------------------------------------------
-- RLS — clients never INSERT directly; SECURITY DEFINER RPCs do.
------------------------------------------------------------
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.votes enable row level security;

drop policy if exists "read active posts" on public.posts;
create policy "read active posts" on public.posts
  for select using (status = 'active');

drop policy if exists "update own posts" on public.posts;
create policy "update own posts" on public.posts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "read active comments" on public.comments;
create policy "read active comments" on public.comments
  for select using (status = 'active');

drop policy if exists "read own votes" on public.votes;
create policy "read own votes" on public.votes
  for select using (auth.uid() = user_id);

grant select on public.posts to anon, authenticated;
grant select on public.comments to anon, authenticated;
grant select on public.votes to authenticated;
grant select on public.posts_feed to anon, authenticated;
grant select on public.comments_for_post to anon, authenticated;

grant execute on function public.cast_vote(text, bigint, smallint) to authenticated;
grant execute on function public.create_post(text, text, text) to authenticated;
grant execute on function public.create_comment(bigint, bigint, text) to authenticated;
