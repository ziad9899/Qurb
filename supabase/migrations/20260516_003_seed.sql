-- Seed posts for Phase 3 — gives the feed something to look at on first run.
-- Creates 5 anonymous users (the on_auth_user_created trigger creates their
-- profiles automatically), forces their numeric_ids to match the web mockup,
-- then inserts the 5 mock posts on their behalf.

do $$
declare
  u1 uuid := gen_random_uuid();
  u2 uuid := gen_random_uuid();
  u3 uuid := gen_random_uuid();
  u4 uuid := gen_random_uuid();
  u5 uuid := gen_random_uuid();
begin
  -- Only seed once
  if exists (select 1 from public.posts where body like 'إذا أحد يبي يطلع في الفجر%') then
    return;
  end if;

  insert into auth.users (instance_id, id, aud, role, is_anonymous, created_at, updated_at,
                          raw_app_meta_data, raw_user_meta_data)
  values
    ('00000000-0000-0000-0000-000000000000'::uuid, u1, 'authenticated', 'authenticated', true,
     now(), now(), '{"seed":true}'::jsonb, '{}'::jsonb),
    ('00000000-0000-0000-0000-000000000000'::uuid, u2, 'authenticated', 'authenticated', true,
     now(), now(), '{"seed":true}'::jsonb, '{}'::jsonb),
    ('00000000-0000-0000-0000-000000000000'::uuid, u3, 'authenticated', 'authenticated', true,
     now(), now(), '{"seed":true}'::jsonb, '{}'::jsonb),
    ('00000000-0000-0000-0000-000000000000'::uuid, u4, 'authenticated', 'authenticated', true,
     now(), now(), '{"seed":true}'::jsonb, '{}'::jsonb),
    ('00000000-0000-0000-0000-000000000000'::uuid, u5, 'authenticated', 'authenticated', true,
     now(), now(), '{"seed":true}'::jsonb, '{}'::jsonb);

  -- Override numeric_ids to match the web design's iconic IDs.
  update public.profiles set numeric_id = 45821 where id = u1;
  update public.profiles set numeric_id = 77103 where id = u2;
  update public.profiles set numeric_id = 32940 where id = u3;
  update public.profiles set numeric_id = 91206 where id = u4;
  update public.profiles set numeric_id = 58471 where id = u5;

  insert into public.posts (user_id, body, tag, proximity, score, comments_count, created_at, expires_at)
  values
    (u1,
     'إذا أحد يبي يطلع في الفجر، فيه أمكنة بالحي تخوّف من الهدوء... جربتها أمس وكأن البلد لي وحدي.',
     'حكايات', 'near', 124, 0,
     now() - interval '14 minutes', now() + interval '24 hours'),
    (u2,
     'صار لي 3 سنين أعيش في نفس العمارة، أمس فقط اكتشفت إن الجار اللي تحتي يشتغل طباخ في نفس المطعم اللي أحبه. كم سنة ضاعت بدون "هاي" بسيطة.',
     'مشاعر', 'block', 482, 0,
     now() - interval '32 minutes', now() + interval '24 hours'),
    (u3,
     'الغروب الحين فوق الحي... لو شخص ثاني شافه يرفع يده.',
     'لحظة', 'near', 67, 0,
     now() - interval '47 minutes', now() + interval '24 hours'),
    (u4,
     'سؤال جدي: ليش الكافيهات الجديدة كلها نفس الطابع؟ نفس الكراسي، نفس الإضاءة، نفس قائمة المشروبات. وين الأصالة؟',
     'نقاش', 'city', 1200, 0,
     now() - interval '88 minutes', now() + interval '24 hours'),
    (u5,
     'فقدت محفظتي قرب البقالة الكبيرة. إذا أحد لقاها — فيها شي مهم جداً غير الفلوس.',
     'مساعدة', 'block', 245, 0,
     now() - interval '120 minutes', now() + interval '24 hours');
end $$;
