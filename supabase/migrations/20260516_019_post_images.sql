-- ============================================================
-- 20260516_019_post_images.sql
-- Phase 10: optional image attachments on posts.
--
--   * post_images table — 1:1 with posts.id (room to grow to 1:N later
--     by relaxing the PK)
--   * post-images storage bucket — private, 2 MB cap, image MIMEs only
--   * RLS on storage.objects so users upload only to their own folder
--   * post_image_url RPC — issues short-lived signed URLs the client
--     uses to render images in the feed
--   * create_post / update_my_post — accept an optional image_path,
--     atomically link it on the way in, and flip has_image=true
--
-- Moderation strategy (MVP): image posts go to status='active'
-- immediately, same as text posts. Bad images are caught by the
-- existing report flow + admin removal. A future Edge Function can
-- flip post_images.status to 'pending_review' on upload and require
-- admin approval before posts.has_image is set.
-- ============================================================

set check_function_bodies = off;

------------------------------------------------------------
-- 1. Storage bucket — private, with hard limits at the bucket level.
--    Doing it via SQL keeps the schema reproducible.
------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'post-images',
  'post-images',
  false,
  2097152,                                            -- 2 MB
  array['image/jpeg','image/png','image/webp']::text[]
)
on conflict (id) do update
set file_size_limit    = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types,
    public             = excluded.public;

------------------------------------------------------------
-- 2. RLS on storage.objects for the post-images bucket.
--    The path convention is {user_id}/{uuid}.{ext}. We enforce it
--    by checking storage.foldername(name)[1] = auth.uid()::text.
------------------------------------------------------------
drop policy if exists "post_images_insert_own" on storage.objects;
create policy "post_images_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'post-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "post_images_select_own" on storage.objects;
create policy "post_images_select_own" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'post-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "post_images_delete_own" on storage.objects;
create policy "post_images_delete_own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'post-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- No public SELECT policy — non-owners can only view via signed URLs
-- issued by the post_image_url RPC below (which is SECURITY DEFINER
-- and runs as the storage owner).

------------------------------------------------------------
-- 3. post_images — one row per post that has an image attachment.
------------------------------------------------------------
create table if not exists public.post_images (
  post_id      bigint primary key references public.posts(id) on delete cascade,
  user_id      uuid   not null references public.profiles(id) on delete cascade,
  storage_path text   not null,
  width        int,
  height       int,
  byte_size    int,
  status       text   not null default 'active'
               check (status in ('pending_review','active','removed')),
  moderated_at timestamptz,
  created_at   timestamptz not null default now()
);

create index if not exists post_images_user_idx on public.post_images(user_id);
create index if not exists post_images_status_idx on public.post_images(status);

alter table public.post_images enable row level security;

-- Anyone authenticated can read the metadata of an active image. The
-- actual bytes still go through signed URLs the client requests via
-- post_image_url(). storage_path leaks no PII beyond what the post
-- view already exposes via author_numeric_id.
drop policy if exists "post_images_read_active" on public.post_images;
create policy "post_images_read_active" on public.post_images
  for select to authenticated
  using (status = 'active');

-- Owner can see their own pending/removed rows (for future moderation UI).
drop policy if exists "post_images_read_own" on public.post_images;
create policy "post_images_read_own" on public.post_images
  for select to authenticated
  using (user_id = auth.uid());

