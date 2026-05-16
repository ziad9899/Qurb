-- ============================================================
-- 20260516_011_comments_realtime.sql
-- Wire `comments` into Realtime so both parties on a post see each
-- other's replies without a manual refresh. Mirrors what migration
-- 004 did for `messages` (whisper chats).
-- ============================================================

-- Idempotent: skip if already added (Supabase Management API runs the
-- whole file inside a single query, so we cannot use `do $$` blocks
-- with version checks — instead use a guarded DO that swallows the
-- "already member" error class.
do $$
begin
  begin
    alter publication supabase_realtime add table public.comments;
  exception
    -- 42710 = duplicate_object (Postgres code) — fired when the table
    -- is already a member of the publication.
    when duplicate_object then null;
  end;
end
$$;
