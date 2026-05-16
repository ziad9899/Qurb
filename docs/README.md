# Privacy Policy hosting — للنشر العام

`privacy.html` ملف HTML واحد ثنائي اللغة (عربي افتراضي + إنجليزي بنقرة) جاهز للنشر. Apple تطلب URL عام قابل للوصول لإكمال نموذج App Store Connect.

## التحقّق من Supabase Storage (لا يعمل لـ HTML)

الملف مرفوع فعلاً على:

```
https://ulojulpdlleisymszamf.supabase.co/storage/v1/object/public/legal/privacy.html
```

**لكن** Supabase Storage يفرض `Content-Type: text/plain` + `X-Content-Type-Options: nosniff` على كل HTML على نطاقه المشترك `*.supabase.co` لمنع XSS — وهذا يجعل المتصفحات تعرض شيفرة HTML الخام بدلاً من الصفحة المُنسَّقة. مراجع Apple سيرى نصاً عشوائياً. **لا تستعمل هذا الرابط للـ submit**.

التجربة موثقة في الـ commit التاريخ وفي `_qa/setup_legal_bucket.ps1`. الـ workaround الوحيدة هي نطاق مخصّص + Supabase Custom Hostnames (ميزة مدفوعة) — غير مستحقّة لصفحة HTML واحدة.

## ثلاثة خيارات نشر مجانية تعمل اليوم

### الخيار 1 — GitHub Pages (الأنظف، 5 دقائق)
هذا الاختيار الأفضل إذا كان عندك حساب GitHub.

```bash
# في الـ terminal من جذر المشروع:
gh repo create qurb-legal --public --source=docs --remote=legal --push
gh api repos/{owner}/qurb-legal/pages -f source[branch]=main -f source[path]=/
```

الرابط النهائي:
```
https://{username}.github.io/qurb-legal/privacy.html
```

أو يدوياً: أنشئ ريبو على github.com، ارفع `docs/privacy.html`، فعّل Pages من Settings ‹ Pages.

### الخيار 2 — Netlify Drop (الأسرع، بدون تسجيل أولي)
1. افتح <https://app.netlify.com/drop>
2. اسحب مجلد `docs/` كاملاً
3. تحصل على رابط `https://random-name-12345.netlify.app/privacy.html` فوراً
4. (اختياري) سجّل دخول لتثبيت الرابط دائماً

### الخيار 3 — Cloudflare Pages (الأقوى للإنتاج)
1. <https://dash.cloudflare.com/pages>
2. "Create a project" ‹ "Direct Upload"
3. ارفع `docs/`
4. رابط `https://qurb-legal.pages.dev/privacy.html`

## تحديث محتوى السياسة

عدّل `privacy.html` محلياً ثم أعِد التشغيل:

- GitHub Pages: `git add . && git commit && git push` → يحدّث خلال 30 ثانية
- Netlify: اسحب الملف مرة أخرى إلى لوحة Netlify
- Supabase Storage: شغّل `_qa/setup_legal_bucket.ps1` (يستعمل `x-upsert: true`)

## ربط الرابط داخل التطبيق

عند تثبيت الرابط النهائي، حدّث `lib/features/legal/privacy_policy_screen.dart` ليفتحه عبر `url_launcher`، أو اتركه يعرض نسخة داخل التطبيق كاحتياط (الموجودة حالياً تطابق نص HTML).

## مرجع App Store

نموذج "App Privacy" في App Store Connect يطلب:
1. **Privacy Policy URL** ← هذا الرابط
2. **App Privacy** (إعلانات نوع البيانات المجمَّعة)

كل البيانات التي تجمعها التطبيق مذكورة في `PrivacyInfo.xcprivacy` كنقطة بداية لإعلان "Data Types" في App Store Connect.
