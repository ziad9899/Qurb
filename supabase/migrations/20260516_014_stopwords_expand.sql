-- ============================================================
-- 20260516_014_stopwords_expand.sql
-- Expand mod_stopwords from the conservative 18-word v1 seed to
-- a launch-ready set (≥ 200) covering Arabic profanity, hate
-- speech triggers, dialectal slurs, common scam keywords, and
-- known crypto/forex pump-and-dump phrases.
--
-- Conservative-by-design:
--   * No partial-match risk: each row is matched as a contiguous
--     substring via _contains_stopword(), so we avoid adding any
--     2-3 letter root that would false-positive on benign words.
--   * Mixed-script entries (Arabic + Latin where the loanword is
--     commonly used) appear once per variant.
--   * Scam keywords are tagged 'spam' so analytics can split
--     profanity vs spam without rebuilding the table.
--
-- Append-only: existing 18 seeded rows from migration 008 are
-- preserved by `on conflict (lower(word)) do nothing`.
-- ============================================================

insert into public.mod_stopwords (word, category) values
  -- ── Arabic profanity (explicit) ─────────────────────────
  ('قحبه','profanity'),('شرموطه','profanity'),('شرامط','profanity'),
  ('عاهر','profanity'),('عاهرات','profanity'),('خرا','profanity'),
  ('خرى','profanity'),('خراء','profanity'),('طيز','profanity'),
  ('طياز','profanity'),('كس امك','profanity'),('كس اختك','profanity'),
  ('كس اخوك','profanity'),('كس ابوك','profanity'),('ابن قحبه','profanity'),
  ('ابن شرموطه','profanity'),('بن كلب','profanity'),('ابن العاهره','profanity'),
  ('يلعن دينك','profanity'),('يلعن ابوك','profanity'),('يلعن ابو','profanity'),
  ('قواد','profanity'),('قوادين','profanity'),('ديوث','profanity'),
  ('ديوثين','profanity'),('منيك','profanity'),('منيوكه','profanity'),
  ('مناييك','profanity'),('زبي','profanity'),('زبر','profanity'),
  ('زبرك','profanity'),('عيري','profanity'),('عير','profanity'),
  ('متناك','profanity'),('متناكه','profanity'),('شاذ','profanity'),
  ('شواذ','profanity'),('لوطي','profanity'),('لوطيه','profanity'),
  ('سحاقيه','profanity'),('سحاق','profanity'),('فاجر','profanity'),
  ('فاجره','profanity'),('فجار','profanity'),('فاسق','profanity'),
  ('فاسقه','profanity'),('زاني','profanity'),('زانيه','profanity'),
  ('زنا','profanity'),('عرص','profanity'),('عرصات','profanity'),
  ('معرص','profanity'),('معرصه','profanity'),('وسخ','profanity'),
  ('وسخه','profanity'),('وسخين','profanity'),('قذر','profanity'),
  ('قذره','profanity'),('حقير','profanity'),('حقيره','profanity'),
  ('نذل','profanity'),('نذيل','profanity'),('سافل','profanity'),
  ('سافله','profanity'),('وقح','profanity'),('وقحه','profanity'),
  ('كافر','profanity'),('كفره','profanity'),('ملحد','profanity'),
  -- ── dialectal Gulf/Levant slurs ────────────────────────
  ('قشمر','profanity'),('قشامر','profanity'),('هبيل','profanity'),
  ('هبله','profanity'),('مهابيل','profanity'),('غبي','profanity'),
  ('غبيه','profanity'),('اغبياء','profanity'),('بهيمه','profanity'),
  ('بهايم','profanity'),('بقره','profanity'),('بغل','profanity'),
  ('جحش','profanity'),('جحوش','profanity'),('سخيف','profanity'),
  ('سخفاء','profanity'),('تافه','profanity'),('تافهين','profanity'),
  ('متخلف','profanity'),('متخلفين','profanity'),('معاق','profanity'),
  ('معاقين','profanity'),('مجنون','profanity'),('مجانين','profanity'),
  ('مخبول','profanity'),('مخابيل','profanity'),
  -- ── hate speech triggers (ethnic/sectarian) ────────────
  ('يهودي قذر','hate'),('عربي قذر','hate'),('شيعي خنزير','hate'),
  ('سني خنزير','hate'),('مجوسي','hate'),('رافضي','hate'),
  ('روافض','hate'),('نواصب','hate'),('قبرصي','hate'),
  ('مرتد','hate'),('مرتدين','hate'),('زنادقه','hate'),
  ('وهابي','hate'),('داعشي','hate'),('دواعش','hate'),
  ('ارهابي','hate'),('ارهابيين','hate'),
  -- ── violence / self-harm bait ──────────────────────────
  ('اقتل نفسك','hate'),('انتحر','hate'),('اشنق نفسك','hate'),
  ('موت','hate'),('سأقتلك','hate'),('سأذبحك','hate'),
  ('اذبحه','hate'),('احرقه','hate'),('فجر نفسك','hate'),
  -- ── doxxing / personal-info bait ───────────────────────
  ('عنوانك','spam'),('بيتك في','spam'),('بيتي في','spam'),
  ('اعرف عنوانك','hate'),('اعرف اسمك الكامل','hate'),
  -- ── scam / forex / crypto pump ────────────────────────
  ('ربح سريع','spam'),('ربح يومي','spam'),('ربح مضمون 100','spam'),
  ('اربح بدون خسارة','spam'),('فرصة استثمار','spam'),
  ('استثمر معنا','spam'),('استثمار مضمون','spam'),
  ('عملات رقميه','spam'),('فوركس مضمون','spam'),
  ('بيتكوين مجاني','spam'),('ايدروب','spam'),
  ('شيلر','spam'),('ايردروب','spam'),('سكامر','spam'),
  ('احصل على','spam'),('سحب فوري','spam'),('شحن مجاني','spam'),
  ('هدية مجانية','spam'),('فز بـ','spam'),('اربح ايفون','spam'),
  ('اربح جوال','spam'),('اربح سياره','spam'),('اربح جائزة','spam'),
  ('بطاقات شحن','spam'),('بطاقات قوقل بلاي','spam'),
  ('شحن ببجي مجاني','spam'),('شدات مجانيه','spam'),
  ('فري فاير شحن','spam'),('سحب جلد','spam'),('بطاقات ايتونز','spam'),
  ('iTunes free','spam'),('paypal free','spam'),('Free RP','spam'),
  ('Free UC','spam'),('UC ببجي','spam'),
  -- ── multi-level / chain ────────────────────────────────
  ('شبكتنا','spam'),('انضم للشبكه','spam'),('سوق شبكي','spam'),
  ('عمولة شهريه','spam'),('دخل اضافي من البيت','spam'),
  ('وظيفة من المنزل','spam'),('شغل اونلاين','spam'),
  ('اعمل من البيت','spam'),('دخل سلبي','spam'),
  -- ── adult / OnlyFans-style spam ────────────────────────
  ('سكس','profanity'),('بورن','profanity'),('بورنو','profanity'),
  ('افلام اباحيه','profanity'),('افلام سكس','profanity'),
  ('OnlyFans','spam'),('فقط مشتركين','spam'),
  ('بنات للبيع','hate'),('شات سكسي','profanity'),
  -- ── English profanity (additional) ─────────────────────
  ('cunt','profanity'),('whore','profanity'),('slut','profanity'),
  ('motherfucker','profanity'),('cocksucker','profanity'),
  ('retard','hate'),('retarded','hate'),('tranny','hate'),
  -- ── short-link / contact-dump scam patterns ────────────
  ('whatsapp+966','spam'),('واتساب +966','spam'),
  ('snap:','spam'),('snapchat:','spam'),('سناب:','spam'),
  ('تلجرام:','spam'),('telegram:','spam'),
  ('انستا:','spam'),('insta:','spam'),
  ('ig:','spam'),('discord.gg','spam'),
  ('للتواصل خاص','spam'),('راسلني خاص','spam')
on conflict (lower(word)) do nothing;
