-- ============================================================
-- 20260516_012_posts_feed_edited_at.sql
-- Migration 010 added posts.edited_at but didn't republish the
-- posts_feed view, so reads through the view still rejected
-- `select edited_at`. Rebuild posts_feed with the new column.
-- ============================================================

create or replace view public.posts_feed as
  select
    p.id, p.body, p.tag, p.proximity, p.score, p.comments_count,
    p.has_image, p.created_at, p.expires_at,
    pr.numeric_id as author_numeric_id,
    p.edited_at
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.status = 'active'
    and pr.status = 'active'
    and p.expires_at > now()
    and not exists (
      select 1 from public.blocks b
       where b.blocker_id = auth.uid() and b.blocked_id = p.user_id
    );