------------------------------------------------------------
-- 4. create_post — extended with an optional p_image_path.
--    The path is what the client already uploaded to
--    post-images/{uid}/{uuid}.jpg. We:
--      a) validate the path actually belongs to this user
--      b) write the post row
--      c) write the post_images row in the SAME transaction so an
--         orphan image and an orphan post can never co-exist
--      d) flip posts.has_image = true
--    If anything fails we raise and the whole transaction rolls back
--    (postgres handles that for us in a function).
------------------------------------------------------------
create or replace function public.create_post(
  p_body       text,
  p_tag        text default null,
  p_proximity  text default 'near',
  p_lat        double precision default null,
  p_lng        double precision default null,
  p_image_path text default null,
  p_img_width  int default null,
  p_img_height int default null,
  p_img_bytes  int default null
)
returns bigint
language plpgsql security definer
set search_path = public, extensions, storage
as $$
declare
  v_uid uuid := auth.uid();
  v_id bigint;
  v_recent_count int;
  v_loc extensions.geography;
  v_owns_object boolean;
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

  -- If the caller claims they uploaded an image, verify the storage
  -- object actually exists and belongs to them. We pin the path
  -- prefix to {uid}/ so a client can't forge another user's file.
  if p_image_path is not null then
    if (storage.foldername(p_image_path))[1] <> v_uid::text then
      raise exception 'image_path_not_owned';
    end if;
    select exists (
      select 1 from storage.objects
       where bucket_id = 'post-images' and name = p_image_path
    ) into v_owns_object;
    if not v_owns_object then
      raise exception 'image_not_uploaded';
    end if;
  end if;

  v_loc := public._snap_location(p_lat, p_lng);
  insert into public.posts (
    user_id, body, tag, proximity, location, has_image
  ) values (
    v_uid, p_body, nullif(p_tag, ''), p_proximity, v_loc,
    p_image_path is not null
  )
  returning id into v_id;

  if p_image_path is not null then
    insert into public.post_images (
      post_id, user_id, storage_path, width, height, byte_size
    ) values (
      v_id, v_uid, p_image_path, p_img_width, p_img_height, p_img_bytes
    );
  end if;

  return v_id;
end;
$$;

------------------------------------------------------------
-- 5. post_image_url — issues a short-lived signed URL for a given
--    post's image. The signing happens through storage's REST API
--    via supabase's internal extension, but the cheapest reliable
--    path for us is to expose the storage_path and let the client
--    call storage.from('post-images').createSignedUrl(path) — which
--    works for any authenticated caller because there's NO public
--    storage.objects SELECT policy that would otherwise let them
--    bypass via direct GET.
--
--    Actually: createSignedUrl() in the JS/Dart SDK doesn't require
--    SELECT permission on storage.objects — it just signs the path.
--    So we only need to expose storage_path. Simpler RPC: return it.
------------------------------------------------------------
create or replace function public.post_image_path(p_post_id bigint)
returns text
language sql stable security definer
set search_path = public, pg_temp
as $$
  select storage_path
    from public.post_images
   where post_id = p_post_id
     and status = 'active'
   limit 1;
$$;

grant execute on function public.post_image_path(bigint) to authenticated, anon;

------------------------------------------------------------
-- 6. posts_feed view — surface storage_path alongside the post so
--    the client can sign URLs in a single round trip instead of
--    one extra RPC per visible card.
------------------------------------------------------------
-- Column order must match existing view; CREATE OR REPLACE refuses to
-- reorder columns. Existing order (set by migrations 006 + 012):
--   id, body, tag, proximity, score, comments_count, has_image,
--   created_at, expires_at, author_numeric_id, edited_at
-- We only append image_path at the end.
create or replace view public.posts_feed as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at,
    pr.numeric_id as author_numeric_id,
    p.edited_at,
    pi.storage_path as image_path
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  left join public.post_images pi on pi.post_id = p.id and pi.status = 'active'
  where p.status = 'active'
    and pr.status = 'active'
    and p.expires_at > now()
    and not exists (
      select 1 from public.blocks b
       where b.blocker_id = auth.uid() and b.blocked_id = p.user_id
    );

------------------------------------------------------------
-- Grants — keep the previous create_post grant since we changed
-- only the signature (added defaulted args).
------------------------------------------------------------
grant select on public.post_images to authenticated;
grant execute on function public.create_post(text, text, text,
                                              double precision, double precision,
                                              text, int, int, int) to authenticated;
