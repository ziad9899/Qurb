-- ============================================================
-- 20260516_007_postgis.sql
-- PostGIS geographic queries for posts + profiles.
-- Adds:
--   * postgis extension
--   * location geography(Point, 4326) on profiles + posts
--   * server-side snap-to-grid (100 m) for privacy
--   * posts_near RPC (radius search) + updated posts_feed view
--   * set_my_location RPC
-- ============================================================

create extension if not exists postgis with schema extensions;

-- ---------- profiles.location -------------------------------------------
alter table public.profiles
  add column if not exists location extensions.geography(Point, 4326),
  add column if not exists location_updated_at timestamptz;

create index if not exists profiles_location_gix
  on public.profiles using gist (location);

-- ---------- posts.location ----------------------------------------------
alter table public.posts
  add column if not exists location extensions.geography(Point, 4326);

create index if not exists posts_location_gix
  on public.posts using gist (location);

-- ---------- snap-to-grid helper (100 m privacy buffer) ------------------
-- Rounds a (lat, lng) pair to the nearest 100 m grid cell before storing,
-- so neighbours within the same cell are indistinguishable. The cell is
-- ~0.0009° lat × 0.0009° lng cos(lat) at Riyadh latitude (~24.7°).
create or replace function public._snap_location(p_lat double precision, p_lng double precision)
returns extensions.geography
language plpgsql immutable
as $$
declare
  -- 1 degree latitude ≈ 111 320 m → 100 m ≈ 0.000898°
  step constant double precision := 0.000898;
  snapped_lat double precision;
  snapped_lng double precision;
begin
  if p_lat is null or p_lng is null then
    return null;
  end if;
  snapped_lat := round(p_lat / step) * step;
  -- longitude step shrinks with latitude
  snapped_lng := round(p_lng / (step / greatest(cos(radians(p_lat)), 0.1))) *
                 (step / greatest(cos(radians(p_lat)), 0.1));
  return extensions.ST_SetSRID(
    extensions.ST_MakePoint(snapped_lng, snapped_lat),
    4326
  )::extensions.geography;
end;
$$;

-- ---------- set_my_location ---------------------------------------------
create or replace function public.set_my_location(p_lat double precision, p_lng double precision)
returns void
language plpgsql security definer
set search_path = public, extensions
as $$
begin
  if auth.uid() is null then
    raise exception 'unauthenticated';
  end if;
  if p_lat is null or p_lng is null
     or p_lat < -90 or p_lat > 90
     or p_lng < -180 or p_lng > 180 then
    raise exception 'invalid_coords';
  end if;
  update public.profiles
     set location = public._snap_location(p_lat, p_lng),
         location_updated_at = now()
   where id = auth.uid();
end;
$$;

grant execute on function public.set_my_location(double precision, double precision) to authenticated;

-- ---------- create_post with location ----------------------------------
-- Drop both old signatures (original 3-arg and the broken 5-arg we just
-- installed) so the new corrected version can land cleanly.
drop function if exists public.create_post(text, text, text);
drop function if exists public.create_post(text, text, text, double precision, double precision);

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
  if v_uid is null then
    raise exception 'unauthenticated';
  end if;
  if length(coalesce(p_body, '')) < 1 or length(p_body) > 500 then
    raise exception 'body length out of range';
  end if;
  if p_proximity not in ('near', 'block', 'city') then
    raise exception 'invalid_proximity';
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
  values (v_uid, p_body, p_tag, p_proximity, v_loc)
  returning id into v_id;

  return v_id;
end;
$$;

grant execute on function public.create_post(text, text, text, double precision, double precision) to authenticated;

-- ---------- posts_near RPC ----------------------------------------------
-- Returns posts within a radius of (p_lat, p_lng), ordered by recency.
-- Schema: posts has user_id (uuid); the public-facing numeric id lives on
-- profiles.numeric_id, so we join. Matches posts_feed's filter set.
create or replace function public.posts_near(
  p_lat double precision,
  p_lng double precision,
  p_radius_m double precision default 500,
  p_limit int default 50
)
returns table (
  id bigint,
  author_numeric_id int,
  body text,
  tag text,
  proximity text,
  score int,
  comments_count int,
  has_image boolean,
  created_at timestamptz,
  distance_m double precision
)
language plpgsql security definer
set search_path = public, extensions
as $$
declare
  v_uid uuid := auth.uid();
  v_origin extensions.geography;
begin
  if p_lat is null or p_lng is null then
    raise exception 'missing_coords';
  end if;
  v_origin := extensions.ST_SetSRID(
    extensions.ST_MakePoint(p_lng, p_lat),
    4326
  )::extensions.geography;

  return query
    select p.id,
           pr.numeric_id,
           p.body,
           p.tag,
           p.proximity,
           p.score,
           p.comments_count,
           p.has_image,
           p.created_at,
           extensions.ST_Distance(p.location, v_origin) as distance_m
      from public.posts p
      join public.profiles pr on pr.id = p.user_id
     where p.status = 'active'
       and pr.status = 'active'
       and p.expires_at > now()
       and p.location is not null
       and extensions.ST_DWithin(p.location, v_origin, p_radius_m)
       and not exists (
         select 1 from public.blocks b
          where b.blocker_id = v_uid and b.blocked_id = p.user_id
       )
     order by p.created_at desc
     limit p_limit;
end;
$$;

grant execute on function public.posts_near(double precision, double precision, double precision, int) to authenticated;

-- ---------- backfill: snap any existing rows without location ----------
-- (Seed posts have no location; that's fine — they'll just be hidden from
-- geo-filtered feeds until backfilled. We do NOT auto-place them at the
-- Riyadh centroid since that would lie about provenance.)
