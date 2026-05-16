-- ============================================================
-- 20260516_010_post_owner_ops.sql
-- Owner-only edit + soft-delete RPCs for posts.
--   * update_my_post(post_id, body): rewrites body, runs moderation,
--     stamps edited_at. Only the author may call it.
--   * delete_my_post(post_id): soft-deletes (status='removed') so the
--     post drops out of posts_feed but rows referenced by votes /
--     comments / reports remain referentially intact.
--
-- Pattern (validated against Supabase RLS guidance + SECURITY DEFINER
-- best practice): all writes go through SECURITY DEFINER RPCs that
-- check `auth.uid() = posts.user_id`. The posts table's existing
-- update RLS policy already covers direct UPDATE, but routing through
-- an RPC lets us run moderation + length checks server-side.
-- ============================================================

alter table public.posts
  add column if not exists edited_at timestamptz;

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
     set body = p_body,
         edited_at = now()
   where id = p_post_id;
end;
$$;

grant execute on function public.update_my_post(bigint, text) to authenticated;

create or replace function public.delete_my_post(
  p_post_id bigint
) returns void
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then raise exception 'unauthenticated'; end if;
  select user_id into v_owner from public.posts where id = p_post_id;
  if v_owner is null then raise exception 'post_not_found'; end if;
  if v_owner <> v_uid then raise exception 'not_post_owner'; end if;

  -- Soft delete: drops the post from posts_feed (which filters
  -- status='active') but preserves referential integrity for votes,
  -- comments, and any reports already filed.
  update public.posts set status = 'removed' where id = p_post_id;
end;
$$;

grant execute on function public.delete_my_post(bigint) to authenticated;
