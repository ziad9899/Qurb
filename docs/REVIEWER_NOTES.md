# Reviewer Notes — Qurb (قُرب)

Paste the **English** section below into App Store Connect → App Review Information → Notes. The Arabic copy is included for archival; Apple reviewers read English.

---

## English (paste this into App Store Connect)

Thank you for reviewing Qurb. A few things to know before testing.

**Positioning.** Qurb is a **hyperlocal anonymous community** for Arabic-speaking neighborhoods (similar in spirit to Jodel or Nextdoor, not a random/global chat app). Public posts are visible only to users within a geographic radius (500m / 2km / 15km). 1:1 Whispers are *opt-in* private messages between a post author and a specific user who saw the public post — there is no random matchmaking.

**Sign-in.** The app uses **anonymous-only authentication**. There is no email, phone, or social login. No demo credentials are needed; tap the **"Create my ID"** button on the welcome screen and you will receive a random 5-digit anonymous ID. (You must tick the **"I am 13 or older"** checkbox first.)

**Location and reviewer testing.** Qurb shows posts that are physically near the user. Our seed content is anchored to Saudi cities, so a reviewer in Cupertino would normally see an empty feed. To bypass this:

1. Complete onboarding.
2. Open **Settings → Privacy → "Demo location (Store review)"** and toggle it ON.
3. Go back to the Feed. The app will report your location as Riyadh (24.7136, 46.6753) and the feed will populate immediately.

You can also grant the OS location permission and use a custom GPS location of 24.7136, 46.6753 via Xcode's location simulation if you prefer — but the in-app toggle is faster.

**Safety mechanisms required by Guideline 1.2** (all implemented):
- **EULA prohibiting objectionable content**: Settings → Terms of Use, sections 3 and 4.
- **User blocking**: each post card has a "⋯" menu with "Block user". The whisper-thread header has a "⋯" with Block + Report user.
- **Content reporting**: every post, comment, message, and user has an in-app report flow with 6 categories (spam, harassment, fake, NSFW, private info, other). Reports are reviewed within 24 hours. Content auto-hides after 3 reports in 24 hours.
- **Server-side moderation**: 218-entry stopword list + spam regex (phone numbers, shortened URLs, Telegram/WhatsApp deep-links). A `ban_user_by_numeric_id` RPC (service-role only) removes a user's posts immediately.

**Privacy**: Location is snapped to a 100-meter grid cell **on the device** before being transmitted. Precise GPS is never stored or shared. Public privacy policy: <https://ziad9899.github.io/Qurb/privacy.html> (bilingual). Privacy manifest (`PrivacyInfo.xcprivacy`) is included.

**Account deletion** (Guideline 5.1.1(v)): Settings → "Delete my ID and all my data" performs a server-side cascade delete of posts, comments, whispers, votes, blocks, and reports.

**Required-Reason API**: only `UserDefaults (CA92.1)` via shared_preferences, `File timestamp (C617.1)` via Flutter engine, and `System boot time (35F9.1)` via Dart VM. No third-party SDKs.

If anything is unclear or you would like a video walkthrough, please reply through Resolution Center — we will respond within a few hours.

— The Qurb team

---

## العربي (للأرشيف، Apple يقرأ النص الإنجليزي أعلاه)

شكراً لمراجعة قُرب. ملاحظات قبل الاختبار:

**التموضع**: قُرب مجتمع محلي مجهول للناطقين بالعربية (شبيه بـ Jodel أو Nextdoor، **ليس** تطبيق محادثة عشوائية). المنشورات تظهر فقط للمستخدمين ضمن نطاق جغرافي (500م/2كم/15كم). الهَمس محادثة خاصة بين كاتب منشور ومن رأى المنشور علناً — لا اقتران عشوائي.

**التسجيل**: مجهول فقط. لا بريد ولا هاتف ولا تسجيل اجتماعي. لا داعي لبيانات تجريبية — اضغط "أنشئ معرفي" بعد تأكيد العمر 13+ تحصل على رقم عشوائي.

**الموقع**: المراجع في Cupertino قد يرى feed فارغاً. الحل: الإعدادات ‹ الخصوصية ‹ "موقع تجريبي (مراجعة المتجر)" تفعيل. سيُثبَّت الموقع على الرياض.

**أدوات السلامة** (Guideline 1.2 كاملة): شروط الاستخدام، حظر المستخدمين، الإبلاغ بـ 6 فئات، إشراف سيرفري بـ 218 كلمة محظورة.

**الخصوصية**: GPS مُربَط على شبكة 100م قبل المغادرة. الرابط: <https://ziad9899.github.io/Qurb/privacy.html>.

**حذف الحساب**: الإعدادات ‹ "حذف معرفي وكل بياناتي".

---

## Internal checklist before submission (not for App Store)

- [x] Privacy URL live: `https://ziad9899.github.io/Qurb/privacy.html`
- [x] `PrivacyInfo.xcprivacy` exists in `ios/Runner/`
- [x] InfoPlist.strings localized (ar/en)
- [x] `ITSAppUsesNonExemptEncryption` set to false
- [x] CFBundleDisplayName: Qurb (en) / قُرب (ar)
- [x] Age gate checkbox + age rating 17+ in App Store Connect
- [x] Demo location toggle in Settings
- [x] All 4 UGC mechanisms (EULA, block, report, moderation)
- [x] Account deletion in app (5.1.1(v))
- [x] Anonymous sign-in only — no demo credentials needed
- [ ] **Open Xcode → drag `PrivacyInfo.xcprivacy`, `en.lproj/InfoPlist.strings`, `ar.lproj/InfoPlist.strings` into Runner target** ← do this once before archiving
- [ ] **Fill App Privacy nutrition label** in App Store Connect (Data Types: Coarse Location, User Content, User ID)
- [ ] **Set Age Rating to 17+** in App Store Connect → App Information
- [ ] **Category**: Social Networking (primary), Lifestyle (secondary)
- [ ] **Screenshots**: 6.7" iPhone, 6.5" iPhone, 5.5" iPhone, 12.9" iPad
