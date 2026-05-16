-- Minto / قُرب — Phase 6: profile stats, blocks, reports, bookmarks
-- Also: makes posts_feed and comments_for_post block-aware.

set check_function_bodies = off;

------------------------------------------------------------
-- blocks
------------------------------------------------------------
create table if not exists public.blocks (
  blocker_id  uuid not null references public.profiles(id) on delete cascade,
  blocked_id  uuid not null references public.profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create index if not exists blocks_blocker_idx on public.blocks(blocker_id);

------------------------------------------------------------
-- reports
------------------------------------------------------------
create table if not exists public.reports (
  id              bigserial primary key,
  reporter_id     uuid not null references public.profiles(id) on delete cascade,
  target_type     text not null check (target_type in
                    ('post','comment','user','message')),
  target_id       bigint,
  target_user_id  uuid references public.profiles(id) on delete set null,
  reason          text not null check (reason in
                    ('spam','harass','fake','nsfw','private','other')),
  note            text,
  status          text not null default 'open'
                  check (status in ('open','reviewed','dismissed')),
  created_at      timestamptz not null default now()
);

create index if not exists reports_target_idx
  on public.reports(target_type, target_id, created_at);

------------------------------------------------------------
-- bookmarks
------------------------------------------------------------
create table if not exists public.bookmarks (
  user_id     uuid not null references public.profiles(id) on delete cascade,
  post_id     bigint not null references public.posts(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, post_id)
);

create index if not exists bookmarks_user_idx
  on public.bookmarks(user_id, created_at desc);

------------------------------------------------------------
-- block_user_by_post(post_id) — privacy-safe: client doesn't need the UUID
------------------------------------------------------------
create or replace function public.block_user_by_post(p_post_id bigint)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_target uuid;
begin
  if v_me is null then raise exception 'auth required'; end if;
  select user_id into v_target from public.posts where id = p_post_id;
  if v_target is null then raise exception 'post_not_found'; end if;
  if v_target = v_me then raise exception 'cannot_block_self'; end if;
  insert into public.blocks(blocker_id, blocked_id)
  values (v_me, v_target)
  on conflict do nothing;
end;
$$;

------------------------------------------------------------
-- block_user_by_numeric_id — used by Settings → blocked list management
------------------------------------------------------------
create or replace function public.block_user_by_numeric_id(p_numeric_id int)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_target uuid;
begin
  if v_me is null then raise exception 'auth required'; end if;
  select id into v_target from public.profiles where numeric_id = p_numeric_id;
  if v_target is null then raise exception 'user_not_found'; end if;
  if v_target = v_me then raise exception 'cannot_block_self'; end if;
  insert into public.blocks(blocker_id, blocked_id)
  values (v_me, v_target)
  on conflict do nothing;
end;
$$;

------------------------------------------------------------
-- unblock_user_by_numeric_id
------------------------------------------------------------
create or replace function public.unblock_user_by_numeric_id(p_numeric_id int)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_target uuid;
begin
  if v_me is null then raise exception 'auth required'; end if;
  select id into v_target from public.profiles where numeric_id = p_numeric_id;
  if v_target is null then return; end if;
  delete from public.blocks
   where blocker_id = v_me and blocked_id = v_target;
end;
$$;

------------------------------------------------------------
-- file_report(target_type, target_id, reason, note)
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

  -- rate limit: 20 reports / 24h
  select count(*) into v_recent
    from public.reports
   where reporter_id = v_me and created_at > now() - interval '24 hours';
  if v_recent >= 20 then raise exception 'rate_limit_reports_per_day'; end if;

  -- derive target_user_id for post / comment so moderation can see whose
  -- content is reported even after status changes.
  if p_target_type = 'post' then
    select user_id into v_target_user from public.posts where id = p_target_id;
  elsif p_target_type = 'comment' then
    select user_id into v_target_user from public.comments where id = p_target_id;
  end if;

  insert into public.reports(
    reporter_id, target_type, target_id, target_user_id, reason, note
  ) values (
    v_me, p_target_type, p_target_id, v_target_user, p_reason,
    nullif(p_note, '')
  )
  returning id into v_id;

  -- auto-hide post/comment if reports cross 3 in 24h
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

------------------------------------------------------------
-- toggle_bookmark(post_id) — returns new state (true = bookmarked)
------------------------------------------------------------
create or replace function public.toggle_bookmark(p_post_id bigint)
returns boolean
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
  v_count int;
begin
  if v_me is null then raise exception 'auth required'; end if;
  with d as (
    delete from public.bookmarks
     where user_id = v_me and post_id = p_post_id
     returning 1
  )
  select count(*) into v_count from d;
  if v_count > 0 then return false; end if;
  insert into public.bookmarks(user_id, post_id) values (v_me, p_post_id)
  on conflict do nothing;
  return true;
end;
$$;

------------------------------------------------------------
-- my_stats() — for the Profile hero
------------------------------------------------------------
create or replace function public.my_stats()
returns table(
  posts_count int,
  comments_count int,
  karma int,
  blocked_count int,
  bookmarks_count int
)
language sql stable security invoker
set search_path = public, pg_temp
as $$
  select
    (select count(*)::int from public.posts
       where user_id = auth.uid() and status = 'active'),
    (select count(*)::int from public.comments
       where user_id = auth.uid() and status = 'active'),
    coalesce(
      (select sum(score)::int from public.posts
         where user_id = auth.uid() and status = 'active'), 0)
    + coalesce(
      (select sum(score)::int from public.comments
         where user_id = auth.uid() and status = 'active'), 0),
    (select count(*)::int from public.blocks
       where blocker_id = auth.uid()),
    (select count(*)::int from public.bookmarks
       where user_id = auth.uid());
$$;

------------------------------------------------------------
-- delete_my_account() — cascades through FKs
------------------------------------------------------------
create or replace function public.delete_my_account()
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_me uuid := auth.uid();
begin
  if v_me is null then raise exception 'auth required'; end if;
  delete from auth.users where id = v_me;
end;
$$;

------------------------------------------------------------
-- views — profile tabs + block list
------------------------------------------------------------
create or replace view public.my_posts as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at, p.status,
    pr.numeric_id as author_numeric_id
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.user_id = auth.uid();

create or replace view public.my_comment_threads as
  select
    c.id, c.post_id, c.parent_id, c.body, c.score, c.created_at,
    pr.numeric_id as author_numeric_id,
    (select substring(p.body, 1, 80) from public.posts p where p.id = c.post_id)
      as post_preview
  from public.comments c
  join public.profiles pr on pr.id = c.user_id
  where c.user_id = auth.uid();

create or replace view public.my_bookmarks as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at,
    pr.numeric_id as author_numeric_id,
    bk.created_at as bookmarked_at
  from public.bookmarks bk
  join public.posts p on p.id = bk.post_id
  join public.profiles pr on pr.id = p.user_id
  where bk.user_id = auth.uid() and p.status = 'active';

create or replace view public.my_blocks as
  select
    b.created_at,
    pr.numeric_id as blocked_numeric_id,
    pr.id as blocked_id
  from public.blocks b
  join public.profiles pr on pr.id = b.blocked_id
  where b.blocker_id = auth.uid();

------------------------------------------------------------
-- Make posts_feed and comments_for_post block-aware.
------------------------------------------------------------
create or replace view public.posts_feed as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at,
    pr.numeric_id as author_numeric_id
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.status = 'active'
    and pr.status = 'active'
    and p.expires_at > now()
    and not exists (
      select 1 from public.blocks b
       where b.blocker_id = auth.uid() and b.blocked_id = p.user_id
    );

create or replace view public.comments_for_post as
  select
    c.id, c.post_id, c.parent_id, c.body, c.score, c.created_at,
    pr.numeric_id as author_numeric_id
  from public.comments c
  join public.profiles pr on pr.id = c.user_id
  where c.status = 'active'
    and pr.status = 'active'
    and not exists (
      select 1 from public.blocks b
       where b.blocker_id = auth.uid() and b.blocked_id = c.user_id
    );

------------------------------------------------------------
-- RLS
------------------------------------------------------------
alter table public.blocks enable row level security;
alter table public.reports enable row level security;
alter table public.bookmarks enable row level security;

drop policy if exists "see my blocks" on public.blocks;
create policy "see my blocks" on public.blocks
  for select using (auth.uid() = blocker_id);

drop policy if exists "see my reports" on public.reports;
create policy "see my reports" on public.reports
  for select using (auth.uid() = reporter_id);

drop policy if exists "see my bookmarks" on public.bookmarks;
create policy "see my bookmarks" on public.bookmarks
  for select using (auth.uid() = user_id);

grant select on public.blocks, public.reports, public.bookmarks to authenticated;
grant select on
  public.my_posts, public.my_comment_threads, public.my_bookmarks,
  public.my_blocks
  to authenticated;
grant execute on function public.block_user_by_post(bigint) to authenticated;
grant execute on function public.block_user_by_numeric_id(int) to authenticated;
grant execute on function public.unblock_user_by_numeric_id(int) to authenticated;
grant execute on function public.file_report(text, bigint, text, text)
  to authenticated;
grant execute on function public.toggle_bookmark(bigint) to authenticated;
grant execute on function public.my_stats() to authenticated;
grant execute on function public.delete_my_account() to authenticated;
