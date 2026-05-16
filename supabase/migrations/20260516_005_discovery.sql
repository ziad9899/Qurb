-- Minto / قُرب — Phase 5: Discovery (notifications + communities + trending)

set check_function_bodies = off;

------------------------------------------------------------
-- notifications
------------------------------------------------------------
create table if not exists public.notifications (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete cascade,
  kind              text not null check (kind in (
                      'reply','reply_to_comment','vote_milestone',
                      'whisper_request','pulse','tag_trending'
                    )),
  actor_numeric_id  int,
  target_type       text check (target_type in ('post','comment','chat_request','tag')),
  target_id         bigint,
  body              text,
  metadata          jsonb default '{}'::jsonb,
  read_at           timestamptz,
  created_at        timestamptz not null default now()
);

create index if not exists notifications_user_recent_idx
  on public.notifications(user_id, created_at desc);
create index if not exists notifications_user_unread_idx
  on public.notifications(user_id, created_at desc)
  where read_at is null;

------------------------------------------------------------
-- communities (static catalogue for the Explore screen)
------------------------------------------------------------
create table if not exists public.communities (
  id          bigserial primary key,
  slug        text unique not null,
  name        text not null,
  description text,
  hue         int not null,
  members     int not null default 0,
  created_at  timestamptz not null default now()
);

insert into public.communities (slug, name, description, hue, members) values
  ('dawn',      'الفجر',          'ناس الفجر',             38,  4280),
  ('stories',   'حكايات الحي',    'قصصنا اليومية',         354, 8920),
  ('cafes',     'كافيهات',        'مراجعات وأماكن',        18,  12400),
  ('help',      'ساعدوني',        'مساعدة عاجلة',          156, 3450),
  ('lost',      'مفقودات',        'بالحي والمدينة',        198, 1820),
  ('rents',     'إيجارات',        'أسعار وعروض',           262, 6780)
on conflict (slug) do nothing;

------------------------------------------------------------
-- trending_tags — aggregate posts of the last hour, ranked
------------------------------------------------------------
create or replace view public.trending_tags as
  with base as (
    select
      p.tag,
      count(*) as total,
      count(*) filter (where p.created_at > now() - interval '30 minutes') as recent,
      max(p.created_at) as last_at
    from public.posts p
    where p.tag is not null
      and p.status = 'active'
      and p.created_at > now() - interval '24 hours'
    group by p.tag
  ),
  prior as (
    select
      p.tag,
      count(*) filter (where p.created_at between now() - interval '1 hour'
                                              and now() - interval '30 minutes') as prior
    from public.posts p
    where p.tag is not null and p.status = 'active'
      and p.created_at > now() - interval '1 hour'
    group by p.tag
  )
  select
    b.tag,
    b.total::int as post_count,
    b.recent::int as recent_count,
    coalesce(pr.prior, 0)::int as prior_count,
    case
      when b.recent > coalesce(pr.prior, 0) then 'up'
      when b.recent < coalesce(pr.prior, 0) then 'down'
      else 'flat'
    end as direction,
    b.last_at
  from base b
  left join prior pr on pr.tag = b.tag
  order by b.recent desc, b.total desc
  limit 12;

grant select on public.trending_tags to anon, authenticated;
grant select on public.communities to anon, authenticated;

------------------------------------------------------------
-- search_posts(query, limit) — Arabic-aware ILIKE search.
-- (Full-text Arabic config is post-MVP; ILIKE works fine at this scale.)
------------------------------------------------------------
create or replace function public.search_posts(p_query text, p_limit int default 30)
returns setof public.posts_feed
language sql stable
set search_path = public, pg_temp
as $$
  select pf.* from public.posts_feed pf
   where pf.body ilike '%' || p_query || '%'
      or pf.tag  ilike '%' || p_query || '%'
   order by pf.created_at desc
   limit greatest(1, least(p_limit, 50));
$$;

grant execute on function public.search_posts(text, int) to anon, authenticated;

------------------------------------------------------------
-- Triggers — fan out notifications
------------------------------------------------------------

-- When a comment is added: notify the post author (unless it's their own
-- comment); if the comment is a reply to another comment, also notify the
-- parent comment's author.
create or replace function public._notif_on_comment()
returns trigger
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_post_author uuid;
  v_actor_numeric int;
  v_parent_author uuid;
  v_body_preview text;
begin
  select user_id into v_post_author from public.posts where id = new.post_id;
  select numeric_id into v_actor_numeric from public.profiles where id = new.user_id;
  v_body_preview := substring(new.body, 1, 80);

  if v_post_author is not null and v_post_author <> new.user_id then
    insert into public.notifications(
      user_id, kind, actor_numeric_id, target_type, target_id, body
    ) values (
      v_post_author, 'reply', v_actor_numeric, 'comment', new.id,
      v_body_preview
    );
  end if;

  if new.parent_id is not null then
    select user_id into v_parent_author
      from public.comments where id = new.parent_id;
    if v_parent_author is not null
       and v_parent_author <> new.user_id
       and v_parent_author <> v_post_author then
      insert into public.notifications(
        user_id, kind, actor_numeric_id, target_type, target_id, body
      ) values (
        v_parent_author, 'reply_to_comment', v_actor_numeric, 'comment', new.id,
        v_body_preview
      );
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists comments_notify_trg on public.comments;
create trigger comments_notify_trg
  after insert on public.comments
  for each row execute function public._notif_on_comment();

-- When a whisper request lands, notify the recipient.
create or replace function public._notif_on_whisper_request()
returns trigger
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_numeric int;
begin
  if new.status <> 'pending' then return new; end if;
  select numeric_id into v_actor_numeric
    from public.profiles where id = new.from_user_id;
  insert into public.notifications(
    user_id, kind, actor_numeric_id, target_type, target_id, body
  ) values (
    new.to_user_id, 'whisper_request', v_actor_numeric, 'chat_request',
    new.id, substring(coalesce(new.message, 'بدأ همساً معك'), 1, 120)
  );
  return new;
end;
$$;

drop trigger if exists whisper_requests_notify_trg on public.chat_requests;
create trigger whisper_requests_notify_trg
  after insert on public.chat_requests
  for each row execute function public._notif_on_whisper_request();

------------------------------------------------------------
-- RPCs
------------------------------------------------------------
create or replace function public.mark_notification_read(p_notif_id bigint)
returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
begin
  update public.notifications
     set read_at = coalesce(read_at, now())
   where id = p_notif_id and user_id = auth.uid();
end;
$$;

create or replace function public.mark_all_notifications_read()
returns int
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_count int;
begin
  with upd as (
    update public.notifications
       set read_at = now()
     where user_id = auth.uid() and read_at is null
     returning 1
  )
  select count(*) into v_count from upd;
  return v_count;
end;
$$;

grant execute on function public.mark_notification_read(bigint) to authenticated;
grant execute on function public.mark_all_notifications_read() to authenticated;

------------------------------------------------------------
-- RLS
------------------------------------------------------------
alter table public.notifications enable row level security;

drop policy if exists "see my notifications" on public.notifications;
create policy "see my notifications" on public.notifications
  for select using (auth.uid() = user_id);

grant select on public.notifications to authenticated;
